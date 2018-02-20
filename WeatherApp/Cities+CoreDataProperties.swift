//
//  Cities+CoreDataProperties.swift
//  
//
//  Created by Mohd Farhan Khan on 2/20/18.
//
//

import Foundation
import CoreData


extension Cities {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Cities> {
        return NSFetchRequest<Cities>(entityName: "Cities")
    }

    @NSManaged public var city: String?
    @NSManaged public var id: Int32
    @NSManaged public var country: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double

}
