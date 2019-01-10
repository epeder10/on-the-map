//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Eric Pedersen on 1/6/19.
//  Copyright © 2019 Eric Pedersen. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locations = [Student]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        UdacityClient.getStudentLocations(completion: self.handleStudentLocationResponse(students:error:))
    }
    
    func handleStudentLocationResponse(students: [Student], error: Error?){
        if let error = error {
            showFailure(message: "Student location data failed to download")
        } else {
            self.locations = students
            loadPins()
        }
    }
    
    func loadPins() {
        var annotations = [MKPointAnnotation]()
        
        for student in locations {
            if let latitude = student.latitude, let longitude = student.longitude, let first = student.firstName, let last = student.lastName, let mediaURL = student.mediaURL {
                let lat = CLLocationDegrees(latitude)
                let long = CLLocationDegrees(longitude)
                
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(first) \(last)"
                annotation.subtitle = mediaURL
                
                annotations.append(annotation)
            }
        }
        self.mapView.addAnnotations(annotations)
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        UdacityClient.deleteSession(completion: self.handleDeleteSessionResponse(success:error:))
    }
    
    func handleDeleteSessionResponse(success: Bool, error: Error?) {
        if success {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func reloadData(_ sender: Any) {
        UdacityClient.getStudentLocations(completion: self.handleStudentLocationResponse(students:error:))
    }
    
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            //let label = UILabel()
            //label.text = annotation.subtitle ?? ""
            //pinView!.detailCalloutAccessoryView = label
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //if control == view.rightCalloutAccessoryView {
        if let toOpen = view.annotation?.subtitle! {
            if let url = URL(string: toOpen) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    /*
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    
        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: annotationView.annotation.subtitle))
        }
    }*/
    
    func showFailure(message: String) {
        let alertVC = UIAlertController(title: "Map Download Failed", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alertVC, sender: nil)
    }
}


