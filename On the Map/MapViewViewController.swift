//
//  MapViewViewController.swift
//  On the Map
//
//  Created by Nathaniel PiSierra on 4/7/16.
//  Copyright © 2016 Nathaniel PiSierra. All rights reserved.
//

import UIKit
import MapKit

class MapViewViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var map: MKMapView!
    var annotations = [MKPointAnnotation]()
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLocations()
        
    }
    
    private func loadLocations(){
        showProgressIndicator()
        map.removeAnnotations(annotations)
        annotations.removeAll()
        ParseClient().getStudentLocations(){ (error) in
            if (error == nil){
                for dictionary in StudentInformation.sharedInstance().studentInformationArray {
                    
                    // Notice that the float values are being used to create CLLocationDegree values.
                    // This is a version of the Double type.
                    let lat = CLLocationDegrees(dictionary.latitude)
                    let long = CLLocationDegrees(dictionary.longitude)
                    
                    // The lat and long are used to create a CLLocationCoordinates2D instance.
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    
                    let first = dictionary.firstName
                    let last = dictionary.lastName
                    let mediaURL = dictionary.mediaURL
                    
                    // Here we create the annotation and set its coordiate, title, and subtitle properties
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = "\(first) \(last)"
                    annotation.subtitle = mediaURL as String
                    
                    // Finally we place the annotation in an array of annotations.
                    self.annotations.append(annotation)
                }
                
                // When the array is complete, we add the annotations to the map.
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    self.map.addAnnotations(self.annotations)
                }
                self.unshowProgressIndicator()
                
            }
            else{
                self.unshowProgressIndicator()
                self.alertError(error!)
            }
            
        }

    }
    
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                let isValidURL = app.openURL(NSURL(string: toOpen)!)
                
                //Display an alertView if the URL can't be opened
                if !isValidURL {
                    alertError("Invalid Url")
                }
            }
        }
    }

    func alertError(error: String){
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:  {(action: UIAlertAction!) in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func pinPressed(sender: AnyObject) {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("InformationalPostingViewController") as! InformationalPostingViewController
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func showProgressIndicator() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.spinner.hidden = false
            self.spinner.startAnimating()
        }
    }
    
    
    func unshowProgressIndicator() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.spinner.stopAnimating()
            self.spinner.hidden = true
        }
    }

    
    @IBAction func refreshPressed(sender: AnyObject) {
        loadLocations()

    }
    
    @IBAction func logOutPressed(sender: AnyObject) {
        showProgressIndicator()
        UdacityClient.sharedInstance().logOutOfSession() { (error) in
            if (error != nil){
                self.unshowProgressIndicator()
                self.alertError(error!)
            }
            else{
                self.unshowProgressIndicator()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    
    
    
}
