//
//  User.swift
//  Models
//
//  Created by Rener on 7/25/20.
//  Copyright © 2020 ExtremeMobile. All rights reserved.
//

import UIKit
import SwiftyJSON

class User: NSObject, NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(userId, forKey: "userId")
        aCoder.encode(firstName, forKey: "firstName")
        aCoder.encode(lastName, forKey: "lastName")
        aCoder.encode(username, forKey: "username")
        aCoder.encode(email, forKey: "email")
        aCoder.encode(photo, forKey: "photo")
        aCoder.encode(address, forKey: "address")
        aCoder.encode(phonenumber, forKey: "phonenumber")
        aCoder.encode(language, forKey: "language")
    }
    
    required init?(coder aDecoder: NSCoder) {
        userId = aDecoder.decodeObject(forKey: "userId") as? Int
        firstName = aDecoder.decodeObject(forKey: "firstName") as? String
        lastName = aDecoder.decodeObject(forKey: "lastName") as? String
        username = aDecoder.decodeObject(forKey: "username") as? String
        email = aDecoder.decodeObject(forKey: "email") as? String
        photo = aDecoder.decodeObject(forKey: "photo") as? String
        address = aDecoder.decodeObject(forKey: "address") as? String
        phonenumber = aDecoder.decodeObject(forKey: "phonenumber") as? String
        language = aDecoder.decodeObject(forKey: "language") as? String
    }
    
    var userId : Int!
    var firstName : String!
    var lastName : String!
    var username : String!
    var email : String!
    var photo : String?
    var address : String?
    var phonenumber : String?
    var language : String?
    var status : Int!
    
    override init() {
        
    }
    
    init(_ item : JSON){
        self.userId                 = item["id"].intValue
        self.firstName              = item["first_name"].stringValue
        self.lastName               = item["last_name"].stringValue
        self.username               = item["username"].stringValue
        self.email                  = item["email"].stringValue
        self.status                 = item["status"].intValue
        self.address                = item["address"].string
        self.phonenumber            = item["phonenumber"].string
        self.photo                  = item["photo"].string
        self.language               = item["language"].string
    }
}
