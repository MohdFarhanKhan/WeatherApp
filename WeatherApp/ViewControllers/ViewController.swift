//
//  ViewController.swift
//  WeatherApp
//
//  Created by Mohd Farhan Khan on 2/17/18.
//  Copyright © 2018 Mohd Farhan Khan. All rights reserved.
//

import UIKit
import CoreLocation
import MBProgressHUD

class ViewController: UIViewController,CLLocationManagerDelegate,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var sunsetImageView: UIImageView!
    @IBOutlet weak var sunriseImageView: UIImageView!
    @IBOutlet weak var weatherTableView: UITableView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherTypeLabel: UILabel!
    @IBOutlet weak var cityMaxTemp: UILabel!
    @IBOutlet weak var cityMinTemp: UILabel!
    @IBOutlet weak var sunsetTimeLabel: UILabel!
    @IBOutlet weak var sunriseTimeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cityTempLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    var currentWeather = Weather()
    var weatherArray : [WeatherForecast] = []
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        settingUpLocation()
        checkLocationSetting()
        weatherTableView.backgroundColor = UIColor.clear
        weatherTableView.tableHeaderView?.backgroundColor = UIColor.clear
        self.weatherTableView.isHidden = true
         NotificationCenter.default.addObserver(self, selector: #selector(ViewController.setCustomCityLocation), name: NSNotification.Name(rawValue: "setCustomCityLocation"), object: nil)
    }
    
    func settingUpLocation(){
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func checkLocationSetting(){
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse{
            locationManager.startMonitoringSignificantLocationChanges()
        }
        else{
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    @IBAction func changeToCurrentLocation(_ sender: Any) {
        locationManager.startUpdatingLocation()
        if let location = locationManager.location{
            settingDataFor(location:location)
        }
        else{
            let alert = UIAlertController(title: "Location Alert", message: "Location manager is unable to find you location. Please try after some time", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            locationManager.startUpdatingLocation()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updateUI(){
        sunriseImageView.image = UIImage(named: "sunrise")
        sunsetImageView.image = UIImage(named: "sunset")
        cityLabel.text = currentWeather.cityName
        weatherTypeLabel.text = currentWeather.weatherType
        cityMaxTemp.text = currentWeather.maximumTemp.removeZero().addDegreeSymbol()
        cityMinTemp.text = currentWeather.minTemp.removeZero().addDegreeSymbol()
        sunsetTimeLabel.text =  currentWeather.sunSetTime
        sunriseTimeLabel.text =  currentWeather.sunRiseTime
        dateLabel.text =  currentWeather.todayDate
        cityTempLabel.text = currentWeather.currentTemp.removeZero().addDegreeSymbol()
        weatherImageView.image = UIImage(named: currentWeather.weatherImage)
        weatherArray = currentWeather.weatherArray
        if weatherArray.count>0{
           self.weatherTableView.isHidden = false
           self.weatherTableView.reloadData()
        }
        DispatchQueue.main.async(execute: { () -> Void in
           MBProgressHUD.hide(for: self.view, animated: true)
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.notDetermined) {
           locationManager.requestWhenInUseAuthorization()
        }else if (status == CLAuthorizationStatus.denied) {
           let alert = UIAlertController(title: "Location Alert", message: "Please allow location from settings", preferredStyle: UIAlertControllerStyle.alert)
           alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
           self.present(alert, animated: true, completion: nil)
        }else {
           locationManager.startUpdatingLocation()
        }
    }
    
    func locManager(manager: CLLocationManager,
                    didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.notDetermined) {
           locationManager.requestWhenInUseAuthorization()
        }else if (status == CLAuthorizationStatus.denied) {
           let alert = UIAlertController(title: "Location Alert", message: "Please allow location from settings", preferredStyle: UIAlertControllerStyle.alert)
           alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
           self.present(alert, animated: true, completion: nil)
        }else {
           locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]){
        let latestLocation: CLLocation = locations[locations.count - 1]
        settingDataFor(location: latestLocation)
    }
    
    func settingDataFor(location: CLLocation){
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
           var placeMark: CLPlacemark!
           placeMark = placemarks?[0]
           let newCity = placeMark.administrativeArea!
           if UserLocation.sharedInstance.city != newCity{
                self.currentWeather.isFromCurrent = true
                UserLocation.sharedInstance.locationLatitude = location.coordinate.latitude
                UserLocation.sharedInstance.locationLongitude = location.coordinate.longitude
                UserLocation.sharedInstance.countryIOSCode = placeMark.isoCountryCode!
                UserLocation.sharedInstance.city = placeMark.administrativeArea!
                DispatchQueue.main.async(execute: { () -> Void in
                    MBProgressHUD.showAdded(to: self.view, animated: true)
                })
                self.currentWeather.downloadWeatherData{
                    self.updateUI()
                }
           }
        })
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        var isCityArrayReady = false
        if identifier == "goToLcationFinder" {
           let appDelegate = UIApplication.shared.delegate as? AppDelegate
           if appDelegate?.isCityAvailable == true{
                isCityArrayReady = true
           }
           else{
                let alert = UIAlertController(title: "", message: "City list not ready. Please try after a moment", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
           }
        }
        return isCityArrayReady
    }
    
   @objc func setCustomCityLocation(){
        DispatchQueue.main.async(execute: { () -> Void in
           MBProgressHUD.showAdded(to: self.view, animated: true)
        })
        self.currentWeather.isFromCurrent = false
        self.currentWeather.downloadWeatherData{
           self.updateUI()
        }
    }
   
    func numberOfSections(in tableView: UITableView) -> Int {
        return currentWeather.weatherArray.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let weatherElement = weatherArray[section]
        return weatherElement.date
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherTableViewCell", for: indexPath) as! WeatherTableViewCell
        let weatherElement = weatherArray[indexPath.section]
        cell.weatherImageView.image = UIImage(named: weatherElement.icon)
        cell.weatherTypeLabel.text = weatherElement.description
        cell.weatherTempLabel.text = weatherElement.temperature.removeZero().addDegreeSymbol()
        cell.backgroundColor = UIColor.clear
        cell.backgroundView?.backgroundColor = UIColor.clear
        return cell
    }
}

