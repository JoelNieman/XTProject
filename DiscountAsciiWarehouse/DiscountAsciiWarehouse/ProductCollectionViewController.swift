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

class ProductCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, ProductResponseDelegate, CartDelegate, ConnectionCheckerDelegate {
    
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var productCollectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var productPreview: UIView!
    @IBOutlet weak var productPreviewFace: UILabel!
    @IBOutlet weak var priceOutlet: UILabel!
    @IBOutlet weak var quantityOutlet: UILabel!
    @IBOutlet weak var buyNowButton: UIButton!
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var priceButton: UIButton!
    @IBOutlet weak var sizeButton: UIButton!
    @IBOutlet weak var quantityButton: UIButton!
    @IBOutlet weak var sortedByButton: UILabel!
    
    
    private var productDownloader: ProductDownloader?
    private var products: [Product] = []
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
    private var collectionViewHeight:CGFloat!
    private var localStorage:NSUserDefaults!
    private var savedProducts = [Product]()
    private var timeSinceLastDownload: CFAbsoluteTime!
    private var date:CFAbsoluteTime!
    private let productLoaderSaver = ProductLoaderSaver()
    private var scrollView:UIScrollView!
    private var apiCalls = true
    private var productSizer = ProductSizer()
    private var sortLabelText: String!
    private var sortedBy: String!
    private var sortMode = "Descending"
    private var connection = true
    private var connectionAlertShown = false
    private var initialLoad = true
    
    private var activityIndicator: UIActivityIndicatorView!
    private var cartViewController: CartViewController!
    
    


    // MARK: - VC life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialLoad == true
        
        self.searchBar.delegate = self
        setGroceryCartButton(self.cart.count)
        
        calculateCellDimensions()
        
        productDownloader = ProductDownloader(handler: self)
        
        setActivityIndicator()
        
        if products.count > numberOfCells {
            reloadAndResetCollectionView()
        }
        
        print("loaded \(self.products.count) products")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
        productCollectionView.scrollEnabled = true
        ConnectionChecker(handler: self).checkConnection()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    func connectionTest(connection: Bool) {
        self.connection = connection
    
        // In the case that the connection test failed and the user has not yet been informed they are without connection, alert them.
        if connection == false && connectionAlertShown == false {
            var alert = UIAlertView(title: "No connection", message: "You do not currently have network connection", delegate: nil, cancelButtonTitle: "Dismiss")
            alert.show()
            connectionAlertShown = true
        }
        
        
        // If this is the initial load (i.e., ViewDidLoad) and the connection test is successful, this function will retrieve the time of the last download and then determine if a new download is necessary.
        if self.initialLoad == true  && connection == true {
            timeSinceLastDownload = readAndSetTime()
            determineDownloadOrLoad()
            self.initialLoad == false
        } else  {
            timeSinceLastDownload = 0
        }
    }
    
    // This is the api call function
    
    func fetchProducts(numberOfProducts: Int, countOfCollection: Int, searched: String?, sort: Bool) {
        if self.connection == false {
            var alert = UIAlertView(title: "No connection", message: "You are not currently connected to the internet", delegate: nil, cancelButtonTitle: "Dismiss")
            alert.show()
        
        } else {
            if segmentedControl.selectedSegmentIndex != 2 && products.last?.lastItem != true {
                apiCalls = apiCallsEnabled(false)
                productDownloader?.downloadProducts(numberOfProducts, skip: countOfCollection, search: searched, sort: sort)
                if activityIndicator != nil {
                    activityIndicator.startAnimating()
                }
            } else if segmentedControl.selectedSegmentIndex == 2{
                productDownloader?.downloadProducts(200, skip: 0, search: searched, sort: false)
                }
                print("Skipping \(countOfCollection)")
            }
        }
    

    
    
    
    // MARK: - API Call Protocol OnResponse method.
    
