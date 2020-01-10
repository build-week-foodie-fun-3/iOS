//
//  AddReviewViewController.swift
//  FoodieFun
//
//  Created by Dennis Rudolph on 1/8/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class AddReviewViewController: UIViewController {
    
    @IBOutlet weak var menuItemTF: UITextField!
    @IBOutlet weak var typeTF: UITextField!
    @IBOutlet weak var priceTF: UITextField!
    @IBOutlet weak var ratingTF: UITextField!
    @IBOutlet weak var reviewTF: UITextField!
    @IBOutlet weak var photoTF: UITextField!
    
    var restaurant: Restaurant?
    var restaurantController: RestaurantController?
    var review: Review?

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    @IBAction func createReviewButtonTapped(_ sender: UIButton) {
        if review == nil {
            guard let restaurantController = restaurantController, let restaurant = restaurant, let restName = restaurant.name, let menuItem = menuItemTF.text, !menuItem.isEmpty, let ratingString = ratingTF.text, let price = priceTF.text else { return }
            
            restaurantController.createReview(restaurant: restaurant, restaurantName: restName, menuItem: menuItem, price: price, itemRating: Int32(ratingString) ?? 0, photoUrl: photoTF.text ?? "", itemReview: reviewTF.text ?? "", typeOfCuisine: typeTF.text ?? "", context: CoreDataStack.shared.mainContext) {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        } else {
            guard let restaurantController = restaurantController, let restaurant = restaurant, let restName = restaurant.name, let menuItem = menuItemTF.text, !menuItem.isEmpty, let ratingString = ratingTF.text, let price = priceTF.text, let review = review else { return }
            
            restaurantController.updateReview(review: review, restaurantName: restName, menuItem: menuItem, price: price, itemRating: Int32(ratingString) ?? 0, photoUrl: photoTF.text ?? "", itemReview: reviewTF.text ?? "", typeOfCuisine: typeTF.text ?? "", context: CoreDataStack.shared.mainContext) {
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}
