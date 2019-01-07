//
//  NewLinkViewController.swift
//  OnTheMap
//
//  Created by Eric Pedersen on 1/6/19.
//  Copyright © 2019 Eric Pedersen. All rights reserved.
//

import UIKit
import CoreLocation

class NewLinkViewController: UIViewController {
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var linkTextView: UITextField!
    @IBOutlet weak var findLocationButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var coordinate: CLLocationCoordinate2D!
    
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
        } else {
            if let text = locationTextField.text {
                setLoggingIn(true)
                CLGeocoder().geocodeAddressString(text) { (placemarks, error) in
                    self.processResponse(withPlacemarks: placemarks, error: error)
                }
            }
        }
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
        let roundController = segue.destination as! ConfirmLocationViewController
        roundController.coordinate = self.coordinate
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
    
}
