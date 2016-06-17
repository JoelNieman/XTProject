//
//  ProductLoaderSaver.swift
//  DiscountAsciiWarehouse
//
//  Created by Joel Nieman on 6/11/16.
//  Copyright © 2016 JoelNieman. All rights reserved.
//

import Foundation

// This object is used to save retrieved products to the directory set up for them and also load them later if necessary.
// This is part of the NSCoding protocol implementation.

public class ProductLoaderSaver {

    
    
    // MARK: - NSCoding
    
    func saveProducts(products: [Product]) {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(products, toFile: Product.allProductURL.path!)
        
        if !isSuccessfulSave {
            print("Failed to save products")
        } else {
            print("Products saved successfully")
        }
        
    }
    
    func saveCart(cart: [Product]) {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(cart, toFile: Product.cartURL.path!)
        
        if !isSuccessfulSave {
            print("Failed to save cart")
        } else {
            print("Cart saved successfully")
        }

    }
    
    func loadProducts() -> [[Product]] {
        print("loadProducts called")
        
        var allProducts = [Product]()
        
        
        if let savedAllProducts = (NSKeyedUnarchiver.unarchiveObjectWithFile(Product.allProductURL.path!) as? [Product]){
            let products = savedAllProducts
            print("Loading \(products.count) saved all products!")
            allProducts = products
        } else {
            allProducts = []
        }
        
        return [allProducts]
    }
    
    func loadCart() -> [[Product]] {
        
        var cartProducts = [Product]()
        
        if let savedCart = (NSKeyedUnarchiver.unarchiveObjectWithFile(Product.cartURL.path!) as? [Product]){
            let cart = savedCart
            print("Loading \(cart.count) saved cart products!")
            cartProducts = cart
        } else {
            cartProducts = []
        }
        
        return[cartProducts]
    }
    
}