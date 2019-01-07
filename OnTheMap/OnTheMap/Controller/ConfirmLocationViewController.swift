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
            //let button = UIButton(type: .custom)
            //button.currentTitle = "http://google.com"
            //pinView!.detailCalloutAccessoryView = button
            //pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
}
