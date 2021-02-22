//
//  Goods.swift
//  ClubAfib
//
//  Created by Rener on 8/21/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit
import SwiftyJSON

class Goods {
    
    var id : Int!
    var image : String?
    var name : String?
    var description : String?
    var link : String?
    var price : Double!
    var createdAt : Date!
    var likes = [Like]()
    var dislikes = [Like]()
    
    init() {
    }
    
    init(_ item : JSON){
        self.id                     = item["id"].intValue
        self.image                  = item["image"].string
        self.name                   = item["name"].string
        self.description            = item["description"].string
        self.link                   = item["link"].string
        self.createdAt              = item["createdAt"].dateValue
        self.price                  = item["price"].doubleValue
        
        if let likes = item["likes"].array {
            self.likes = likes.map { return Like($0) }
        }
        if let dislikes = item["dislikes"].array {
            self.dislikes = dislikes.map { return Like($0) }
        }
    }
}
