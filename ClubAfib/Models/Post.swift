//
//  Post.swift
//  ClubAfib
//
//  Created by Rener on 8/19/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit
import SwiftyJSON

class Post {
    
    var id : Int!
    var nickname : String!
    var image : String?
    var title : String?
    var description : String?
    var creator : User!
    var likes = [Like]()
    var dislikes = [Like]()
    var comments : [PostComment] = [PostComment]()
    var createdAt: Date!
    
    init() {
    }
    
    init(_ item : JSON){
        self.id                     = item["id"].intValue
        self.nickname               = item["nickname"].stringValue
        self.image                  = item["image"].stringValue
        self.title                  = item["title"].stringValue
        self.description            = item["content"].stringValue
        self.creator                = User(item["creator"])
        self.createdAt              = item["createdAt"].dateValue
        
        if let likes = item["likes"].array {
            self.likes = likes.map{ return Like($0) }
        }
        if let dislikes = item["dislikes"].array {
            self.dislikes = dislikes.map{ return Like($0) }
        }
        if let comments = item["comments"].array {
            self.comments = comments.map{ return PostComment($0) }
        }
    }
}
