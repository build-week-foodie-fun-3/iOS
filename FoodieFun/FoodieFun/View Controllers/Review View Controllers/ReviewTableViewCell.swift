//
//  ReviewTableViewCell.swift
//  FoodieFun
//
//  Created by Dennis Rudolph on 1/8/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class ReviewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameTF: UILabel!
    @IBOutlet weak var priceTF: UILabel!
    @IBOutlet weak var ratingTF: UILabel!
    @IBOutlet weak var reviewImageView: UIImageView!
    
    var review: Review? {
        didSet {
            updateViews()
        }
    }
    
    func updateViews() {
        guard let review = review else { return }
        nameTF.text = review.menuitem
        priceTF.text = review.price
        ratingTF.text = String(review.itemrating)
    }
}
