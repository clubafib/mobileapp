//
//  Payment.swift
//  ClubAfib
//
//  Created by Rener on 8/21/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit
import SwiftyJSON

class Payment {
    
    var id : Int!
    var stripe_id : String!
    var type : Int!
    var status : Int!
    var createdAt : Date!
    var updatedAt : Date!
    
    init() {
    }
    
    init(_ item : JSON){
        self.id                     = item["id"].intValue
        self.stripe_id              = item["stripe_id"].stringValue
        self.type                   = item["type"].intValue
        self.status                 = item["patient"].intValue
        self.createdAt              = item["createdAt"].dateValue
        self.updatedAt              = item["updatedAt"].dateValue
    }
    
}
