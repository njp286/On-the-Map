//
//  InformationalPostingViewController.swift
//  On the Map
//
//  Created by Nathaniel PiSierra on 4/7/16.
//  Copyright © 2016 Nathaniel PiSierra. All rights reserved.
//

import UIKit
import MapKit


class InformationalPostingViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var studyLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var findOnMapButton: UIButton!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var activityIndicatior: UIActivityIndicatorView!
    
    var userLocation: CLLocationCoordinate2D!
    var newStudentLocation = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view2(false)
        linkTextField.delegate = self
        locationTextField.delegate = self
        map.delegate = self
        activityIndicatior.hidden = true
        
    }
    
    func alertError(error: String){
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:  {(action: UIAlertAction!) in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    

    
    @IBAction func cancelPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func findOnMapPressed(sender: AnyObject) {
        showProgressIndicator()
        if locationTextField.text == "" {
            unshowProgressIndicator()
            alertError("No location entered. Please enter a location to add it to map")
        }
        else {
            findEnteredLocation(locationTextField.text!, completionHandler: { (coordinates) -> Void in
                //Valid location returned
                if let location = coordinates {
                    self.userLocation = location
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.displayMapWithUserLocation(self.userLocation)
                        self.view2(true)
                    })
                    self.unshowProgressIndicator()
                    print("Valid location geocoded: \(self.userLocation.latitude), \(self.userLocation.longitude)")
                    
                //Invalid location
                } else {
                    //Display alert message for invalid location
                    self.unshowProgressIndicator()

                    self.alertError("Could not geocode the location")
                    
                }
                
            })
        }
    }
    
    
    func findEnteredLocation(location: String, completionHandler: (coordinates: CLLocationCoordinate2D?) -> Void) {
        
        CLGeocoder().geocodeAddressString(location) { (placemarks, error) -> Void in
            
            if let error = error {
                print("Geocoding error: \(error)")
                completionHandler(coordinates: nil)
                
                if error.localizedDescription.containsString("The Internet connection appears to be offline")  {
                    self.alertError("The internet connection appears to be offline")
                    
                } else {
                    self.alertError("Error geocoding")
                }
                
            } else {
                if let placemark = placemarks?.first {
                    completionHandler(coordinates: placemark.location!.coordinate)
                } else {
                    completionHandler(coordinates: nil)
                }
            }
            
        }
        
    }
    
    @IBAction func submitButtonPressed(sender: AnyObject) {
    
        showProgressIndicator()
        submitHelper()
    }
    
    func submitHelper(){
        //Carry out submit action
        if linkTextField.text != "" {
            
            //Create the Student Information object for posting to PARSE
            var info = [String : AnyObject]()
            info[ParseConstants.StudentLocationKeys.uniqueKey] = UdacityClient.sharedInstance().userID
            info[ParseConstants.StudentLocationKeys.firstName] = UdacityClient.sharedInstance().firstName
            info[ParseConstants.StudentLocationKeys.lastName] = UdacityClient.sharedInstance().lastName
            info[ParseConstants.StudentLocationKeys.mapString] = locationTextField.text!
            info[ParseConstants.StudentLocationKeys.mediaURL] = linkTextField.text!
            info[ParseConstants.StudentLocationKeys.latitude] = userLocation.latitude
            info[ParseConstants.StudentLocationKeys.longitude] = userLocation.longitude
            
            let studentInfo = StudentInformationStruct.init(dictionary: info)
            
                ParseClient.sharedInstance().postStudentLocation(studentInfo) { (error) in
                    
                    self.unshowProgressIndicator()
                    
                    if(error != nil){
                        self.alertError(error!)
                    }
                    else{
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                }
                
            
        } else {
            unshowProgressIndicator()
            alertError("Nothing entered for URL")
        }

    }
    
    func view2(on: Bool){
        map.hidden = !on
        submitButton.hidden = !on
        locationTextField.hidden = on
        linkTextField.hidden = !on
        findOnMapButton.hidden = on
        studyLabel.hidden = on
    }
    
    
    //Display the map in the mapFrame with the location as an annotation
    func displayMapWithUserLocation(location: CLLocationCoordinate2D) -> Void {
        
        map.zoomEnabled = false
        map.scrollEnabled = false
        
        
        //Create the annotation and add to the map
        let annotation = MKPointAnnotation()
        
        let lat = CLLocationDegrees(location.latitude)
        let long = CLLocationDegrees(location.longitude)
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        annotation.coordinate = coordinate
        let annotationArray : [MKPointAnnotation] = [annotation]
        
        map.addAnnotation(annotation)
        map.showAnnotations(annotationArray, animated: true)
        
        
        
    }
    
    
    //Mark indicator stuff
    func showProgressIndicator() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.activityIndicatior.hidden = false
            self.activityIndicatior.startAnimating()
        }
    }
    
    func unshowProgressIndicator() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.activityIndicatior.stopAnimating()
            self.activityIndicatior.hidden = true
        }
    }

    
    //Mark -- Text View Delegate Stuff
    
    func textViewDidBeginEditing(textView: UITextView) {
        
        textView.text = ""
        textView.textAlignment = .Left
        
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        
        textView.textAlignment = .Center
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        return true
    }
    

    
}
