//
//  NewLinkViewController.swift
//  OnTheMap
//
//  Created by Eric Pedersen on 1/6/19.
//  Copyright © 2019 Eric Pedersen. All rights reserved.
//

import UIKit
import CoreLocation

class NewLinkViewController: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate  {
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var linkTextView: UITextField!
    @IBOutlet weak var findLocationButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var coordinate: CLLocationCoordinate2D!
    
    override func viewWillAppear(_ animated: Bool) {
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLoggingIn(false)
        findLocationButton.layer.cornerRadius = 5
    }

    @IBAction func findLocationButton(_ sender: Any) {
        if locationTextField.text == "" {
            showFailure(message: "Location Text Field can't be empty")
        } else if linkTextView.text == "" {
            showFailure(message: "Link Text Field can't be empty")
        } else if !checkLink(linkTextView.text ?? "") {
            showFailure(message: "The URL is invalid.")
        } else {
            if let text = locationTextField.text {
                setLoggingIn(true)
                CLGeocoder().geocodeAddressString(text) { (placemarks, error) in
                    self.processResponse(withPlacemarks: placemarks, error: error)
                }
            }
        }
    }
    
    /*
     Check if the link the user provided is valid
     */
    private func checkLink(_ url: String) -> Bool {
        if let url = URL(string: url) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
        
    @IBAction func cancelAdd(_ sender: Any) {
        showConfirmation()
    }
    
    func setLoggingIn(_ loggingIn: Bool) {
        if loggingIn {
            activityIndicator.isHidden = !loggingIn
            activityIndicator.startAnimating()
        } else {
            activityIndicator.isHidden = !loggingIn
            activityIndicator.stopAnimating()
        }
        locationTextField.isEnabled = !loggingIn
        linkTextView.isEnabled = !loggingIn
        findLocationButton.isEnabled = !loggingIn
    }
    
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        // Update View
        setLoggingIn(false)
        
        if let error = error {
            locationTextField.text = "Unable to Find Location for Address"
            
        } else {
            var location: CLLocation?
            
            if let placemarks = placemarks, placemarks.count > 0 {
                location = placemarks.first?.location
            }
            
            if let location = location {
                self.coordinate = location.coordinate
                self.performSegue(withIdentifier: "confirmLocation", sender: self)
            } else {
                locationTextField.text = "No Matching Location Found"
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let confirmController = segue.destination as! ConfirmLocationViewController
        confirmController.coordinate = self.coordinate
        confirmController.mediaURL = self.linkTextView.text
        confirmController.mapString = self.locationTextField.text
        
    }
    
    func showFailure(message: String) {
        let alertVC = UIAlertController(title: "Invalid Request", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        self.present(alertVC, animated: true, completion: nil)
    }
    
    func showConfirmation() {
        let alertVC = UIAlertController(title: "Discard Changes", message: "Are you sure you want to discard your changes?", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (alert) in
            self.navigationController?.popToRootViewController(animated: true)
        }))
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat{
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue //of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    @objc func keyboardWillShow(_ notification:Notification){
        view.frame.origin.y = -55
    }
    
    @objc func keyboardWillHide(_ notification:Notification){
        view.frame.origin.y = 0
    }
    
    func subscribeToKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
}
