//
//  CartViewController.swift
//  DiscountAsciiWarehouse
//
//  Created by Joel Nieman on 6/12/16.
//  Copyright © 2016 JoelNieman. All rights reserved.
//

import UIKit

class CartViewController: UIViewController {
    
    var cartItems = [Product]()

    override func viewDidLoad() {
        super.viewDidLoad()

        print("There are \(cartItems.count) items in your cart")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
