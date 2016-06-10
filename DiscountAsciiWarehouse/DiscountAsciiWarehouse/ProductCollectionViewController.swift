//
//  ProductCollectionViewController.swift
//  DiscountAsciiWarehouse
//
//  Created by Nieman, Joel (J.M.) on 6/9/16.
//  Copyright © 2016 JoelNieman. All rights reserved.
//

import UIKit

//private let reuseIdentifier = "ProductCell"

class ProductCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, ProductResponseDelegate {
    
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var productCollectionView: UICollectionView!
    
    var productDownloader: ProductDownloader?
    var products = [Product]()
    
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
        
        print("ViewWillAppear: The number of cells to download is: \(numberOfCells)")
        
        self.navigationItem.title = "Discount Ascii Warehouse"
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
        
        
        //        let numberOfCells = Int((screenHeight/cellHeight) + cellHeight)/3
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - API Call Protocol Methods
    
    func onResponse(products: [Product]) {
        self.products += products
        //        print("There are \(self.products.count) products")
        
        //        if (self.products.count < 4) {
        //            productDownloader?.downloadProducts(1, skip: self.products.count)
        //        }
        
        // var index = self.products.count-1
        productCollectionView.reloadInputViews()
        //        productCollectionView.reloadSections(NSIndexSet(index: 1))
        
        
        self.productCollectionView.reloadData()
        
        
        //        self.productCollectionView.reloadData()
        
        print(products.count)
        
    }
    
    
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
    
    func fetchProducts(numberOfProducts: Int, countOfCollection: Int) {
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
    
}
