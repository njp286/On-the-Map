//
//  StudentInformation.swift
//  On the Map
//
//  Created by Nathaniel PiSierra on 4/7/16.
//  Copyright © 2016 Nathaniel PiSierra. All rights reserved.
//

import Foundation

class StudentInformation: NSObject {
    
    var studentInformationArray = [StudentInformationStruct]()
    
    class func sharedInstance() -> StudentInformation {
        
        struct Singleton {
            static var sharedInstance = StudentInformation()
        }
        
        return Singleton.sharedInstance
    }

}

struct StudentInformationStruct{
    //let objectId: String
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String
    let latitude: Double
    let longitude: Double
    
    init(dictionary: [String:AnyObject]) {
        //objectId = dictionary[ParseConstants.StudentLocationKeys.objectId] as! String
        uniqueKey = dictionary[ParseConstants.StudentLocationKeys.uniqueKey] as! String
        firstName = dictionary[ParseConstants.StudentLocationKeys.firstName] as! String
        lastName = dictionary[ParseConstants.StudentLocationKeys.lastName] as! String
        mapString = dictionary[ParseConstants.StudentLocationKeys.mapString] as! String
        mediaURL = dictionary[ParseConstants.StudentLocationKeys.mediaURL] as! String
        latitude = dictionary[ParseConstants.StudentLocationKeys.latitude] as! Double
        longitude = dictionary[ParseConstants.StudentLocationKeys.longitude] as! Double
    }

    
    static func arrayFromResults(results: [[String:AnyObject]], completionHandler: (error: String?) -> Void) {
        
        StudentInformation.sharedInstance().studentInformationArray.removeAll()
        
        for result in results {
            StudentInformation.sharedInstance().studentInformationArray.append(StudentInformationStruct(dictionary: result))
        }
        
        completionHandler(error: nil)
    }

}