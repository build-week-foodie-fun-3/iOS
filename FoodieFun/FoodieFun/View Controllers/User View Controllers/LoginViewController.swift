//
//  LoginViewController.swift
//  FoodieFun
//
//  Created by Dennis Rudolph on 1/6/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var restaurantController: RestaurantController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signInButtonTapped(_ sender: UIButton) {
        guard let restaurantController = restaurantController else { return }
        guard let username = usernameTextField.text,
            !username.isEmpty,
            let password = passwordTextField.text,
            !password.isEmpty else { return }
        
        let user = User(username: username, password: password)
        
        restaurantController.login(with: user) { (error) in
            guard error == nil else { return }
            DispatchQueue.main.async {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreateAccountSegue" {
            if let createVC = segue.destination as? SignUpViewController {
                createVC.restaurantController = restaurantController
            }
        }
    }
}
