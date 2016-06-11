//
//  ProductResponseDelegate.swift
//  DiscountAsciiWarehouse
//
//  Created by Nieman, Joel (J.M.) on 6/8/16.
//  Copyright © 2016 JoelNieman. All rights reserved.
//

import Foundation

@objc protocol ProductResponseDelegate {
    optional func onResponse(products: [Product])
}