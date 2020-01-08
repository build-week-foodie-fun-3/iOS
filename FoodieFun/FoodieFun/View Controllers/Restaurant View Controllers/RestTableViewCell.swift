//
//  RestTableViewCell.swift
//  FoodieFun
//
//  Created by Dennis Rudolph on 1/6/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class RestTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    var restaurant: Restaurant? {
        didSet {
            updateViews()
        }
    }

    func updateViews() {
        guard let restaurant = restaurant else { return }
        nameLabel.text = restaurant.name
        locationLabel.text = restaurant.location
        ratingLabel.text = restaurant.rating
    }
}
