//
//  OtherLocationTableViewTableViewController.swift
//  WeatherApp
//
//  Created by Mohd Farhan Khan on 2/19/18.
//  Copyright © 2018 Mohd Farhan Khan. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreData
import MBProgressHUD

class OtherLocationTableViewTableViewController: UITableViewController, UISearchBarDelegate  {
    @IBOutlet weak var citySearchBar: UISearchBar!
    var citiesArray :[Cities] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Choose your location"
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        DispatchQueue.main.async(execute: { () -> Void in
            MBProgressHUD.showAdded(to: self.view, animated: true)
        })
        DispatchQueue.global(qos: .background).async {
            do{
                let managedContext = appDelegate.persistentContainer.viewContext
                let request = NSFetchRequest<Cities>(entityName: "Cities")
                request.predicate = NSPredicate(format: "city != '' ")
                let sortDescriptor = NSSortDescriptor(key: "city", ascending: true)
                request.sortDescriptors = [sortDescriptor]
                let results = try managedContext.fetch(request)
                self.citiesArray = results
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
            }
            catch{
                print("Error from reading data")
            }
        }
    }
    
    func getDataFrom(city: String){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        if city.isEmpty{
            do{
                let managedContext = appDelegate.persistentContainer.viewContext
                let request = NSFetchRequest<Cities>(entityName: "Cities")
                let sortDescriptor = NSSortDescriptor(key: "city", ascending: true)
                request.sortDescriptors = [sortDescriptor]
                let results = try managedContext.fetch(request)
                citiesArray = results
            }
            catch{
                print("Error from reading data")
            }
            return
        }
        do{
            let request = NSFetchRequest<Cities>(entityName: "Cities")
             request.predicate = NSPredicate(format: "city contains[c] %@ ", city)
            let sortDescriptor = NSSortDescriptor(key: "city", ascending: true)
            request.sortDescriptors = [sortDescriptor]
            let results = try managedContext.fetch(request)
            citiesArray = results
            self.tableView.reloadData()
        }
        catch{
            print("Error from reading data")
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        getDataFrom(city: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return citiesArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let cityDict = citiesArray[indexPath.row]
        let cityName = cityDict.city
        let countryName = cityDict.country
        cell.textLabel?.text = "\(cityName!), \(countryName!)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cityDict = citiesArray[indexPath.row]
        UserLocation.sharedInstance.locationLatitude = cityDict.latitude
        UserLocation.sharedInstance.locationLongitude = cityDict.longitude
        UserLocation.sharedInstance.countryIOSCode = cityDict.country!
        UserLocation.sharedInstance.city = cityDict.city!
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "setCustomCityLocation"), object: nil, userInfo: nil)
        self.navigationController?.popViewController(animated: true)
    }
}
