//
//  AppDelegate.swift
//  WeatherApp
//
//  Created by Mohd Farhan Khan on 2/17/18.
//  Copyright © 2018 Mohd Farhan Khan. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var isCityAvailable = false
   
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        getCitiesFromJSON()
        deleteOldWeatherEntriesFromCoreData()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
       
    }

    func applicationWillTerminate(_ application: UIApplication) {
        self.saveContext()
    }

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "WeatherApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            }catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
   
    //getCitiesFromJSON will check wether all elements of cities.json file are stored in core data or not, if not then it will store in core data
    func getCitiesFromJSON(){
        DispatchQueue.global(qos: .background).async {
            if let path = Bundle.main.path(forResource: "cities", ofType: "json") {
                do{
                    let managedContextOnMainTread = self.persistentContainer.viewContext
                    let managedContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                    managedContext.parent = managedContextOnMainTread
                    let request = NSFetchRequest<Cities>(entityName: "Cities")
                    let results = try managedContext.fetch(request)
                    if results.count>0{
                        self.isCityAvailable = true
                        return
                    }
                    let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                    let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                    if let jsonResult = jsonResult as? [[String: AnyObject]]{
                        for item in jsonResult{
                            let entity = NSEntityDescription.entity(forEntityName: "Cities",
                                                                    in: managedContext)!
                            let cityObject = Cities(entity: entity, insertInto: managedContext)
                            let locationDict = item["coord"]
                            cityObject.city = item["name"] as? String
                            cityObject.country = item["country"] as? String
                            cityObject.id =  item["id"] as! Int32
                            cityObject.latitude = locationDict!["lat"] as! Double
                            cityObject.longitude = locationDict!["lon"] as! Double
                        }
                        if managedContext.hasChanges {
                            try managedContext.save()
                        }
                        self.isCityAvailable = true
                    }
                }
                catch{
                    print("Error")
                }
            }
        }
    }
    //deleteOldWeatherEntriesFromCoreData will delete all entries which are older from weather core data
    func deleteOldWeatherEntriesFromCoreData(){
        DispatchQueue.global(qos: .background).async {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            let todayDateString = dateFormatter.string(from: Date())
            let managedContextOnMainTread = self.persistentContainer.viewContext
            let managedContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            managedContext.parent = managedContextOnMainTread
            let request = NSFetchRequest<Location>(entityName: "Location")
            request.predicate = NSPredicate(format: "date != %@",todayDateString)
            do{
                let results = try managedContext.fetch(request)
                if results.count>0{
                    for item in results{
                        managedContext.delete(item)
                    }
                    if managedContext.hasChanges {
                        try managedContext.save()
                    }
                }
            }catch let error as NSError {
                print("Error: \(error), \(error.userInfo)")
            }
        }
    }
}


