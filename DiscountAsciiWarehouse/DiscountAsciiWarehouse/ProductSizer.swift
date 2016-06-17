//
//  ProductSizer.swift
//  DiscountAsciiWarehouse
//
//  Created by Nieman, Joel (J.M.) on 6/15/16.
//  Copyright © 2016 JoelNieman. All rights reserved.
//

import Foundation

class ProductSizer {
    
    
    
    func setProductSize(size:Int) -> String {
        
        var returnSize:String!
        
        if size > 40 {
            returnSize = "XL"
        } else if size > 30 {
            returnSize = "L"
        } else if size > 20 {
            returnSize = "M"
        } else if size > 0{
            returnSize = "S"
        } else {
            returnSize = ""
        }
        
        return returnSize
    }
    
    func setFaceSize(productSize: String) -> Int {
        var faceSize: Int!
        
        switch productSize {
        case "XL":
            faceSize = 50
        case "L":
            faceSize = 35
        case "M":
            faceSize = 25
        default:
            faceSize = 15
        }
        return faceSize
    }
    
}
