//
//  ProductResponseDelegate.swift
//  DiscountAsciiWarehouse
//
//  Created by Nieman, Joel (J.M.) on 6/8/16.
//  Copyright © 2016 JoelNieman. All rights reserved.
//

import Foundation

// This is used to update the UI upon completion of parsing retrieved json

protocol ProductResponseDelegate {
    func onResponse(products: [Product]?, inStockProducts: [Product]?, searchedProducts: [Product]?, sort: Bool)
    func apiCallsEnabled(enabled: Bool) -> Bool
    func serverError()
}