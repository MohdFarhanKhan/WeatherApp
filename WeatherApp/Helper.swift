//
//  Helper.swift
//  WeatherApp
//
//  Created by Mohd Farhan Khan on 2/18/18.
//  Copyright © 2018 Mohd Farhan Khan. All rights reserved.
//

import Foundation
import UIKit



typealias downloadComplete = ()->()
enum weatherKeys: String{
    case cityNameKey = "name"
    case weatherKey = "weather"
    case mainKey = "main"
    case descriptionKey = "description"
    case iconKey = "icon"
    case tempKey = "temp"
    case tempMinKey = "temp_min"
    case tempMaxKey = "temp_max"
    case pressureKey = "pressure"
    case humidityKey = "humidity"
    case windKey = "wind"
    case speedKey = "speed"
    case degKey = "deg"
    case cloudsKey = "clouds"
    case dateKey = "dt"
    case sysKey = "sys"
    case countryISOCodeKey = "country"
    case sunriseKey = "sunr ise"
    case sunsetKey = "sunset"
   
}
extension Double{
    func roundedTo(place: Int)->Double{
        let divisor = pow(10.0, Double(place))
        return (self*divisor).rounded()/divisor
    }
    func removeZero()->String {
        let nf = NumberFormatter()
        nf.minimumFractionDigits = 0
        nf.maximumFractionDigits = 0
        
        return nf.string(from: NSNumber(value:self))!
    }
}
extension Date{
    func dayOfWeek()->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self)
    }
}
extension String{
    func addDegreeSymbol()->String{        
        return self+"\u{00B0} C"
    }
    
}
/*
 let WEATHER_API_URL = "http://api.openweathermap.org/data/2.5/weather?lat=\(UserLocation.sharedInstance.locationLatitude)&lon=\(UserLocation.sharedInstance.locationLongitude)&appid=0e269c8b0a82df046cc9327562754eac"
 let FORECAST_API_URL = "http://api.openweathermap.org/data/2.5/forecast?lat=\(UserLocation.sharedInstance.locationLatitude)&lon=\(UserLocation.sharedInstance.locationLongitude)&appid=0e269c8b0a82df046cc9327562754eac"
 */
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
