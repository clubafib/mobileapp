//
//  Patient.swift
//  ClubAfib
//
//  Created by Rener on 9/1/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

class Patient: Object {
    
    @objc dynamic var userId = 0
    @objc dynamic var firstName : String?
    @objc dynamic var lastName : String?
    @objc dynamic var username : String?
    @objc dynamic var subject : String?
    @objc dynamic var email : String?
    @objc dynamic var photo : String?
    @objc dynamic var language : String?
    @objc dynamic var address : String?
    @objc dynamic var phone : String?
    @objc dynamic var about : String?
    
    required override init() {
    }
    
    override static func primaryKey() -> String? {
        return "userId"
    }
    
    init(_ item : JSON){
        self.userId                 = item["id"].intValue
        self.firstName              = item["first_name"].stringValue
        self.lastName               = item["last_name"].stringValue
        self.username               = item["username"].stringValue
        self.subject                = item["subject"].stringValue
        self.email                  = item["email"].stringValue
        self.photo                  = item["photo"].stringValue
        self.language               = item["language"].stringValue
        self.address                = item["address"].stringValue
        self.phone                  = item["phone"].stringValue
        self.about                  = item["about"].stringValue
        
        super.init()

        try! RealmManager.default.realm.write {
            RealmManager.default.realm.add(self, update: .modified)
        }
    }
}
