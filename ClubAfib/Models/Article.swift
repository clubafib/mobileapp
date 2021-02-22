//
//  Article.swift
//  ClubAfib
//
//  Created by Rener on 7/25/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit
import SwiftyJSON

class Article {
    
    var id : Int!
    var banner : String?
    var title : String?
    var description : String?
    var caption : String?
    var createdAt : Date!
    var likes = [Like]()
    var dislikes = [Like]()
    
    init() {
    }
    
    init(_ item : JSON){
        self.id                     = item["id"].intValue
        self.banner                 = item["banner"].stringValue
        self.title                  = item["title"].stringValue
        self.description            = item["description"].stringValue
        self.caption                = item["caption"].stringValue
        self.createdAt              = item["createdAt"].dateValue
        
        if let likes = item["likes"].array {
            self.likes = likes.map { return Like($0) }
        }
        if let dislikes = item["dislikes"].array {
            self.dislikes = dislikes.map { return Like($0) }
        }
    }
}
