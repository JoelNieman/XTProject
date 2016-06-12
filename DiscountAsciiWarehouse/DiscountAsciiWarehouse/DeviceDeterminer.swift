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
            print("This is an iPhone 6 Plus screen size")
            returnValue = 18
        } else if (screenHeight > 650) {
            print("This is an iPhone 6 screen size")
            returnValue = 15
        } else if (screenHeight > 550) {
            print("this is an iPhone 5 screen size")
            returnValue = 15
        } else if (screenHeight > 450) {
            print("this is an iPhone 4 screen size")
            returnValue = 9
        } else {
            print("This is an iPhone 3 or earlier")
            returnValue = 8
        }
        return returnValue
    }
}