//
//  ListViewController.swift
//  On the Map
//
//  Created by Nathaniel PiSierra on 4/7/16.
//  Copyright © 2016 Nathaniel PiSierra. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showProgressIndicator()
        ParseClient().getStudentLocations(){ (error) in
            if (error == nil){
                self.tableView.reloadData()
                self.unshowProgressIndicator()
            }
            else{
                self.unshowProgressIndicator()
                self.alertError(error!)
            }
            
        }
        tableView.delegate = self
        tableView.dataSource = self

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    @IBAction func logoutPressed(sender: AnyObject) {
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
    
    @IBAction func pinPressed(sender: AnyObject) {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("InformationalPostingViewController") as! InformationalPostingViewController
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func reloadPressed(sender: AnyObject) {
        showProgressIndicator()
        ParseClient().getStudentLocations(){ (error) in
            if (error == nil){
                self.tableView.reloadData()
                self.unshowProgressIndicator()
            }
            else{
                self.unshowProgressIndicator()
                self.alertError(error!)
            }
            
        }
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
    
    func alertError(error: String){
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:  {(action: UIAlertAction!) in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentInformation.sharedInstance().studentInformationArray.count
    }
    

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // get cell type
        let cellReuseIdentifier = "mapCell"
        let student = StudentInformation.sharedInstance().studentInformationArray[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as UITableViewCell!
        
        // set cell defaults
        cell.textLabel!.text = student.firstName + " " + student.lastName
        cell.detailTextLabel!.text = student.mediaURL
        cell.imageView!.image = UIImage(named: "pin")
        cell.imageView!.contentMode = UIViewContentMode.ScaleAspectFit
        
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let student = StudentInformation.sharedInstance().studentInformationArray[indexPath.row]
        if let requestUrl = NSURL(string: student.mediaURL) {
            UIApplication.sharedApplication().openURL(requestUrl)
        }
    }

    
}
