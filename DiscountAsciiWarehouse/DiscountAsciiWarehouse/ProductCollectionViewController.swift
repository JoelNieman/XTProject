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
    
    private var productDownloader: ProductDownloader?
    private var products = [Product]()
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
    
    private var activityIndicator: UIActivityIndicatorView!
    
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    
    
    
    // MARK: - VC life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        screenWidth = UIScreen.mainScreen().bounds.width
        screenHeight = UIScreen.mainScreen().bounds.height
        
        cellWidth = ((screenWidth - 16) - leftAndRightPaddings) / numberOfItemsInRow
        cellHeight = (screenWidth + 30)
        
        numberOfCells = deviceDeterminer.determineNumberOfCells(screenHeight)
        
        fetchProducts(numberOfCells, countOfCollection: products.count)
        
        self.searchBar.delegate = self
        
        print("ViewWillAppear: The number of cells to download is: \(numberOfCells)")
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - API Call Protocol Methods
    
    func onResponse(retrievedProducts: [Product]) {
        
        self.products += retrievedProducts
//        
        let dataToSave:Dictionary = ["cachedAllProducts": self.products]
        
//        let d = NSKeyedArchiver.archivedDataWithRootObject(dataToSave)
//        localStorage.setValue(dataToSave, forKey: "cachedAllProducts")
        
        
//        localStorage = NSUserDefaults.standardUserDefaults()
//        localStorage.setObject(dataToSave, forKey: "cachedAllProducts")
//        localStorage.setObject(dataToSave, forKey: "cachedAllProducts")
//        localStorage.synchronize()
        
        productCount = self.products.count
//        print("There are \(localStorage.objectForKey("cachedAllProducts")!.count) cached products")
        
        self.productCollectionView.reloadData()
        activityIndicator.stopAnimating()
        
        minimumTrigger = productCollectionView.bounds.size.height + scrollTriggerDistanceFromBottom
        productCollectionView.scrollEnabled = true
        
        print("The product count is \(productCount)")
    }
    
    // MARK: - UICollectionViewMethods
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.products.count
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ProductCell", forIndexPath: indexPath) as! CustomCell
        
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
                    fetchProducts(21, countOfCollection: productCount)
                    print("Fetching 21")
                    print("Skipping \(products.count)")
                }
            }
        }
    }
    
    
    // MARK: - XXX
    
    
    func fetchProducts(numberOfProducts: Int, countOfCollection: Int) {
            startActivityIndicator()
            productDownloader = ProductDownloader(handler: self)
            productDownloader?.downloadProducts(numberOfProducts, skip: countOfCollection)
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
    
    // MARK - Search functionality
    
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
    
}
