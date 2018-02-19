//
//  Location+CoreDataProperties.swift
//  
//
//  Created by Mohd Farhan Khan on 2/20/18.
//
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var city: String?
    @NSManaged public var data: NSData?
    @NSManaged public var date: String?
    @NSManaged public var weatherData: NSData?

}
