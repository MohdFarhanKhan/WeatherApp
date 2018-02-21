//
//  Weather.swift
//  WeatherApp
//
//  Created by Mohd Farhan Khan on 2/18/18.
//  Copyright © 2018 Mohd Farhan Khan. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import CoreData
// UserLocation  will store location of user
class UserLocation{
    static let sharedInstance = UserLocation()
    var city = ""
    var countryIOSCode = ""
    var locationLatitude : Double
    var locationLongitude : Double
    
    init(){
        city = ""
        countryIOSCode = ""
        locationLatitude = 0.0
        locationLongitude =  0.0
    }
}
//WeatherForecast will store forecasting elements of Weather class
struct WeatherForecast {
    
    let description:String
    let icon:String
    let temperature:Double
    let date:String
    
    init(json:JSON) throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .medium
        let  weatherImage = json[String(describing: weatherKeys.weatherKey.rawValue)][0][String(describing: weatherKeys.iconKey.rawValue)].stringValue
        let weatherDescription = json[String(describing: weatherKeys.weatherKey.rawValue)][0][String(describing: weatherKeys.descriptionKey.rawValue)].stringValue
        let maxTemp = (json[String(describing: weatherKeys.mainKey.rawValue)][String(describing: weatherKeys.tempMaxKey.rawValue)].doubleValue-273.15).roundedTo(place: 0)
        let dateTime = dateFormatter.string(from: Date(timeIntervalSince1970: (json[String(describing: weatherKeys.dateKey.rawValue)].doubleValue)))
        self.description = weatherDescription
        self.icon = weatherImage
        self.temperature = maxTemp
        self.date = dateTime
    }
}
//Weather will store weather of user location
class Weather{
    private var _cityName : String!
    private var _sunRiseTime : String!
    private var _sunSetTime : String!
    private var _minTemp : Double!
    private var _maximumTemp : Double!
    private var _currentTemp : Double!
    private var _weatherImage : String!
    private var _weatherType : String!
    private var _todayDate : String!
    private var _weatherArray : [JSON]!
    private var _forecastArray : [WeatherForecast]?   //will store weather forecasting elements
    var isFromCurrent = true
    var cityName : String{
        if _cityName == nil{
            _cityName = ""
        }
        return _cityName
    }
    var sunRiseTime : String{
        if _sunRiseTime == nil{
            _sunRiseTime = ""
        }
        return _sunRiseTime
    }
    var sunSetTime : String{
        if _sunSetTime == nil{
            _sunSetTime = ""
        }
        return _sunSetTime
    }
    var weatherImage : String{
        if _weatherImage == nil{
            _weatherImage = ""
        }
        return _weatherImage
    }
    var weatherType : String{
        if _weatherType == nil{
            _weatherType = ""
        }
        return _weatherType
    }
    var todayDate : String{
        if _todayDate == nil{
            _todayDate = ""
        }
        return _todayDate
    }
    var minTemp : Double{
        if _minTemp == nil{
            _minTemp = 0.0
        }
        return _minTemp
    }
    var maximumTemp : Double{
        if _maximumTemp == nil{
            _maximumTemp = 0.0
        }
        return _maximumTemp
    }
    var currentTemp : Double{
        if _currentTemp == nil{
            _currentTemp = 0.0
        }
        return _currentTemp
    }
    var weatherArray : [WeatherForecast]{
        if _weatherArray == nil{
            _forecastArray = []
        }
        else{
            var temForecastArray:[WeatherForecast] = []
            for item in _weatherArray{
                if let weatherObject = try? WeatherForecast(json: item) {
                    temForecastArray.append(weatherObject)
                }
            }
            _forecastArray = temForecastArray
        }
        return _forecastArray!
    }
    
    func getWeatherURL()->String{
        let  weatherAPIURL = "http://api.openweathermap.org/data/2.5/weather?lat=\(UserLocation.sharedInstance.locationLatitude)&lon=\(UserLocation.sharedInstance.locationLongitude)&appid=0e269c8b0a82df046cc9327562754eac"
        return weatherAPIURL
    }
    
