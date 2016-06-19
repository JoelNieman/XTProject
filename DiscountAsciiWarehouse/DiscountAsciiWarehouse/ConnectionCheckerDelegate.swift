//
//  ConnectionCheckerDelegate.swift
//  DiscountAsciiWarehouse
//
//  Created by Joel Nieman on 6/18/16.
//  Copyright © 2016 JoelNieman. All rights reserved.
//

import Foundation

protocol ConnectionCheckerDelegate {
    func connectionTest(connection: Bool)
}