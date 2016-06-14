//
//  ProductCollectionViewController.swift
//  DiscountAsciiWarehouse
//
//  Created by Nieman, Joel (J.M.) on 6/9/16.
//  Copyright © 2016 JoelNieman. All rights reserved.
//

import UIKit
import Social

// This is where all the magic happens!

class ProductCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, ProductResponseDelegate, CartDelegate {
    
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var productCollectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var productPreview: UIView!
    @IBOutlet weak var productPreviewFace: UILabel!
    @IBOutlet weak var priceOutlet: UILabel!
    @IBOutlet weak var quantityOutlet: UILabel!
    @IBOutlet weak var buyNowButton: UIButton!

    
    private var productDownloader: ProductDownloader?
    private var products = [Product]()
    private var inStockProducts = [Product]()
    private var searchedProducts = [Product]()
    private var cart = [Product]()
    private var product = Product()
    private var loadedProducts:[Product]?
    private var productCount:Int!
    private var searchTag: String?
    private var searchTagForURL: String!
    
    private let leftAndRightPaddings:CGFloat = 24.0
    private let numberOfItemsInRow:CGFloat = 3.0
    private let heightAdjustment:CGFloat = 30.0
    private var screenWidth:CGFloat!
    private var screenHeight:CGFloat!
    private var cellWidth:CGFloat!
    private var cellHeight:CGFloat!
    private var device:NSString!
    private let deviceDeterminer = DeviceDeterminer()
    private var numberOfCells:Int!
    private var scrollTriggerDistanceFromBottom:CGFloat = 1
    private var minimumTrigger:CGFloat!
    private var localStorage:NSUserDefaults!
    private var savedProducts = [Product]()
    private var timeSinceLastDownload: CFAbsoluteTime!
    private var date:CFAbsoluteTime!
    private let productLoaderSaver = ProductLoaderSaver()
    private var scrollView:UIScrollView!
    
    private var activityIndicator: UIActivityIndicatorView!
    private var cartViewController: CartViewController!
    
    

    
    
    
    
    // MARK: - VC life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchBar.delegate = self
        setGroceryCartButton(self.cart.count)
        
        calculateCellDimensions()
        
        productDownloader = ProductDownloader(handler: self)
        
        timeSinceLastDownload = readAndSetTime()
        determineDownloadOrLoad()
        
        print("loaded \(self.products.count) products")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
        productCollectionView.scrollEnabled = true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    // MARK: - API Call Protocol OnResponse method.
    
    func onResponse(retrievedProducts: [Product]?, inStockProducts: [Product]?, searchedProducts: [Product]?) {
        
        handleAllProducts(retrievedProducts)
        handleInStockProducts(inStockProducts)
        handleSearchedProducts(searchedProducts)

        productCount = self.products.count
        
        self.productCollectionView.reloadData()
        activityIndicator.stopAnimating()
        
        setMinimumTrigger()
        
        productLoaderSaver.saveProducts(self.products)
        
        self.productCollectionView.reloadData()
        
        segmentedControl.userInteractionEnabled = true
        
        if self.products.count == numberOfCells {
            localStorage.setObject(date, forKey:"timeOfLastDownload")
        }

        print("The current product count is \(productCount)")
    }
    
    
    // this checks to see if the handler is giving it products that were searched for
    // if true it puts them in the searchedProducts collection and moves the user to the search tab.
    func handleSearchedProducts(searchedProducts: [Product]?) {
        if let mySearchedProducts = searchedProducts {
            if mySearchedProducts.count > 0{
                self.searchedProducts += mySearchedProducts
                segmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
                segmentedControl.selectedSegmentIndex = 2
                print("adding \(searchedProducts!.count) products to searchedProducts")
                print("There are now \(self.searchedProducts.count) searched products")
            } else {
                print("nothing to add to searched products")
                }
            }
        }
    
        // this logic handles the products retrieved that are currently in stock.
        func handleInStockProducts(inStockProducts: [Product]?){
            if let myInStockProducts = inStockProducts {
                self.inStockProducts += myInStockProducts
                print("adding \(myInStockProducts.count) products to inStockProducts")
                print("There are now \(self.inStockProducts.count) inStock products")
            } else {
                print("nothing to add to inStock products")
            }
        }
        
        // this logic handles all products recieved.
        func handleAllProducts(retrievedProducts: [Product]?) {
            if let myRetrievedProducts = retrievedProducts {
                self.products += myRetrievedProducts
                print("adding \(myRetrievedProducts.count) products to allProducts")
                print("There are now \(self.products.count) products")
            } else {
                print("nothing to add to searched products")
            }
        }
    
    // MARK: - UICollectionViewMethods
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var numberOfCells = Int()
        
        if segmentedControl.selectedSegmentIndex == 0 {
            numberOfCells = self.products.count
        } else if segmentedControl.selectedSegmentIndex == 1 {
            numberOfCells = self.inStockProducts.count
        } else {
            numberOfCells = self.searchedProducts.count
        }
        
