//
//  ConnectionChecker.swift
//  DiscountAsciiWarehouse
//
//  Created by Nieman, Joel (J.M.) on 6/15/16.
//  Copyright © 2016 JoelNieman. All rights reserved.
//

import Foundation
import SystemConfiguration
//
public class ConnectionChecker {
    
    let handler: ConnectionCheckerDelegate
    init(handler: ConnectionCheckerDelegate) {
        self.handler = handler
    }

    func checkConnection() {
        var myUrl = NSURL(string: "https://www.google.com")
    
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(myUrl!, completionHandler: {
            location, response, error in
            if let taskError = error {
                dispatch_async(dispatch_get_main_queue()) {
                    self.handler.connectionTest(false)
                }
                print("Task Error Domain is: \(taskError.domain)\n\nThe Error Code is: \(taskError.code)")
            } else {
                let httpResponse = (response as! NSHTTPURLResponse)
                switch httpResponse.statusCode {
                case 200:
                    dispatch_async(dispatch_get_main_queue()) {
                        self.handler.connectionTest(true)
                    }
                default:
                    dispatch_async(dispatch_get_main_queue()) {
                        self.handler.connectionTest(false)
                    }
                    print("Request failed: \(httpResponse.statusCode)")
                }
            }
        })
    
        task.resume()
        
        
    }
}
