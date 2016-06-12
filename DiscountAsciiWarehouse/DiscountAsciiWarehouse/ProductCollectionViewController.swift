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
    private let product = Product()
    private var loadedProducts:[Product]?
    private var productCount:Int!
    
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
            fetchProducts(numberOfCells, countOfCollection: products.count, inStock: 0)
            print("It about time for some new products!")
        } else {
            let productsCollection = productLoaderSaver.loadProducts()
            self.products = productsCollection[0]
            self.inStockProducts = productsCollection[1]
            if self.products == [] {
                fetchProducts(numberOfCells, countOfCollection: products.count, inStock: 0)
                print("No saved products. Fetching some for you")
            }
        }
        
        self.searchBar.delegate = self
        
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
    
    func onResponse(retrievedProducts: [Product]?, inStockProducts: [Product]?) {
        
        if retrievedProducts != nil {
            self.products += retrievedProducts!
            print("adding \(retrievedProducts!.count) products to allProducts")
        }
        
        if inStockProducts != nil {
            self.inStockProducts += inStockProducts!
            print("adding \(inStockProducts!.count) products to inStockProducts")
        }
        
        
        productCount = self.products.count
        
        self.productCollectionView.reloadData()
        activityIndicator.stopAnimating()
        
        minimumTrigger = productCollectionView.bounds.size.height + scrollTriggerDistanceFromBottom
        productCollectionView.scrollEnabled = true
        
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
        } else {
            numberOfCells = self.inStockProducts.count
        }
        
        return numberOfCells
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ProductCell", forIndexPath: indexPath) as! CustomCell
        
        if segmentedControl.selectedSegmentIndex == 0 {
            cell.face.text = self.products[indexPath.row].face
        } else {
            cell.face.text = self.inStockProducts[indexPath.row].face
        }
        
        cell.face.text = self.products[indexPath.row].face
        
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
                        fetchProducts(21, countOfCollection: self.products.count, inStock: 0)
                        print("Fetching 21")
                        print("Skipping \(products.count)")
                    } else if segmentedControl.selectedSegmentIndex == 1 {
                        fetchProducts(21, countOfCollection: self.products.count, inStock: 1)
                        print("Fetching 21 inStock products")
                        print("Skipping \(products.count)")
                    }
                    
                }
            }
        }
    }
    
    
    // MARK: - XXX
    
    
    func fetchProducts(numberOfProducts: Int, countOfCollection: Int, inStock: Int) {
        startActivityIndicator()
        productDownloader?.downloadProducts(numberOfProducts, skip: countOfCollection, inStock: inStock)
    }
    
    func formatCellDimensions(){
        let layout = productCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSizeMake(cellWidth, cellWidth + heightAdjustment)
    }
    
    
    @IBAction func segmentedControlPressed(sender: AnyObject) {
        productCollectionView.reloadData()
    }
    
    func startActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: activityIndicator)
    }
    
    // MARK: - Search functionality
    
    internal func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        self.searchBar.showsCancelButton = true
        
        return true
    }
    
    internal func searchBarSearchButtonClicked(searchBar: UISearchBar) {
//        self.searchBar.endEditing(true)
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
