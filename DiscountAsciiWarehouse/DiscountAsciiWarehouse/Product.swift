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


class Product {
    var type: String!
    var id: String!
    var size: Int!
    var price: Double!
    var face: String!
    var stock: Int!
    var tags: [String]!
    var lastItem: Bool!
    
    init() {
        
    }
    
    init(face: String, lastItem: Bool) {
        self.face = face
        self.lastItem = lastItem
    }
    
//    required convenience init?(coder decoder: NSCoder) {
//        guard let type = decoder.decodeObjectForKey("type") as? String,
//            let id = decoder.decodeObjectForKey("id") as? String,
//            let size = decoder.decodeIntForKey("size") as? Int32,
//            let price = decoder.decodeDoubleForKey("price") as? Double,
//            let face = decoder.decodeObjectForKey("face") as? String,
//            let stock = decoder.decodeIntForKey("stock") as? Int32,
//            let tags = decoder.decodeObjectForKey("tags") as? [String],
//            let lastItem = (decoder.decodeBoolForKey("lastItem") as? Bool)
//            else { return nil }
//        
//        self.init(type: type, id: id, size: size, price: price, face: face, stock: stock, tags: tags, lastItem: lastItem) {
//            self.type = type
//            self.id = id
//            self.size = size
//            self.price = price
//            self.face = face
//            self.stock = stock
//            self.tags = tags
//            self.lastItem = lastItem
//        }
//    }
//    
//    func encodeWithCoder(coder: NSCoder) {
//        coder.encodeObject(self.title, forKey: "title")
//        coder.encodeObject(self.author, forKey: "author")
//        coder.encodeInt(Int32(self.pageCount), forKey: "pageCount")
//        coder.encodeObject(self.categories, forKey: "categories")
//        coder.encodeBool(self.available, forKey: "available")
//    }
    
}