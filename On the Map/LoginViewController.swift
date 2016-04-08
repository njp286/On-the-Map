//
//  LoginViewController.swift
//  On the Map
//
//  Created by Nathaniel PiSierra on 4/7/16.
//  Copyright © 2016 Nathaniel PiSierra. All rights reserved.
//

import UIKit



class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loadingSwirl: UIActivityIndicatorView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        loadingSwirl.hidden = true
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
    }

    func alertError(error: String){
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:  {(action: UIAlertAction!) in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func loginPressed(sender: UIButton) {
        showProgressIndicator()
        setUIEnabled(false)
        if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            unshowProgressIndicator()
            setUIEnabled(true)
            alertError("Email and/or Password Fields are blank")
        } else {
            UdacityClient.sharedInstance().getSessionID(emailTextField.text!, password: passwordTextField.text!) { (sessionID, userID, error) in
                if(sessionID != nil && userID != nil){
                    self.unshowProgressIndicator()
                    self.setUIEnabled(true)
                    if(error != nil){
                        self.alertError(error!)
                    }
                    self.completeLogin()
                }
                else{
                    self.setUIEnabled(true)
                    self.unshowProgressIndicator()
                    self.alertError(error!)
                }
            }
        }
    }

    private func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("OTMTabBarController") as! UITabBarController
        self.presentViewController(controller, animated: true, completion: nil)
        })
    }
    
    @IBAction func signUpPressed(sender: UIButton) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signup")!)
        }

    }
    
    
    //Mark Text field stuff
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

    
    //Mark indicator stuff
    
    func showProgressIndicator() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.loadingSwirl.hidden = false
            self.loadingSwirl.startAnimating()
        }
    }

    
    func unshowProgressIndicator() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.loadingSwirl.stopAnimating()
            self.loadingSwirl.hidden = true
        }
    }


    private func setUIEnabled(enabled: Bool) {
            self.emailTextField.enabled = enabled
            self.passwordTextField.enabled = enabled
            self.loginButton.enabled = enabled
            self.signUpButton.enabled = enabled
            
            if enabled {

                self.loginButton.alpha = 1.0
                self.signUpButton.alpha = 1.0
            } else {
                self.loginButton.alpha = 0.5
                self.signUpButton.alpha = 0.5
            }
    }


    
}