        return numberOfCells
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ProductCell", forIndexPath: indexPath) as! CustomCell
        
        var productForCell = determineProductToUse(indexPath.row)
        
        cell.face.text = productForCell.face
        cell.face.adjustsFontSizeToFitWidth = true
        
        if productForCell.stock > 0 {
            cell.quantity.text = "Only \(productForCell.stock) left"
        } else {
            cell.quantity.text = "Sold out!"
        }
        
        if productForCell.lastItem == true {
            cell.quantity.text = ""
        }

        formatCellDimensions()
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        var productForCell = determineProductToUse(indexPath.row)
        self.product = productForCell
        
        productPreviewFace.text = productForCell.face
        productPreviewFace.adjustsFontSizeToFitWidth = true
        priceOutlet.text = "$\(Int(productForCell.price))"
        
        if productForCell.stock > 0 {
            quantityOutlet.text = "Only \(productForCell.stock) left!"
        } else {
            quantityOutlet.text = "Out of stock"
        }
        
        buyNowButton.hidden = false
        
        if productForCell.lastItem != true {
            productPreview.hidden = false
            if productForCell.stock == 0 {
                buyNowButton.hidden = true
            }
        } else {
            productPreview.hidden = true
        }
        
    }

    // This function sets the product appropriately based on the collection being viewed.
    
    func determineProductToUse(indexPath: Int) -> Product {
        var productForCell = Product()
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            productForCell = self.products[indexPath]
        case 1:
            productForCell = self.inStockProducts[indexPath]
        case 2:
            productForCell = self.searchedProducts[indexPath]
        default:
            print("Error populating collection view cells")
        }
        
        return productForCell

    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.scrollView = scrollView
        
        if segmentedControl.selectedSegmentIndex != 2 && products.last?.lastItem != true {
            enableScrollToLoad()
        }
    }
    
    // This function handles enabling the scroll to load more functionality
    
    func enableScrollToLoad() {
    
        if scrollView.contentSize.height > minimumTrigger {
            let distanceFromBottom = scrollView.contentSize.height - (scrollView.bounds.size.height - scrollView.contentInset.bottom) - scrollView.contentOffset.y
            if distanceFromBottom < self.scrollTriggerDistanceFromBottom {
                scrollView.scrollEnabled = false
                fetchProducts(30, countOfCollection: self.products.count, searched: nil)
                print("Fetching 30 products")
                print("Skipping \(self.products.count)")
                }
            }
        }
    
    // This function sets the distance to the bottom of the screen that is used to trigger an action.
    
    func setMinimumTrigger() {
        minimumTrigger = productCollectionView.bounds.size.height + scrollTriggerDistanceFromBottom
        productCollectionView.scrollEnabled = true
    }


    
    // This is the api call function

    func fetchProducts(numberOfProducts: Int, countOfCollection: Int, searched: String?) {
        startActivityIndicator()
        segmentedControl.userInteractionEnabled = false
        productDownloader?.downloadProducts(numberOfProducts, skip: countOfCollection, search: searched)
    }
    
    // These functions formats the cell size based on the iPhone screen size
    
    func formatCellDimensions(){
        let layout = productCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSizeMake(cellWidth, cellWidth + heightAdjustment)
    }
    
    func calculateCellDimensions() {
        screenWidth = UIScreen.mainScreen().bounds.width
        screenHeight = UIScreen.mainScreen().bounds.height
        
        cellWidth = ((screenWidth - 16) - leftAndRightPaddings) / numberOfItemsInRow
        cellHeight = (screenWidth + 30)
        
        numberOfCells = deviceDeterminer.determineNumberOfCells(screenHeight)
    }
    
    
    @IBAction func segmentedControlPressed(sender: AnyObject) {
        searchBar.text = nil
        productCollectionView.reloadData()
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            print("There are \(self.products.count) products on this tab")
        case 1:
            print("There are \(self.inStockProducts.count) inStock products on this tab")
        default:
            print("There are \(self.searchedProducts.count) searched products on this tab")
        }
        
        productPreview.hidden = true
    }
    
    
    // This function puts the activitiy indicator in view and starts the animation.
    
    func startActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: activityIndicator)
    }
    
    // This function manages the pictures used for the grocery cart.
    
    func setGroceryCartButton(countOfProducts: Int) {
        var cartImage = String()
        switch self.cart.count {
        case 0:
            cartImage = "Cart0"
        case 1:
            cartImage = "Cart1"
        case 2:
            cartImage = "Cart2"
        case 3:
            cartImage = "Cart3"
        default:
            cartImage = "Cartplus"
        }
        
        
        let groceryCartImage = UIImage(named: cartImage)?.imageWithRenderingMode(.AlwaysOriginal)
        let groceryCartButton: UIButton = UIButton(type: UIButtonType.Custom)
        groceryCartButton.setImage((groceryCartImage), forState: UIControlState.Normal)
        groceryCartButton.addTarget(self, action: "groceryCartButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        groceryCartButton.frame = CGRectMake(0, 0, 30, 30)
        
        let barButton = UIBarButtonItem(customView: groceryCartButton)
        self.navigationItem.rightBarButtonItem = barButton
        
        
    }
    
    
    // MARK: - Search functionality
    
    internal func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        self.searchBar.showsCancelButton = true
        
        return true
    }
    
    internal func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchedProducts = []
        
        
        searchTag = searchBar.text?.lowercaseString
        searchTagForURL = searchTag?.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        print("Fetching searched products")
        fetchProducts(0, countOfCollection: 0, searched: searchTagForURL)
        
        self.searchBar.showsCancelButton = false
        self.searchBar.resignFirstResponder()
        
        self.productCollectionView.reloadData()
    }
    
    internal func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = false
        self.searchBar.resignFirstResponder()
    }
    
    // MARK: - Timer for product caching
    
    // This function takes a reading on the current time and stores it to the NSUserDefaults for reading later.
    // If there aleady is a time stored, it will measure the time since the previous time was set.
    
    func readAndSetTime() -> Double {
        localStorage = NSUserDefaults.standardUserDefaults()
        
        var time: Double!
        date = CFAbsoluteTimeGetCurrent()
        
        if localStorage.objectForKey("timeOfLastDownload") == nil {
            localStorage.setObject(date, forKey:"timeOfLastDownload")
            print("setting time \(date) to userDefualts")
            time = 0.0

        } else {
            let timeOfLastDownload = localStorage.objectForKey("timeOfLastDownload") as! CFAbsoluteTime
            let timeInterval = CFTimeInterval(date - timeOfLastDownload)
            let timeIntervalInMinutes = Int(timeInterval) / 3600

            print("it has been \(timeIntervalInMinutes) minutes since the last download")
            time = timeInterval
        }
        
        return time
    }
    
    // This function determines if a new download is necessary based on the time passed since the last download
    // If a new download is not necessary, it loads the previously retrieved products from the archive directory.
    
    func determineDownloadOrLoad() {
        if self.timeSinceLastDownload >= 60.0 {
            self.products = []
            print("It about time for some new products!")
            
            let savedCart = productLoaderSaver.loadCart()
            self.cart = savedCart[0]

            fetchProducts(numberOfCells, countOfCollection: products.count, searched: nil)
        } else {
            let savedProducts = productLoaderSaver.loadProducts()
            self.products = savedProducts[0]
            
            let savedCart = productLoaderSaver.loadCart()
            self.cart = savedCart[0]
            
            
            addInStockProducts(self.products)
            
            if self.products == [] {
            fetchProducts(numberOfCells, countOfCollection: products.count, searched: nil)
            print("No saved products. Fetching some for you")
            }
            self.productCollectionView.scrollEnabled = false
        }
        setGroceryCartButton(cart.count)
        
    }
    
    func groceryCartButtonPressed() {
        if cart.count > 0 {
            performSegueWithIdentifier("segueToCart", sender: nil)
        }
    }
    
    // This function sends the CartViewController the current cart collection and sets the delegate for returning an updated cart
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueToCart" {
            cartViewController = segue.destinationViewController as! CartViewController
            cartViewController.handler = self
            cartViewController.cartItems = cart
            
        }
    }
    
    // This function iterates over the products recieved and puts all inStock products in the inStockProducts collection.
    
    func addInStockProducts(allProducts: [Product]) {
        for product in allProducts{
            if product.stock > 0 {
                inStockProducts.append(product)
            }
        }
    }

    @IBAction func closeButtonPressed(sender: AnyObject) {
        productPreview.hidden = true
    }
    
    // This adds an item to the cart.
    
    @IBAction func addToCartButtonPressed(sender: AnyObject) {
        self.cart.append(self.product)
        productPreview.hidden = true
        setGroceryCartButton(self.cart.count)
        print("There is now \(self.cart.count) product(s) in your cart")
        productLoaderSaver.saveCart(self.cart)
    }
    
    // this function is used to update the cart image and save the cart products when a product is added to the cart.
    
    func updateAndSaveCart(cart: [Product]) {
        self.cart = cart
        setGroceryCartButton(cart.count)
        productLoaderSaver.saveCart(self.cart)
        print("There are now \(self.cart.count) products saved for later")
    }
    
    // This is the logic for the facebook button
    
    @IBAction func facebookButtonPressed(sender: AnyObject) {
        
        //  Check if Facebook is available, otherwise display an error message
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
            //  Display Facebook Composer
            let facebookComposer = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            
            //  Set initial text for facebook has been disabled due to FB policy.
            facebookComposer.setInitialText("Check out this product and more on the new  Discount Ascii Warehouse iOS app!\n\n\(self.product.face)")
            
            self.presentViewController(facebookComposer, animated: true, completion: nil)
    
            return
        } else {
            let alertMessage = UIAlertController(title: "Facebook Unavailable", message: "You haven't registered your Facebook account. Please go to Settings > Facebook to create one.", preferredStyle: .Alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alertMessage, animated: true, completion: nil)
            
            return
        }
        
    }
    
}


