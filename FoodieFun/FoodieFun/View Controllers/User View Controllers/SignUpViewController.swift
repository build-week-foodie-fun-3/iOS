//
//  SignUpViewController.swift
//  FoodieFun
//
//  Created by Dennis Rudolph on 1/6/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
   
    var restaurantController: RestaurantController?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func createAccountButtonTapped(_ sender: UIButton) {
        guard let restaurantController = restaurantController else { return }
                guard let username = usernameTextField.text,
                    !username.isEmpty,
                    let email = emailTextField.text,
                    !email.isEmpty,
                    let password = passwordTextField.text,
                    !password.isEmpty,
                    let location = locationTextField.text,
                    !location.isEmpty else { return }
        
        let user = User(username: username, password: password, location: location, email: email, id: nil)
        
        
        restaurantController.signUp(with: user) { (error) in
            if let error = error {
                print("Error occurred during sign up: \(error)")
            } else {
                restaurantController.login(with: user) { (error) in
                    guard error == nil else { return }
                    DispatchQueue.main.async {
                        self.navigationController?.popToRootViewController(animated: true)
                        let alertController = UIAlertController(title: "Sign Up Successful", message: "Welcome \(user.username)", preferredStyle: .alert)
                        let alertAction = UIAlertAction(title: "Get Started", style: .default, handler: nil)
                        alertController.addAction(alertAction)
                        self.present(alertController, animated: true) {
                        }
                    }
                }
            }
        }
    }
}

