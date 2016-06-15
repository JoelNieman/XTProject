//
//  Product.swift
//  DiscountAsciiWarehouse
//
//  Created by Nieman, Joel (J.M.) on 6/8/16.
//  Copyright © 2016 JoelNieman. All rights reserved.
//

import Foundation




// MARK: - Types

struct PropertyKey {
    static let typeKey = "type"
    static let idKey = "id"
    static let sizeKey = "size"
    static let priceKey = "price"
    static let faceKey = "face"
    static let stockKey = "stock"
    static let tagsKey = "tags"
    static let lastItemKey = "lastItem"
    
}

// MARK: - Product Class

// this is my custom "Product" object.
// Product subclasses NSObject and implements NSCoding to enable saving and loading of previously retrieved products.

class Product: NSObject, NSCoding {
    var type: String!
    var id: String!
    var size: Int!
    var price: Double!
    var face: String!
    var stock: Int!
    var tags: [String]!
    var lastItem: Bool!
    
    override init() {
        super.init()
    }
    
    
    init(face: String, lastItem: Bool) {
        self.face = face
        self.lastItem = lastItem
        
        super.init()
    }
    
    init?(type: String, id: String, size: Int, price: Double, face: String, stock: Int, tags: [String], lastItem: Bool) {
        self.type = type
        self.id = id
        self.size = size
        self.price = price
        self.face = face
        self.stock = stock
        self.tags = tags
        self.lastItem = lastItem
        
        super.init()
        
        if (face.isEmpty) {
            return nil
        }
    }
    
    
    
    // MARK: - NSCoding
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(type, forKey: PropertyKey.typeKey)
        aCoder.encodeObject(id, forKey: PropertyKey.idKey)
        aCoder.encodeInteger(size, forKey: PropertyKey.sizeKey)
        aCoder.encodeDouble(price, forKey: PropertyKey.priceKey)
        aCoder.encodeObject(face, forKey: PropertyKey.faceKey)
        aCoder.encodeInteger(stock, forKey: PropertyKey.stockKey)
        aCoder.encodeObject(tags, forKey: PropertyKey.tagsKey)
        aCoder.encodeBool(lastItem, forKey: PropertyKey.lastItemKey)
    }
    
    
    required convenience init?(coder decoder: NSCoder) {
        let type = decoder.decodeObjectForKey(PropertyKey.typeKey) as? String
        let id = decoder.decodeObjectForKey(PropertyKey.idKey) as? String
        let size = decoder.decodeIntegerForKey(PropertyKey.sizeKey) as? Int
        let price = decoder.decodeDoubleForKey(PropertyKey.priceKey) as? Double
        let face = decoder.decodeObjectForKey(PropertyKey.faceKey) as? String
        let stock = decoder.decodeIntegerForKey(PropertyKey.stockKey) as? Int
        let tags = decoder.decodeObjectForKey(PropertyKey.tagsKey) as? [String]
        let lastItem = decoder.decodeBoolForKey(PropertyKey.lastItemKey) as? Bool

        
        self.init(type: type!, id: id!, size: size!, price: price!, face: face!, stock: stock!, tags: tags!, lastItem: lastItem!)
    }
    
    // these are the files where the All Products and Products in Cart are saved and loaded from. 
    static let documentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static var allProductURL = documentsDirectory.URLByAppendingPathComponent("Products")
    static var cartURL = documentsDirectory.URLByAppendingPathComponent("Cart")
}