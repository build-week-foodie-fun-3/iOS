//
//  AddRestViewController.swift
//  FoodieFun
//
//  Created by Dennis Rudolph on 1/8/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class AddRestViewController: UIViewController {
    
    var restaurantController: RestaurantController?

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var locationTF: UITextField!
    @IBOutlet weak var hoursTF: UITextField!
    @IBOutlet weak var typeTF: UITextField!
    @IBOutlet weak var ratingTF: UITextField!
    @IBOutlet weak var photoTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

      
    }
    
    @IBAction func createRestButtonTapped(_ sender: UIButton) {
        guard let restaurantController = restaurantController, let userid = restaurantController.loggedInUser?.id, let name = nameTextField.text, !name.isEmpty, let location = locationTF.text, !location.isEmpty, let rating = ratingTF.text, !rating.isEmpty else { return }
        restaurantController.createRestaurant(id: userid, name: name, location: location, hours: hoursTF.text ?? "", photoUrl: photoTF.text ?? "", rating: rating, typeOfCuisine: typeTF.text ?? "", context: CoreDataStack.shared.mainContext)
        
        self.dismiss(animated: true, completion: nil)
    }
}
