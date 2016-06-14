//
//  CartViewController.swift
//  DiscountAsciiWarehouse
//
//  Created by Joel Nieman on 6/12/16.
//  Copyright © 2016 JoelNieman. All rights reserved.
//

import UIKit
import Foundation

class CartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var cartTableView: UITableView!
    @IBOutlet weak var cartTotalLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var buyNowButton: UIButton!
    
    var cartItems = [Product]()
    var cartTotal = Int()
    
    var handler: CartDelegate!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        print("There are \(cartItems.count) items in your cart")
        updateCartTotal(self.cartItems)
        
        cartTableView.rowHeight = 60
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        cartTotalLabel.text = "$\(cartTotal).00"
        totalPriceLabel.hidden = false
    }
    
    
    // MARK: - TableView DataSource and Delegate Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("CartProductCell", forIndexPath: indexPath) as! CustomTableViewCell
        
        cell.faceOutlet.text = cartItems[indexPath.row].face
        cell.priceOutlet.text = "$\(Int(cartItems[indexPath.row].price))"
        
        return cell
    }
    
    // This code allows the user to swipe and delete items from the cart.
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        let removeAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Remove", handler: { (action:UITableViewRowAction, indexPath:NSIndexPath) -> Void in
            
            self.cartItems.removeAtIndex(indexPath.row)
            self.updateCartTotal(self.cartItems)
            self.cartTableView.reloadData()
            

            self.handler.updateAndSaveCart(self.cartItems)
            

        })
        return [removeAction]
    }

    // This function updated the cart total price
    
    func updateCartTotal(cart: [Product]){
        self.cartTotal = 0
        for item in cartItems {
            self.cartTotal += Int(item.price)
        }
        cartTotalLabel.text = "$\(self.cartTotal).00"
    }
    @IBAction func buyNowButtonPressed(sender: AnyObject) {
        
        if self.cartItems.count > 0 {
            let alertController = UIAlertController(title: "Thank You!", message:
                "Your order hase been placed", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default) { (action) in
                self.cartItems = []
                self.handler.updateAndSaveCart(self.cartItems)
                self.cartTableView.reloadData()
                self.updateCartTotal(self.cartItems)
                });
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
    }
    
}