    func onResponse(retrievedProducts: [Product]?, inStockProducts: [Product]?, searchedProducts: [Product]?, sort: Bool) {
        handleAllProducts(retrievedProducts)
        handleInStockProducts(inStockProducts)
        handleSearchedProducts(searchedProducts)
        self.productCount = self.products.count
        
        productLoaderSaver.saveProducts(self.products)
        setInitialDownloadTime()
        
        if sort == true {
            handleSorting(self.sortedBy)
        }
        
        self.apiCalls = apiCallsEnabled(true)
    
        reloadAndResetCollectionView()
        activityIndicator.stopAnimating()
        print("The current product count is \(productCount)")
    }
    
    // This delegate method prevents api calls to be made while one is currently in progress.
    
    func apiCallsEnabled(enabled: Bool) -> Bool {
        var apiEnabled: Bool!
        
        switch enabled {
        case true:
            apiEnabled = true
            activityIndicator.stopAnimating()
        default:
            apiEnabled = false
        }
        
        return apiEnabled
    }
    
    // this function creates and displays an error dialog to the user if the server is unavailable. 
    
    func serverError() {
        if connection == true {
            let alertController = UIAlertController(title: "Error", message:
                "Unfortunately we are having connection problems", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default) { (action) in
                });
            
            self.presentViewController(alertController, animated: true, completion: nil)
            self.activityIndicator.stopAnimating()
        }
        
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
//                print("There are now \(self.searchedProducts.count) searched products")
            } else {
                print("nothing to add to searched products")
                }
            }
            reloadAndResetCollectionView()
        }
    
    // this logic handles the products retrieved that are currently in stock.
    func handleInStockProducts(inStockProducts: [Product]?){
        if let myInStockProducts = inStockProducts {
            self.inStockProducts += myInStockProducts
            print("adding \(myInStockProducts.count) products to inStockProducts")
//               print("There are now \(self.inStockProducts.count) inStock products")
        } else {
            print("nothing to add to inStock products")
        }
    }
        
    // this logic handles all products recieved.
    func handleAllProducts(retrievedProducts: [Product]?) {
        if let myRetrievedProducts = retrievedProducts {
            self.products += myRetrievedProducts
            print("adding \(myRetrievedProducts.count) products to allProducts")
//               print("There are now \(self.products.count) products")
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
        
        let productSize = productSizer.setProductSize(productForCell.size)
        cell.size.text = productSize
        cell.price.text = "$\(Int(productForCell.price))"
        
        
        cell.face.text = productForCell.face
        cell.face.adjustsFontSizeToFitWidth = true
        
        
        if productForCell.stock > 0 {
            cell.quantity.text = "Only \(productForCell.stock) left"
        } else {
            cell.quantity.text = "Sold out!"
        }
        
        if productForCell.lastItem == true {
            cell.quantity.text = ""
            cell.price.text = ""
        }
        
        formatCellDimensions()
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        var productForCell = determineProductToUse(indexPath.row)
        self.product = productForCell
        
        var productSize = productSizer.setProductSize(productForCell.size)
        let faceSize = CGFloat(productSizer.setFaceSize(productSize))
        
        productPreviewFace.text = productForCell.face
        productPreviewFace.font = productPreviewFace.font.fontWithSize(faceSize)
        if productForCell.size > 30 {
            productPreviewFace.adjustsFontSizeToFitWidth = true
        }
        
        
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
    
    
    // MARK: - Scroll to load functionality
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.scrollView = scrollView
        
        if segmentedControl.selectedSegmentIndex != 2 && products.last?.lastItem != true {
            enableScrollToLoad()
        }
    }

    
    // This function handles enabling the scroll to load more functionality
    
    func enableScrollToLoad() {
        if self.connection == true {
            if scrollView.contentSize.height > minimumTrigger {
                let distanceFromBottom = scrollView.contentSize.height - (scrollView.bounds.size.height - scrollView.contentInset.bottom) - scrollView.contentOffset.y
                if distanceFromBottom < self.scrollTriggerDistanceFromBottom && apiCalls == true && self.connection == true{
                    reloadAndResetCollectionView()
                    setActivityIndicator(self.products.count)
                    fetchProducts(30, countOfCollection: self.products.count, searched: nil, sort: false)
                    }
                }
            }
        }

    
    // This function sets the distance to the bottom of the screen that is used to trigger an action.
    
    func setMinimumTrigger() {
        minimumTrigger = productCollectionView.bounds.size.height + scrollTriggerDistanceFromBottom
        productCollectionView.scrollEnabled = true
    }
    
    
    

    func setActivityIndicator(productsLoaded: Int){
        if productsLoaded == self.products.count && self.products.last?.lastItem != true{
            self.activityIndicator.startAnimating()
        } else {
            self.activityIndicator.stopAnimating()
        }
    }
    
    func reloadAndResetCollectionView() {
        productCollectionView.reloadData()
        setMinimumTrigger()
    }
    
    
    // MARK: - Cell Formatting
    
    // These functions format the cell size based on the iPhone screen size
    
    func formatCellDimensions(){
        let layout = productCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSizeMake(cellWidth, cellWidth + heightAdjustment)
    }
    
    func calculateCellDimensions() {
        screenWidth = UIScreen.mainScreen().bounds.width
        screenHeight = UIScreen.mainScreen().bounds.height
        
        cellWidth = ((screenWidth - 16) - leftAndRightPaddings) / numberOfItemsInRow
        cellHeight = (screenWidth + 30)
        
        self.numberOfCells = deviceDeterminer.determineNumberOfCells(screenHeight)
        
        self.scrollTriggerDistanceFromBottom = screenHeight - 200
    }
    
    
    
    
    // This function puts the activitiy indicator in view and starts the animation.
    
    func setActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        activityIndicator.hidesWhenStopped = true
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
        if self.connection == true {
            self.searchedProducts = []
            
            
            searchTag = searchBar.text?.lowercaseString
            searchTagForURL = searchTag?.stringByReplacingOccurrencesOfString(" ", withString: "")
            
            print("Fetching searched products")
            fetchProducts(200, countOfCollection: 0, searched: searchTagForURL, sort: false)
            
            self.searchBar.showsCancelButton = false
            self.searchBar.resignFirstResponder()
            
            self.productCollectionView.reloadData()
        }
        self.searchBar.resignFirstResponder()
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
            let timeIntervalInMinutes = Int(timeInterval) / 60

            print("it has been \(timeIntervalInMinutes) minutes since the last download")
            time = timeInterval
        }
        
        return time
    }
    
    // This code sets the value for the time of last download. It does it only when the user pulls the first batch to prevent later product fetches from increasing the time to the next download.
    
    func setInitialDownloadTime() {
        if self.products.count == numberOfCells {
            reloadAndResetCollectionView()
            localStorage.setObject(date, forKey:"timeOfLastDownload")
            fetchProducts(numberOfCells, countOfCollection: productCount, searched: nil, sort: false)
        }
    }
    
    
    
    
    
    // This function determines if a new download is necessary based on the time passed since the last download
    // If a new download is not necessary, it loads the previously retrieved products from the archive directory.
    
    func determineDownloadOrLoad() {
        if self.timeSinceLastDownload >= 3600.0 {
            self.products = []
            print("It about time for some new products!")
            
            let savedCart = productLoaderSaver.loadCart()
            self.cart = savedCart[0]
            
            if self.connection == true {
                fetchProducts(numberOfCells, countOfCollection: products.count, searched: nil, sort: false)
            }
            
        } else {
            let savedProducts = productLoaderSaver.loadProducts()
            self.products = savedProducts[0]
            
            let savedCart = productLoaderSaver.loadCart()
            self.cart = savedCart[0]
            
            
            addInStockProducts(self.products)
            if self.products.last?.lastItem == true {
                inStockProducts.append((lastProduct)!)
            }
            
            if self.products == [] {
                if self.connection == true {
                    fetchProducts(numberOfCells, countOfCollection: products.count, searched: nil, sort: false)
                    print("No saved products. Fetching some for you")
                }
            }
            self.productCollectionView.scrollEnabled = false
            reloadAndResetCollectionView()
        }
        setGroceryCartButton(cart.count)
        setMinimumTrigger()
        
    }
    
    // This function iterates over the products recieved and puts all inStock products in the inStockProducts collection.
    
    func addInStockProducts(allProducts: [Product]) {
        for product in allProducts{
            if product.stock > 0 {
                inStockProducts.append(product)
            }
        }
    }
    
    func groceryCartButtonPressed() {
        if cart.count > 0 {
            performSegueWithIdentifier("segueToCart", sender: nil)
        }
    }
    
    // this function is used to update the cart image and save the cart products when a product is added to the cart.
    
    func updateAndSaveCart(cart: [Product]) {
        self.cart = cart
        setGroceryCartButton(cart.count)
        productLoaderSaver.saveCart(self.cart)
        print("There are now \(self.cart.count) products saved for later")
    }
    
    
    // This function sends the CartViewController the current cart collection and sets the delegate for returning an updated cart
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueToCart" {
            cartViewController = segue.destinationViewController as! CartViewController
            cartViewController.handler = self
            cartViewController.cartItems = cart
            
        }
    }
    
    func toggleSortButtons() {
        switch priceButton.hidden {
        case true:
            self.priceButton.hidden = false
            self.sizeButton.hidden = false
            self.quantityButton.hidden = false
        default:
            self.priceButton.hidden = true
            self.sizeButton.hidden = true
            self.quantityButton.hidden = true
        }
    }
    
    func manageSortViews() {
        switch segmentedControl.selectedSegmentIndex {
        case 2:
            sortedByButton.hidden = true
            sortButton.hidden = true
            searchBar.hidden = false
        default:
            sortedByButton.hidden = false
            sortButton.hidden = false
            searchBar.hidden = true
        }
    }
    
    // MARK: - IBActions


    @IBAction func segmentedControlPressed(sender: AnyObject) {
        searchBar.text = nil
        reloadAndResetCollectionView()
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            manageSortViews()
            print("There are \(self.products.count) products on this tab")
        case 1:
            manageSortViews()
            print("There are \(self.inStockProducts.count) inStock products on this tab")
        default:
            manageSortViews()
            print("There are \(self.searchedProducts.count) searched products on this tab")
        }
        
        productPreview.hidden = true
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
    @IBAction func sortButtonPressed(sender: AnyObject) {
        toggleSortButtons()
        productPreview.hidden = true
    }
    
    @IBAction func priceButtonPressed(sender: AnyObject) {
        toggleSortButtons()
        self.sortLabelText = "  Price"
        self.sortButton.titleLabel?.text = sortLabelText
        self.sortedBy = "price"
        self.sortedByButton.text = self.sortMode

        if products.last?.lastItem == true {
            sortPrice()
            productCollectionView.reloadData()
        } else if self.connection == true {
                fetchProducts(100, countOfCollection: self.products.count, searched: nil, sort: true)
        } else {
            sortPrice()
        }
        self.sortedByButton.userInteractionEnabled = true
    }
    
    @IBAction func sizeButtonPressed(sender: AnyObject) {
        toggleSortButtons()
        self.sortLabelText = "  Size"
        self.sortButton.titleLabel?.text = sortLabelText
        self.sortedBy = "size"
        self.sortedByButton.text = self.sortMode
        
        if products.last?.lastItem == true {
            sortSize()
            productCollectionView.reloadData()
        } else if self.connection == true {
                fetchProducts(100, countOfCollection: self.products.count, searched: nil, sort: true)
        } else {
            sortSize()
        }
        self.sortedByButton.userInteractionEnabled = true
    }
    
    @IBAction func quantityButtonPressed(sender: AnyObject) {
        toggleSortButtons()
        self.sortLabelText = "Quantity"
        self.sortButton.titleLabel?.text = sortLabelText
        self.sortedBy = "quantity"
        self.sortedByButton.text = self.sortMode
        
        if products.last?.lastItem == true {
            sortQuantity()
            productCollectionView.reloadData()
        } else if self.connection == true {
            fetchProducts(100, countOfCollection: self.products.count, searched: nil, sort: true)
        } else {
            sortQuantity()
        }
        self.sortedByButton.userInteractionEnabled = true
    }
    
    func sortPrice() {
        var lastItemIncluded = false
        
        switch sortMode {
        case "Descending":
            self.products = self.products.sort {(element1, element2) -> Bool in
                return element1.price > element2.price
            }
            self.inStockProducts = self.inStockProducts.sort {(element1, element2) -> Bool in
                return element1.price > element2.price
            }
        default:
            if self.products.last?.lastItem == true {
                lastItemIncluded = true
                self.products.removeLast()
                self.inStockProducts.removeLast()
            }
            
            self.products = self.products.sort {(element1, element2) -> Bool in
                return element1.price < element2.price
            }
            self.inStockProducts = self.inStockProducts.sort {(element1, element2) -> Bool in
                return element1.price < element2.price
            }
            if lastItemIncluded == true {
                self.products.append(lastProduct!)
                self.inStockProducts.append(lastProduct!)
            }
        }
    }
    
    func sortSize() {
        var lastItemIncluded = false
        
        switch sortMode {
        case "Descending":
            self.products = self.products.sort {(element1, element2) -> Bool in
                return element1.size > element2.size
            }
            self.inStockProducts = self.inStockProducts.sort {(element1, element2) -> Bool in
                return element1.size > element2.size
            }
        default:
            if self.products.last?.lastItem == true {
                lastItemIncluded = true
                self.products.removeLast()
                self.inStockProducts.removeLast()
            }
            
            self.products = self.products.sort {(element1, element2) -> Bool in
                return element1.size < element2.size
            }
            self.inStockProducts = self.inStockProducts.sort {(element1, element2) -> Bool in
                return element1.size < element2.size
            }
            
            if lastItemIncluded == true {
                self.products.append(lastProduct!)
                self.inStockProducts.append(lastProduct!)
            }
        }
    }
    
    func sortQuantity() {
        var lastItemIncluded = false
        
        switch sortMode {
        case "Descending":
            self.products = self.products.sort {(element1, element2) -> Bool in
                return element1.stock > element2.stock
            }
            self.inStockProducts = self.inStockProducts.sort {(element1, element2) -> Bool in
                return element1.stock > element2.stock
            }
        default:
            if self.products.last?.lastItem == true {
                lastItemIncluded = true
                self.products.removeLast()
                self.inStockProducts.removeLast()
            }
            
            self.products = self.products.sort {(element1, element2) -> Bool in
                return element1.stock < element2.stock
            }
            self.inStockProducts = self.inStockProducts.sort {(element1, element2) -> Bool in
                return element1.stock < element2.stock
            }
            
            if lastItemIncluded == true {
                self.products.append(lastProduct!)
                self.inStockProducts.append(lastProduct!)
            }
        }
    }
    
    func handleSorting(sortBy: String) {
        switch sortBy {
        case "price":
            sortPrice()
        case "size":
            sortSize()
        case "quantity":
            sortQuantity()
        default:
            print("Error sorting")
        }
        productCollectionView.reloadData()
    }
    
    
    @IBAction func sortedByButtonPressed(sender: AnyObject) {
        if self.sortMode == "Descending" {
            self.sortMode = "Ascending"
        } else {
            self.sortMode = "Descending"
        }
        
        manageSortMode()
        self.sortedByButton.text = self.sortMode
        productCollectionView.reloadData()
    }
    
    func manageSortMode() {
        switch sortedBy {
        case "price":
            sortPrice()
        case "size":
            sortSize()
        default:
            sortQuantity()
        }
    }
}


