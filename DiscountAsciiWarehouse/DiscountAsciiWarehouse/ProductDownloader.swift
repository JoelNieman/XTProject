//
//  ProductDownloader.swift
//  DiscountAsciiWarehouse
//
//  Created by Nieman, Joel (J.M.) on 6/8/16.
//  Copyright © 2016 JoelNieman. All rights reserved.
//

import Foundation

class ProductDownloader {
    
    var products:Array = [Product]();
    var dnJson = NSData()
    var httpResponse: NSHTTPURLResponse?
    private let lastProduct = Product(face: ":(", lastItem: true)
    
    let handler: ProductResponseDelegate
    init(handler: ProductResponseDelegate) {
        self.handler = handler
    }

    
    func downloadProducts(limit: Int, skip: Int) {
        
        var myArrayOfProducts:Array = [Product]()
        let url = NSURL(string: "http://74.50.59.155:5000/api/search?limit=\(limit)&skip=\(skip)")
//        let url = NSURL(string: "http://74.50.59.155:5000/api/search?limit=1&skip=0")
        let session = NSURLSession.sharedSession()
        let task = session.downloadTaskWithURL(url!, completionHandler: {
            location, response, error in
            if let taskError = error {
                print("Task Error Domain is: \(taskError.domain)\n\nThe Error Code is: \(taskError.code)")
            } else {
                self.httpResponse = (response as! NSHTTPURLResponse)
                switch self.httpResponse!.statusCode {
                case 200:
//                    print("Got 200")
//                    print("The retrieved data is: \n\n \(location!)")
                    
                    do {
                        let jsonString:NSString = try NSString(contentsOfURL: location!, encoding: NSUTF8StringEncoding)
                        let myArray:[NSString] = jsonString.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
                        
                        if jsonString == "" {
                            dispatch_async(dispatch_get_main_queue()) {
                                print("jsonString is empty")
                                var lastProductCollection = [Product]()
                                lastProductCollection.append(self.lastProduct)
                                self.handler.onResponse!(lastProductCollection)
                            }
                        } else {
                            self.parseJSON(myArray)
                        }
                        
                        
                    } catch {
                        print("error converting url to NSString")
                    }
                    
                default:
                    print("Request failed: \(self.httpResponse!.statusCode)")
                }
            }
        })
        
        task.resume()
        
    }
    
    func parseJSON(array: NSArray) {
        
        var productArray = [Product]()
        
        for json in array {
            
            let product = Product()
            
            if var jsonData:NSData = json.dataUsingEncoding(NSUTF8StringEncoding) {
                
                do {
                
                    let serializedJSON: NSDictionary?  = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments) as! NSDictionary
                    
                        if (serializedJSON!.objectForKey("type") != nil) {
                            product.type = (serializedJSON!.objectForKey("type") as! String)
                        } else { print("there is no value for key: type") }
                        
                    
                        if (serializedJSON!.objectForKey("id") != nil) {
                            product.id = (serializedJSON!.objectForKey("id") as! String)
                        } else { print("there is no value for key: id") }
                    
                    
                        if (serializedJSON!.objectForKey("size") != nil) {
                            product.size = (serializedJSON!.objectForKey("size")!.integerValue)
                        } else { print("there is no value for key: size") }
                    
                    
                        if (serializedJSON!.objectForKey("price") != nil) {
                            product.price = (serializedJSON!.objectForKey("price") as! Double)
                        } else { print("there is no value for key: price") }
                    
                    
                        if (serializedJSON!.objectForKey("face") != nil) {
                            product.face = (serializedJSON!.objectForKey("face") as! String)
                        } else { print("there is no value for key: face") }
                    
                    
                        if (serializedJSON!.objectForKey("stock") != nil) {
                            product.stock = (serializedJSON!.objectForKey("stock")!.integerValue)
                        } else { print("there is no value for key: stock") }
                    
                    
                        if (serializedJSON!.objectForKey("tags") != nil) {
                            product.tags = (serializedJSON?.objectForKey("tags")! as! [String])
                        } else { print("there are no values for key: tags") }
                    
                        product.lastItem = false

//                        print("The type is : \(product.type)")
//                        print("The id is   : \(product.id)")
//                        print("The size is : \(product.size)")
//                        print("The price is: \(product.price)")
//                        print("\(product.face)")
//                        print("The stock is: \(product.stock)")
//                        print("The tags are: \(product.tags)")
                    
                        productArray.append(product)
                    
                } catch {
//                    print("Error serializing JSON")
                }

            }else {
                print("Error encoding JSON")
            }
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            self.handler.onResponse!(productArray)
        }
    }
}

