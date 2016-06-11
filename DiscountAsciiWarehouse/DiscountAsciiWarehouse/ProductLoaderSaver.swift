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
    
    func saveProducts(products: [Product]) {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(products, toFile: Product.ArchiveURL.path!)
        
        if !isSuccessfulSave {
            print("Failed to save products")
        } else {
            print("Products saved successfully")
        }
        
    }
    
    func loadProducts() -> [Product]{
        print("loadProducts called")
        
        if let savedProducts = (NSKeyedUnarchiver.unarchiveObjectWithFile(Product.ArchiveURL.path!) as? [Product]){
                let products = savedProducts
                print("Loading saved products!")
                //  print("\(self.products[0].face)")
                return products
                
            
        } else {
            return []
        }
    }
    
    
}