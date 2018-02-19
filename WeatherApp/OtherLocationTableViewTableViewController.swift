//
//  OtherLocationTableViewTableViewController.swift
//  WeatherApp
//
//  Created by Mohd Farhan Khan on 2/19/18.
//  Copyright © 2018 Mohd Farhan Khan. All rights reserved.
//

import UIKit
import SwiftyJSON
class OtherLocationTableViewTableViewController: UITableViewController {
    var citiesArray :[[String: AnyObject]] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.title = "Choose your location"
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
       citiesArray = appDelegate.citiesArray
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return citiesArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let cityDict = citiesArray[indexPath.row]
        let cityName = cityDict["name"] as! String
        let countryName = cityDict["country"] as! String
        cell.textLabel?.text = "\(cityName), \(countryName)"
        // Configure the cell...

        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cityDict = citiesArray[indexPath.row]
        let locationDict = cityDict["coord"] as! [String:Double]
        UserLocation.sharedInstance.locationLatitude = locationDict["lat"] as! Double
        UserLocation.sharedInstance.locationLongitude = locationDict["lon"] as! Double
        UserLocation.sharedInstance.countryIOSCode = cityDict["country"] as! String
        UserLocation.sharedInstance.city = cityDict["name"] as! String
       
        //setCustomCityLocation
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "setCustomCityLocation"), object: nil, userInfo: nil)
        self.navigationController?.popViewController(animated: true)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
