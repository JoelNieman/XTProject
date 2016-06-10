//
//  DeviceDeterminer.swift
//  DiscountAsciiWarehouse
//
//  Created by Joel Nieman on 6/9/16.
//  Copyright © 2016 JoelNieman. All rights reserved.
//

import UIKit

public class DeviceDeterminer {
    
    func determineNumberOfCells(screenHeight: CGFloat) -> Int {
        
        var returnValue = 0
        
        if (screenHeight > 700) {
            print("This is a 6 Plus")
            returnValue = 18
        } else if (screenHeight > 650) {
            print("This is a 6")
            returnValue = 15
        } else if (screenHeight > 550) {
            print("this is a 5")
            returnValue = 15
        } else if (screenHeight > 450) {
            print("this is a 4")
            returnValue = 9
        } else {
            print("This is a 3 or eaarlier")
            returnValue = 8
        }
        return returnValue
    }
}