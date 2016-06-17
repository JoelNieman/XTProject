//
//  cartDelegate.swift
//  DiscountAsciiWarehouse
//
//  Created by Nieman, Joel (J.M.) on 6/13/16.
//  Copyright © 2016 JoelNieman. All rights reserved.
//

import Foundation

// This delegate is used to notify the ProductCollectionViewController of a change to the items in the cart if the user removes something while on the CartViewController.

protocol CartDelegate {
    func updateAndSaveCart(cart: [Product])
}
