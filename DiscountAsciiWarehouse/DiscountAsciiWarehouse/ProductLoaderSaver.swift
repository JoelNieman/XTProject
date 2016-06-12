//
//  ProductLoaderSaver.swift
//  DiscountAsciiWarehouse
//
//  Created by Joel Nieman on 6/11/16.
//  Copyright © 2016 JoelNieman. All rights reserved.
//

import Foundation

public class ProductLoaderSaver {

    
    
    // MARK: - NSCoding
    
    func saveProducts(products: [Product], inStockProducts: [Product]) {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(products, toFile: Product.allProductURL.path!) && NSKeyedArchiver.archiveRootObject(inStockProducts, toFile: Product.inStockURL.path!)
        
        if !isSuccessfulSave {
            print("Failed to save products")
        } else {
            print("Products saved successfully")
        }
        
    }
    
    func loadProducts() -> [[Product]]{
        print("loadProducts called")
        
        var allProducts = [Product]()
        var inStockProducts = [Product]()
        
        if let savedAllProducts = (NSKeyedUnarchiver.unarchiveObjectWithFile(Product.allProductURL.path!) as? [Product]){
                let products = savedAllProducts
                print("Loading \(products.count) saved all products!")
                //  print("\(self.products[0].face)")
                allProducts = products
        } else {
            allProducts = []
        }
        
        if let savedInStockProducts = (NSKeyedUnarchiver.unarchiveObjectWithFile(Product.inStockURL.path!) as? [Product]){
            let products = savedInStockProducts
            print("Loading \(products.count) saved inStock products!")
            //  print("\(self.products[0].face)")
            inStockProducts = products
        } else {
            allProducts = []
        }
        
        return[allProducts, inStockProducts]
    }
    
    
}