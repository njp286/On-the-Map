//
//  ParseClient.swift
//  On the Map
//
//  Created by Nathaniel PiSierra on 4/7/16.
//  Copyright © 2016 Nathaniel PiSierra. All rights reserved.
//

import Foundation

class ParseClient: NSObject{
    
    var objectID : String! = nil
    let session = UdacityClient.sharedInstance().session
 
    func getStudentLocations(completionHandler: (error: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation?limit=100&order=-updatedAt")!)
        request.addValue(ParseConstants.Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ParseConstants.Constants.APIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
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
            
            //Parse the data
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            guard let results: AnyObject! = parsedResult["results"]  else {
                displayError("Cannot find results")
                return
            }
            
            StudentInformationStruct.arrayFromResults(results as! [[String: AnyObject]]){ (error) in
                if (error == nil){
                    completionHandler(error: nil)
                }
                else{
                    completionHandler(error: error)
                }
            }
            
        }
        task.resume()
       
    }
    
    func postStudentLocation(object: StudentInformationStruct, completionHandler:(error:String?) -> Void) {
        
        var jsonBody = [String : AnyObject]()
        jsonBody[ParseConstants.StudentLocationKeys.uniqueKey] = object.uniqueKey
        jsonBody[ParseConstants.StudentLocationKeys.firstName] = object.firstName
        jsonBody[ParseConstants.StudentLocationKeys.lastName] = object.lastName
        jsonBody[ParseConstants.StudentLocationKeys.mapString] = object.mapString
        jsonBody[ParseConstants.StudentLocationKeys.mediaURL] = object.mediaURL
        jsonBody[ParseConstants.StudentLocationKeys.latitude] = object.latitude
        jsonBody[ParseConstants.StudentLocationKeys.longitude] = object.longitude
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.HTTPMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
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
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            //Parse the data
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            guard let objectID: String! = parsedResult[ParseConstants.StudentLocationKeys.objectId] as! String else {
                displayError("Cannot find objectID")
                return
            }
            
            self.objectID = objectID
            completionHandler(error: nil)

        }
        task.resume()
    }
    
    
    
    class func sharedInstance() -> ParseClient {
        
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        
        return Singleton.sharedInstance
    }
    
    
}