//
//  UdacityClient.swift
//  On the Map
//
//  Created by Nathaniel PiSierra on 4/7/16.
//  Copyright © 2016 Nathaniel PiSierra. All rights reserved.
//

import Foundation

class UdacityClient : NSObject {

    /* Shared Session */
    var session: NSURLSession
    
    /* Authentication state */
    var sessionID : String!
    var userID : String!
    
    /* Student Name */
    var firstName : String!
    var lastName : String!
    
    
    //MARK: Initializer
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }


    func getSessionID(email: String, password: String, completionHandler: (sessionID: String?, accountKey: String?, error: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let text = "{\"udacity\": {\"username\": \"" + email + "\", \"password\": \"" + password + "\"}}"
        request.HTTPBody = text.dataUsingEncoding(NSUTF8StringEncoding)
        let task = session.dataTaskWithRequest(request) { data, response, error in
            func displayError(error: String, debugLabelText: String? = nil) {
                print(error)
                completionHandler(sessionID: nil, accountKey: nil, error: error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            
            //Parse the data
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
                
            } catch {
                displayError("Could not parse the data as JSON: '\(newData)'")
                return
            }
            
            /* 6. Use the data! */
            
            guard let session: AnyObject! = parsedResult["session"]  else {
                displayError("Cannot find session")
                return
            }
            
            guard let sessionID: String! = session["id"] as! String else {
                displayError("Cannot find sessionID")
                return
            }
            
            guard let account: AnyObject! = parsedResult["account"]  else {
                displayError("Cannot find account")
                return
            }
            
            guard let key: String! = account["key"] as! String else {
                displayError("Cannot find userID")
                return
            }
            
            self.sessionID = sessionID
            self.userID = key
            self.getUserInfo(key) { (error) in
                if(error == nil){
                    completionHandler(sessionID: sessionID, accountKey: key, error: nil)
                }
                else {
                    completionHandler(sessionID: sessionID, accountKey: key, error: error)
                }
                
            }
            
            
        }
        task.resume()
        
        
    }
    
    
    func getUserInfo(user: String, completionHandler: (error: String?) -> Void){
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/\(user)")!)
        let task = session.dataTaskWithRequest(request) { data, response, error in
            func displayError(error: String, debugLabelText: String? = nil) {
                print(error)
                completionHandler(error: error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            
            //Parse the data
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
                
            } catch {
                displayError("Could not parse the data as JSON: '\(newData)'")
                return
            }
            
            guard let user: AnyObject! = parsedResult[UdacityConstants.UdacityKeys.user]  else {
                displayError("Cannot find user")
                return
            }
            
            guard let lastName: String! = user[UdacityConstants.UdacityKeys.last_name] as! String else {
                displayError("Cannot find last_name")
                return
            }
            
            guard let firstName: String! = user[UdacityConstants.UdacityKeys.first_name] as! String else {
                displayError("Cannot find first_name")
                return
            }
            
            self.firstName = firstName
            self.lastName = lastName
            completionHandler(error: nil)
            
            
        }
        task.resume()
    }
    

    //to do --> return errors if any
    func logOutOfSession(completionHandler:(error: String?) -> Void){
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let task = session.dataTaskWithRequest(request) { data, response, error in
            func displayError(error: String, debugLabelText: String? = nil) {
                print(error)
                completionHandler(error: error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            /* GUARD: Was there any data returned? */
            guard let _ = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            completionHandler(error: nil)

        }
        task.resume()
    }

    
    class func sharedInstance() -> UdacityClient {
        
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        
        return Singleton.sharedInstance
    }

}


