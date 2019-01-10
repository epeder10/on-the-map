//
//  ConfirmLocationViewController.swift
//  OnTheMap
//
//  Created by Eric Pedersen on 1/6/19.
//  Copyright © 2019 Eric Pedersen. All rights reserved.
//

import UIKit
import MapKit

class ConfirmLocationViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var finishButton: UIButton!
    
    var coordinate:CLLocationCoordinate2D!
    var mapString: String!
    var mediaURL: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        finishButton.layer.cornerRadius = 5
        
        var annotations = [MKPointAnnotation]()

        let annotation = MKPointAnnotation()
        annotation.coordinate = self.coordinate
        annotations.append(annotation)
        self.mapView.addAnnotations(annotations)

        self.mapView.showAnnotations(annotations, animated: true)

    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    @IBAction func confirmCreateLocationButton(_ sender: Any) {
        UdacityClient.createStudentLocation(mapString: self.mapString, mediaURL: self.mediaURL, latitude: self.coordinate.latitude, longitude: self.coordinate.longitude, completion: self.handleCreateLocationResponse(success:error:))
    }
    
    func handleCreateLocationResponse(success: Bool, error: Error?){
        if success {
            self.navigationController?.popToRootViewController(animated: true)
        } else {
            showFailure(message: error?.localizedDescription ?? "")
        }
    }
    
    func showFailure(message: String) {
        let alertVC = UIAlertController(title: "Invalid Request", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alertVC, animated: true, completion: nil)
    }
}
