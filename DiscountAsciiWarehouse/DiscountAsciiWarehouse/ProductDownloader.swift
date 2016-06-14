//
//  ProductDownloader.swift
//  DiscountAsciiWarehouse
//
//  Created by Nieman, Joel (J.M.) on 6/8/16.
//  Copyright © 2016 JoelNieman. All rights reserved.
//

import Foundation

class ProductDownloader {
    
    
    private var collectionOfAllProducts = [Product]()
    var dnJson = NSData()
    var httpResponse: NSHTTPURLResponse?
    let handler: ProductResponseDelegate
    
    init(handler: ProductResponseDelegate) {
        self.handler = handler
    }

    
    func downloadProducts(limit: Int, skip: Int, search: String?) {
        
        var myArrayOfProducts:Array = [Product]()
        
        var myUrl = NSURL()
        
        if search != nil {
            myUrl = NSURL(string: "http://74.50.59.155:5000/api/search?limit=200&skip=0&q=\(search!)")!
            print("Making an api call for searched products")
        } else {
            myUrl = NSURL(string: "http://74.50.59.155:5000/api/search?limit=\(limit)&skip=\(skip)")!
            print("Making an api call for All products")
        }


        let session = NSURLSession.sharedSession()
        let task = session.downloadTaskWithURL(myUrl, completionHandler: {
            location, response, error in
            if let taskError = error {
                print("Task Error Domain is: \(taskError.domain)\n\nThe Error Code is: \(taskError.code)")
            } else {
                self.httpResponse = (response as! NSHTTPURLResponse)
                switch self.httpResponse!.statusCode {
                case 200:
                    do {
                        
                        // myArray is the returned json objects, separated by new line and cast as a string, and then collected in an array.
                        let jsonString:NSString = try NSString(contentsOfURL: location!, encoding: NSUTF8StringEncoding)
                        let myArray:[NSString] = jsonString.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
                        
                        if jsonString == "" {
                            dispatch_async(dispatch_get_main_queue()) {
                                
                                // if the json returned from the api call is empty, this sends the default last product object to the view controller
                                if search == nil || search == "" {
                                    let lastProduct = Product(type: "", id: "", size: 0, price: 0, face: "The End", stock: 0, tags: [], lastItem: true)
                                    
                                    self.handler.onResponse([lastProduct!], inStockProducts: [lastProduct!], searchedProducts: nil)
                                    print("All products jsonString is empty")
                                } else {
                                    let lastSearchedProduct = Product(type: "", id: "", size: 0, price: 0, face: "We don't sell those", stock: 0, tags: [], lastItem: true)
                                    self.handler.onResponse(nil, inStockProducts: nil, searchedProducts: [lastSearchedProduct!])
                                    print("Search products jsonString is empty")
                                }
                            }
                    
                        } else {
                            if search != nil {
                                self.parseJSON(myArray, productSearch: true)
                            } else {
                                self.parseJSON(myArray, productSearch: false)
                        }
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
    
    // function used to parse the retrieved json objects if the api call does not return an empty object.
    
    func parseJSON(array: NSArray, productSearch: Bool) {
        
        var products = [Product]()
        var inStockProducts = [Product]()
        var searchedProducts = [Product]()
        
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
                    
                    switch productSearch {
                    case false:
                        products.append(product)
                        if product.stock > 0 {
                            inStockProducts.append(product)
                        }
                        
                    default:
                        searchedProducts.append(product)
                    }
                    
                } catch {
//                    print("Error serializing JSON")
                }

            } else {
                print("Error encoding JSON")
            }
        }
        
        // gives the handler the retrieved and serialized products on the main thread.
        
        dispatch_async(dispatch_get_main_queue()) {
            self.handler.onResponse(products, inStockProducts: inStockProducts, searchedProducts: searchedProducts)
        }
    }
}

