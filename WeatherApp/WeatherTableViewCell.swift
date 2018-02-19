//
//  WeatherTableViewCell.swift
//  WeatherApp
//
//  Created by Mohd Farhan Khan on 2/19/18.
//  Copyright © 2018 Mohd Farhan Khan. All rights reserved.
//

import UIKit

class WeatherTableViewCell: UITableViewCell {

    @IBOutlet weak var weatherImageView: UIImageView!
   
    @IBOutlet weak var weatherTypeLabel: UILabel!
    @IBOutlet weak var weatherTempLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
