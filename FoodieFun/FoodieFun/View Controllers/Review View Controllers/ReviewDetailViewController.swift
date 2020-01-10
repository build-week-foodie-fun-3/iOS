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
    
    let demoImages: [String] = [
        "https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg?auto=compress&cs=tinysrgb&h=750&w=1260",
        "https://images.pexels.com/photos/376464/pexels-photo-376464.jpeg?auto=compress&cs=tinysrgb&h=750&w=1260",
        "https://images.pexels.com/photos/70497/pexels-photo-70497.jpeg?auto=compress&cs=tinysrgb&h=750&w=1260"
    ]
    
    var demoIndex = Int.random(in: 0...2)
    
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
        
        if reviewImageView.image == nil, let imageURL = URL(string: demoImages[demoIndex]) {
        
            do {
                let image = try UIImage(withContentsOfURL: imageURL)
                reviewImageView.image = image
            } catch {
                print("Error converting image URL: \(error)")
            }
        }
        
        demoIndex = Int.random(in: 0...2)
    }
}

