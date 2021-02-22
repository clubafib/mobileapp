//
//  Like.swift
//  ClubAfib
//
//  Created by Rener on 8/21/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit
import SwiftyJSON

class Like {
    
    var user_id : Int!
    
    init() {
    }
    
    init(_ item : JSON){
        self.user_id                     = item["user_id"].intValue
    }
}
