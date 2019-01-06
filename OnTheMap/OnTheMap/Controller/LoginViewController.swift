//
//  ViewController.swift
//  OnTheMap
//
//  Created by Eric Pedersen on 1/5/19.
//  Copyright © 2019 Eric Pedersen. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginFailed: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //button.backgroundColor = .clear
        loginButton.layer.cornerRadius = 5
        //button.layer.borderWidth = 1
        //button.layer.borderColor = UIColor.black.cgColor
        
        loginFailed.isHidden = true
        setLoggingIn(false)
    }

    @IBAction func loginButton(_ sender: Any) {
        setLoggingIn(true)
        UdacityClient.getSessionID(username: usernameTextField.text ?? "", password: passwordTextField.text ?? "", completion: self.handleSessionResponse(success:error:))
        setLoggingIn(false)
    }
    
    func handleSessionResponse(success: Bool, error: Error?) {
        if success {
            self.performSegue(withIdentifier: "showTableView", sender: self)
        } else {
            loginFailed.isHidden = false
            loginFailed.text = "Login failed: \(error?.localizedDescription ?? "")"
        }
    }
    
    func setLoggingIn(_ loggingIn: Bool) {
        if loggingIn {
            activityIndicator.isHidden = !loggingIn
            activityIndicator.startAnimating()
        } else {
            activityIndicator.isHidden = !loggingIn
            activityIndicator.stopAnimating()
        }
        usernameTextField.isEnabled = !loggingIn
        passwordTextField.isEnabled = !loggingIn
        loginButton.isEnabled = !loggingIn
        //loginViaWebsiteButton.isEnabled = !loggingIn
    }
}

