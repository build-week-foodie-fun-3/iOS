//
//  DetailRestViewController.swift
//  FoodieFun
//
//  Created by Dennis Rudolph on 1/8/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class DetailRestViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var reviewTableView: UITableView!
    @IBOutlet weak var restImageView: UIImageView!
    
    var restaurant: Restaurant?
    var restaurantController: RestaurantController?

    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    @IBAction func addPhotoButtonTapped(_ sender: UIButton) {
    }
    
    @IBAction func addReviewButtonTapped(_ sender: UIButton) {
    }
    
    
    func updateViews() {
        nameLabel.text = restaurant?.name
        locationLabel.text = restaurant?.location
        hoursLabel.text = restaurant?.hours
        ratingLabel.text = restaurant?.rating
        typeLabel.text = restaurant?.typeofcuisine
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
