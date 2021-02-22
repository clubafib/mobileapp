//
//  Feedback.swift
//  ClubAfib
//
//  Created by Rener on 8/14/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

class Feedback: Object {
    
    @objc dynamic var id = 0
    @objc dynamic var patient_id = 0
    @objc dynamic var patient : Patient!
    @objc dynamic var chat_id : String!
    @objc dynamic var rating : Double = 0.0
    @objc dynamic var detail : String?
    @objc dynamic var create_date : Date?
    
    required override init() {
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    init(_ item : JSON){
        self.id                     = item["id"].intValue
        self.patient_id             = item["patient_id"].intValue
        self.patient                = Patient(item["patient"])
        self.chat_id                = item["chat_id"].stringValue
        self.rating                 = item["rating"].doubleValue
        self.detail                 = item["description"].stringValue
        self.create_date            = item["createdAt"].date
        
        super.init()

        try! RealmManager.default.realm.write {
            RealmManager.default.realm.add(self, update: .modified)
        }
    }
    
}
