//
//  DeviceDeterminer.swift
//  DiscountAsciiWarehouse
//
//  Created by Joel Nieman on 6/9/16.
//  Copyright © 2016 JoelNieman. All rights reserved.
//

import UIKit

// this is probably a long way to determine the iPhone device being used.
// this object is used to set the cell dimensions in the collection view so that the view is optimized by device.

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
            print("this is an iPhone 4 screen size or smalled")
            returnValue = 12
        }
        
        return returnValue
    }
}