    func getForecastURL()->String{
        let forecastAPIURL = "http://api.openweathermap.org/data/2.5/forecast?lat=\(UserLocation.sharedInstance.locationLatitude)&lon=\(UserLocation.sharedInstance.locationLongitude)&appid=0e269c8b0a82df046cc9327562754eac"
        return forecastAPIURL
    }
    
    func getCurrentWeatherDataFromLocalStorage(completed: (Bool)->()){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        let todayDateString = dateFormatter.string(from: Date())
        let cityName = UserLocation.sharedInstance.city
        let managedContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<Location>(entityName: "Location")
        request.predicate = NSPredicate(format: "city == %@ AND date == %@", cityName,todayDateString)
        do{
            let results = try managedContext.fetch(request)
            if results.count<=0{
                completed(false)
                return
            }
            let firstRow = results[0] as Location
            let storedData = firstRow.data
            let weatherData = firstRow.weatherData
            if let storedData = storedData, (weatherData != nil){
                let storedDataArray = try JSON(data: storedData)
                let storedWeatherArray = try JSON(data: weatherData!)
                let storedWeatherJson = storedWeatherArray.dictionary
                self._weatherArray = storedWeatherJson!["list"]?.array
                setWeatherElement(json: storedDataArray)
                setTemperatureElementFrom(forecastArray: self._weatherArray)
                completed(true)
            }
        }catch let error as NSError {
            completed(false)
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    func downloadWeatherData(completed: @escaping downloadComplete){
        if isFromCurrent == true{
            getCurrentWeatherDataFromLocalStorage { (isFound) in
                if isFound == false{
                    downloadCurrentWeather(completed: {
                        completed()
                    })
                }
                else{
                    completed()
                }
            }
        }
        else{
            downloadCurrentWeather(completed: {
                completed()
            })
        }
    }
    
    func downloadCurrentWeather(completed: @escaping downloadComplete){
        Alamofire.request( URL(string: getWeatherURL())!,
                           method: .get).validate().responseJSON { (response) -> Void in
            let result = response.result
            let json = JSON(result.value )
            do {
                if self.isFromCurrent == true{
                    let encryptedData: Data = try json.rawData()
                    self.saveData(data: encryptedData)
                }
            } catch let myJSONError {
                    print(myJSONError)
            }
            self.setWeatherElement(json: json)
            self.downloadWeatherForecasteData(completed: completed)
        }
    }
    
    func downloadWeatherForecasteData(completed: @escaping downloadComplete){
        Alamofire.request( URL(string: getForecastURL())!,
                           method: .get).validate().responseJSON { (response) -> Void in
            let result = response.result
            let json = JSON(result.value )
            let storedWeatherJson = json.dictionary
            self._weatherArray = storedWeatherJson!["list"]?.array
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            do{
                self.setTemperatureElementFrom(forecastArray: self._weatherArray)
                let encryptedData: Data = try json.rawData()
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .none
                let todayDateString = dateFormatter.string(from: Date())
                let cityName = UserLocation.sharedInstance.city
                let managedContext = appDelegate.persistentContainer.viewContext
                let request = NSFetchRequest<Location>(entityName: "Location")
                request.predicate = NSPredicate(format: "city == %@ AND date == %@", cityName,todayDateString)
                let results = try managedContext.fetch(request)
                let currentLocation = results.first
                currentLocation?.weatherData = encryptedData
                try managedContext.save()
            }catch let myJSONError {
                    print(myJSONError)
            }
            completed()
        }
    }
    
    func saveData(data: Data){
        if isFromCurrent == false{
            return
        }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        let todayDateString = dateFormatter.string(from: Date())
        let cityName = UserLocation.sharedInstance.city
        let entity = NSEntityDescription.entity(forEntityName: "Location",
                                                in: managedContext)!
        let locationManagedObject = Location(entity: entity, insertInto: managedContext)
        locationManagedObject.city = cityName
        locationManagedObject.date = todayDateString
        locationManagedObject.data = data
        try! managedContext.save()
    }
    
    func setWeatherElement(json: JSON){
        let storedJson = json.dictionary        
        self._cityName = storedJson![weatherKeys.cityNameKey.rawValue]?.stringValue
        self._weatherImage = storedJson![String(describing: weatherKeys.weatherKey.rawValue)]![0][String(describing: weatherKeys.iconKey.rawValue)].stringValue
        self._weatherType = storedJson![String(describing: weatherKeys.weatherKey.rawValue)]![0][String(describing: weatherKeys.mainKey.rawValue)].stringValue
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        self._todayDate = dateFormatter.string(from: Date(timeIntervalSince1970: (storedJson![String(describing: weatherKeys.dateKey.rawValue)]?.doubleValue)!))
        self._currentTemp = (storedJson![String(describing: weatherKeys.mainKey.rawValue)]![String(describing: weatherKeys.tempKey.rawValue)].doubleValue-273.15).roundedTo(place: 0)
        self._minTemp = (storedJson![String(describing: weatherKeys.mainKey.rawValue)]![String(describing: weatherKeys.tempMinKey.rawValue)].doubleValue-273.15).roundedTo(place: 0)
        self._maximumTemp = (storedJson![String(describing: weatherKeys.mainKey.rawValue)]![String(describing: weatherKeys.tempMaxKey.rawValue)].doubleValue-273.15).roundedTo(place: 0)
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .medium
        self._sunRiseTime = dateFormatter.string(from: Date(timeIntervalSince1970: storedJson![String(describing: weatherKeys.sysKey.rawValue)]![String(describing: weatherKeys.sunriseKey.rawValue)].doubleValue))
        self._sunSetTime = dateFormatter.string(from: Date(timeIntervalSince1970: storedJson![String(describing: weatherKeys.sysKey.rawValue)]![String(describing: weatherKeys.sunsetKey.rawValue)].doubleValue))
    }
    
    //setTemperatureElementFrom will set currentTemp, maxTemp and minTemp from weatherforecast array
    func setTemperatureElementFrom(forecastArray: [JSON]){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let nowDateWithTime = Date()
        for item in forecastArray{
            let dateWithTime =  Date(timeIntervalSince1970: (item[String(describing: weatherKeys.dateKey.rawValue)].doubleValue))
            if isFirtTimeGreaterThanOrEqualToSecondTime(firstDate: nowDateWithTime, secondDate: dateWithTime){
                self._currentTemp = (item[String(describing: weatherKeys.mainKey.rawValue)][String(describing: weatherKeys.tempKey.rawValue)].doubleValue-273.15).roundedTo(place: 0)
                self._minTemp = (item[String(describing: weatherKeys.mainKey.rawValue)][String(describing: weatherKeys.tempMinKey.rawValue)].doubleValue-273.15).roundedTo(place: 0)
                self._maximumTemp = (item[String(describing: weatherKeys.mainKey.rawValue)][String(describing: weatherKeys.tempMaxKey.rawValue)].doubleValue-273.15).roundedTo(place: 0)
            }
        }
    }
    
    func isFirtTimeGreaterThanOrEqualToSecondTime(firstDate: Date, secondDate: Date)->Bool{
        var isConditionTrue = false
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        let firstDateString = dateFormatter.string(from: firstDate as Date)
        let secondDateString = dateFormatter.string(from: secondDate as Date)
        let timeInSecondForDateFirst = firstDate.getTotalTimeInSecond()
        let timeInSecondForDateSecond = secondDate.getTotalTimeInSecond()
        if (firstDateString == secondDateString) && timeInSecondForDateFirst >= timeInSecondForDateSecond{
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .full
            isConditionTrue = true
        }
        return isConditionTrue
    }
}
