//
//  CustomCell.swift
//  DiscountAsciiWarehouse
//
//  Created by Nieman, Joel (J.M.) on 6/9/16.
//  Copyright © 2016 JoelNieman. All rights reserved.
//

import UIKit

// This is my custom cell object.
// bounds is used to ensure the faces are placed exactly in the middle of the cell.

class CustomCell: UICollectionViewCell {
    
    @IBOutlet weak var face: UILabel!
    @IBOutlet weak var quantity: UILabel!
    @IBOutlet weak var size: UILabel!
    
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }
}

