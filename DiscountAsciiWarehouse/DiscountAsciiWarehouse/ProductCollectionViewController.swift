//
//  ProductCollectionViewController.swift
//  DiscountAsciiWarehouse
//
//  Created by Nieman, Joel (J.M.) on 6/9/16.
//  Copyright © 2016 JoelNieman. All rights reserved.
//

import UIKit

//private let reuseIdentifier = "ProductCell"

class ProductCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, ProductResponseDelegate {
    
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var productCollectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    
    private var productDownloader: ProductDownloader?
    private var products = [Product]()
    private var inStockProducts = [Product]()
    private var searchedProducts = [Product]()
    private let product = Product()
    private var loadedProducts:[Product]?
    private var productCount:Int!
    private var searchTag: String?
    
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
    
    private var activityIndicator: UIActivityIndicatorView!
    
    

    
    
    
    
    // MARK: - VC life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        screenWidth = UIScreen.mainScreen().bounds.width
        screenHeight = UIScreen.mainScreen().bounds.height
        
        cellWidth = ((screenWidth - 16) - leftAndRightPaddings) / numberOfItemsInRow
        cellHeight = (screenWidth + 30)
        
        numberOfCells = deviceDeterminer.determineNumberOfCells(screenHeight)
        
        productDownloader = ProductDownloader(handler: self)
        
        timeSinceLastDownload = readAndSetTime()
        
        if self.timeSinceLastDownload >= 60.0 {
            self.products = []
            print("It about time for some new products!")
            fetchProducts(numberOfCells, countOfCollection: products.count, inStock: 0, searched: nil)
        } else {
            let productsCollection = productLoaderSaver.loadProducts()
            self.products = productsCollection[0]
            self.inStockProducts = productsCollection[1]
            if self.products == [] {
                fetchProducts(numberOfCells, countOfCollection: products.count, inStock: 0, searched: nil)
                print("No saved products. Fetching some for you")
            }
        }
        
        self.searchBar.delegate = self
        
        setGroceryCartButton()

        print("ViewWillAppear: loaded \(self.products.count) products")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - API Call Protocol Methods
    
    func onResponse(retrievedProducts: [Product]?, inStockProducts: [Product]?, searchedProducts: [Product]?) {
        
        
        if let mySearchedProducts = searchedProducts {
            if mySearchedProducts.count > 0{
                self.searchedProducts = mySearchedProducts
                segmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
                segmentedControl.selectedSegmentIndex = 2
                print("adding \(searchedProducts!.count) products to searchedProducts")
                print("There are now \(self.searchedProducts.count) searched products")
            } else {
                print("nothing to add to searched products")
            }
        }

        if let myInStockProducts = inStockProducts {
            self.inStockProducts += inStockProducts!
            print("adding \(inStockProducts!.count) products to inStockProducts")
            print("There are now \(self.inStockProducts.count) inStock products")
        } else {
            print("nothing to add to inStock products")
        }
        
        if let myRetrievedProducts = retrievedProducts {
            self.products += retrievedProducts!
            print("adding \(retrievedProducts!.count) products to allProducts")
            print("There are now \(self.products.count) products")
        } else {
            print("nothing to add to searched products")
        }
        
        productCount = self.products.count
        
        self.productCollectionView.reloadData()
        activityIndicator.stopAnimating()
        
        setMinimumTrigger()
        
        productLoaderSaver.saveProducts(self.products, inStockProducts: self.inStockProducts)
        
        if self.products.count == numberOfCells {
            localStorage.setObject(date, forKey:"timeOfLastDownload")
        }
        print("The product count is \(productCount)")
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
        
        if segmentedControl.selectedSegmentIndex == 0 {
            cell.face.text = self.products[indexPath.row].face
        } else if segmentedControl.selectedSegmentIndex == 1 {
            cell.face.text = self.inStockProducts[indexPath.row].face
        } else {
            cell.face.text = self.searchedProducts[indexPath.row].face
        }
        
        
        formatCellDimensions()
        
        return cell
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if products.last?.lastItem != true {
            if scrollView.contentSize.height > minimumTrigger {
                let distanceFromBottom = scrollView.contentSize.height - (scrollView.bounds.size.height - scrollView.contentInset.bottom) - scrollView.contentOffset.y
                
                if distanceFromBottom < self.scrollTriggerDistanceFromBottom {
                    scrollView.scrollEnabled = false
                    if segmentedControl.selectedSegmentIndex == 0 {
                        fetchProducts(30, countOfCollection: self.products.count, inStock: 0, searched: nil)
                        print("Fetching 30 products")
                        print("Skipping \(products.count)")
                    } else if segmentedControl.selectedSegmentIndex == 1 {
                        fetchProducts(30, countOfCollection: self.inStockProducts.count, inStock: 1, searched: nil)
                        print("Fetching 30 inStock products")
                        print("Skipping \(products.count)")
                    }
                    
                }
            }
        }
    }
    
    
    // MARK: - XXX
    
    
    func fetchProducts(numberOfProducts: Int, countOfCollection: Int, inStock: Int, searched: String?) {
        startActivityIndicator()
        productDownloader?.downloadProducts(numberOfProducts, skip: countOfCollection, inStock: inStock, search: searched)
    }
    
    func formatCellDimensions(){
        let layout = productCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSizeMake(cellWidth, cellWidth + heightAdjustment)
    }
    
    
    @IBAction func segmentedControlPressed(sender: AnyObject) {
        searchBar.text = nil
        productCollectionView.reloadData()
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            print("There are \(self.products.count) products on this tab")
        case 1:
            print("There are now \(self.inStockProducts.count) inStock products on this tab")
        default:
            print("There are now \(self.searchedProducts.count) searched products on this tab")
        }
    }
    
    func startActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: activityIndicator)
    }
    
    func setGroceryCartButton() {
        let groceryCartImage = UIImage(named: "Cart0")?.imageWithRenderingMode(.AlwaysOriginal)
        let groceryCartButton: UIButton = UIButton(type: UIButtonType.Custom)
        groceryCartButton.setImage((groceryCartImage), forState: UIControlState.Normal)
        groceryCartButton.addTarget(self, action: "groceryCartButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        groceryCartButton.frame = CGRectMake(0, 0, 30, 30)
        
        let barButton = UIBarButtonItem(customView: groceryCartButton)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    func setMinimumTrigger() {
        minimumTrigger = productCollectionView.bounds.size.height + scrollTriggerDistanceFromBottom
        productCollectionView.scrollEnabled = true
    }
    
    
    
    
    
    // MARK: - Search functionality
    
    internal func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        self.searchBar.showsCancelButton = true
        
        return true
    }
    
    internal func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        searchTag = searchBar.text?.lowercaseString
        var searchTagForURL = searchTag?.stringByReplacingOccurrencesOfString(" ", withString: "")
        print("The searchTagForUrl is \(searchTagForURL)")
        
        print("Fetching searched products")
        fetchProducts(0, countOfCollection: 0, inStock: 0, searched: searchTagForURL)
        
        self.searchBar.showsCancelButton = false
        self.searchBar.resignFirstResponder()
    }
    
    internal func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = false
        self.searchBar.resignFirstResponder()
    }
    
    // MARK: - Timer for product caching
    
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
            print("it has been \(timeInterval) since the last download")
            time = timeInterval
        }
        
        return time
    }
}
