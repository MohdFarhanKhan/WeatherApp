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
    func getTotalTimeInSecond()->Int{
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: self)
        let minutes = calendar.component(.minute, from: self)
        let seconds = calendar.component(.second, from: self)
        let totalTime = hour*3600+minutes*60+seconds
        return totalTime
    }
}

extension String{
    func addDegreeSymbol()->String{        
        return self+"\u{00B0} C"
    }
}

