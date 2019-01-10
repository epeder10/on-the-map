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

        loginButton.layer.cornerRadius = 5

        loginFailed.isHidden = true
        setLoggingIn(false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        usernameTextField.text = ""
        passwordTextField.text = ""
    }

    @IBAction func loginButton(_ sender: Any) {
        setLoggingIn(true)
        if usernameTextField.text == "" {
            showFailure(message: "Username can't be blank")
            setLoggingIn(false)
        } else if passwordTextField.text == "" {
            showFailure(message: "Password can't be blank")
            setLoggingIn(false)
        } else {
            UdacityClient.getSessionID(username: usernameTextField.text ?? "", password: passwordTextField.text ?? "", completion: self.handleSessionResponse(success:error:))
        }
    }
    
    func handleSessionResponse(success: Bool, error: Error?) {
        if success {
            UdacityClient.getStudent(completion: self.handleStudentResponse(success:error:))
        } else {
            loginFailed.isHidden = false
            loginFailed.text = "Login failed"
            loginFailed.text = "\(error?.localizedDescription ?? "")"
            passwordTextField.text = ""
            setLoggingIn(false)
        }
    }
    
    func handleStudentResponse(success: Bool, error: Error?) {
        setLoggingIn(false)
        if success {
            self.performSegue(withIdentifier: "showTableView", sender: self)
        } else {
            loginFailed.isHidden = false
            loginFailed.text = "Login failed.  Failed to get user information."
            passwordTextField.text = ""
        }
    }
    @IBAction func signUpButton(_ sender: Any) {
        if let url = URL(string: "https://auth.udacity.com/sign-up") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
    
    func showFailure(message: String) {
        let alertVC = UIAlertController(title: "Invalid Request", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alertVC, animated: true, completion: nil)
    }
}

