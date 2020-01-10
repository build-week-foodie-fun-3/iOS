//
//  ReviewDetailViewController.swift
//  FoodieFun
//
//  Created by Dennis Rudolph on 1/6/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class ReviewDetailViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var reviewImageView: UIImageView!
    
    
    var review: Review?
    var restaurantController: RestaurantController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    @IBAction func addReviewPhotoButtonTapped(_ sender: UIButton) {
    }
    
    func updateViews() {
        guard let review = review else { return }
        nameLabel.text = review.menuitem
        typeLabel.text = review.typeofcuisine
        priceLabel.text = review.price
        ratingLabel.text = String(review.itemrating)
        notesTextView.text = review.itemreview
    }
}
