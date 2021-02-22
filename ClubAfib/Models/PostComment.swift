//
//  PostComment.swift
//  ClubAfib
//
//  Created by Rener on 8/19/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit
import SwiftyJSON

class PostComment {
    
    var id : Int!
    var post_id: Int!
    var user_id: Int!
    var content : String?
    var user: User!
    var createdAt: Date!
    var likes = [Like]()
    var dislikes = [Like]()
    
    init() {
    }
    
    init(_ item : JSON){
        self.id                     = item["id"].intValue
        self.post_id                = item["post_id"].intValue
        self.user_id                = item["user_id"].intValue
        self.content                = item["text"].stringValue
        self.createdAt              = item["createdAt"].dateValue
        self.user                   = User(item["user"])
        
        if let likes = item["likes"].array {
            self.likes = likes.map { return Like($0) }
        }
        if let dislikes = item["dislikes"].array {
            self.dislikes = dislikes.map { return Like($0) }
        }
    }
}
