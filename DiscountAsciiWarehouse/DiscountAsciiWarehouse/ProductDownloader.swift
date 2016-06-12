//
//  ProductDownloader.swift
//  DiscountAsciiWarehouse
//
//  Created by Nieman, Joel (J.M.) on 6/8/16.
//  Copyright © 2016 JoelNieman. All rights reserved.
//

import Foundation

class ProductDownloader {
    
    
//    var searchedProducts = [Product]()
    var dnJson = NSData()
    var httpResponse: NSHTTPURLResponse?
    private let lastProduct = Product(face: ":(", lastItem: true)
    
    let handler: ProductResponseDelegate
    init(handler: ProductResponseDelegate) {
        self.handler = handler
    }

    
    func downloadProducts(limit: Int, skip: Int, inStock: Int, search: String?) {
        
        var myArrayOfProducts:Array = [Product]()
        
        var myUrl = NSURL()
        
        if search != nil {
            myUrl = NSURL(string: "http://74.50.59.155:5000/api/search?limit=200&skip=0&q=\(search!)")!
            print(myUrl)
            print("Making an api call for searched products")
        } else if inStock == 0 {
            myUrl = NSURL(string: "http://74.50.59.155:5000/api/search?limit=\(limit)&skip=\(skip)")!
            print("Making an api call for All products")
            print(myUrl)
        } else if inStock == 1{
            myUrl = NSURL(string: "http://74.50.59.155:5000/api/search?limit=\(limit)&skip=\(skip)&onlyInStock=true")!
            print("Making an api call for inStock products")
            print(myUrl)
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
//                    print("Got 200")
//                    print("The retrieved data is: \n\n \(location!)")
                    
                    do {
                        let jsonString:NSString = try NSString(contentsOfURL: location!, encoding: NSUTF8StringEncoding)
                        let myArray:[NSString] = jsonString.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
                        
                        if jsonString == "" {
                            dispatch_async(dispatch_get_main_queue()) {
                                
                                if inStock == 0 {
                                    if search == nil {
                                        
                                        print("All products jsonString is empty")
                                        var lastProductCollection = [Product]()
                                        lastProductCollection.append(self.lastProduct)
                                        self.handler.onResponse(lastProductCollection, inStockProducts: nil, searchedProducts: nil)
                    
                                    } else {
                                        print("Search products jsonString is empty")
                                        var lastProductCollection = [Product]()
                                        lastProductCollection.append(self.lastProduct)
                                        self.handler.onResponse(nil, inStockProducts: nil, searchedProducts: lastProductCollection)
                                    }
                                    
                                } else if inStock == 1 {
                                    print("In Stock products jsonString is empty")
                                    var lastInStockProductCollection = [Product]()
                                    lastInStockProductCollection.append(self.lastProduct)
                                    self.handler.onResponse(nil, inStockProducts: lastInStockProductCollection, searchedProducts: nil)
                                } else {
                                    print("Error appending last item to collection")
                                }
                            }
                        } else {
                            switch inStock {
                            case 0:
                                if search != nil {
                                    self.parseJSON(myArray, inStock: false, productSearch: true)
                                } else {
                                    self.parseJSON(myArray, inStock: false, productSearch: false)
                                }
                        
                            
                            case 1:
                                self.parseJSON(myArray, inStock: true, productSearch: false)
                            
                            default:
                                print("error handing json array to json parser")
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
    
    func parseJSON(array: NSArray, inStock: Bool, productSearch: Bool) {
        
        var products:Array = [Product]()
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

//                        print("The type is : \(product.type)")
//                        print("The id is   : \(product.id)")
//                        print("The size is : \(product.size)")
//                        print("The price is: \(product.price)")
//                        print("\(product.face)")
//                        print("The stock is: \(product.stock)")
//                        print("The tags are: \(product.tags)")
                    
                    switch inStock {
                    case false:
                        if productSearch == true {
                            searchedProducts.append(product)
                        } else {
                            products.append(product)
                            
                            if product.stock > 0 {
                                inStockProducts.append(product)
                                }
                        }
                    case true:
                            inStockProducts.append(product)
                            
                    default:
                        print("Error adding products to collections")
                    }
                    
                } catch {
//                    print("Error serializing JSON")
                }

            }else {
                print("Error encoding JSON")
            }
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            self.handler.onResponse(products, inStockProducts: inStockProducts, searchedProducts: searchedProducts)
        }
    }
}

