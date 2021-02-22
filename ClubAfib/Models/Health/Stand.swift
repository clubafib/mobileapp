//
//  Stand.swift
//  ClubAfib
//
//  Created by Rener on 8/21/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

class Stand: Object, SingleValueHealthData {
    
    @objc dynamic var id = 0
    @objc dynamic var date : Date = Date()
    @objc dynamic var stand : Double = 0.0
    @objc dynamic var status = 0
    
    var value: Double {
        get {
            return stand
        }
    }
    
    required override init() {
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    init(_ item : JSON){
        self.id                     = item["id"].intValue
        self.date                   = item["date"].dateValue
        self.stand                  = item["stand"].doubleValue
        self.status                 = item["status"].intValue
    }
    
    
    class func setStands(_ stands: [Stand]) {
        try! RealmManager.default.realm.write {
            RealmManager.default.realm.add(stands, update: .modified)
        }
    }
    
    class func setStandsAsync(_ realm: Realm, _ stands: [Stand]) {
        try! realm.write {
            realm.add(stands, update: .modified)
        }
    }
    
    class func getStands() -> Results<Stand> {
        return RealmManager.default.realm.objects(Stand.self)
    }
    
    class func getStandsAsync(_ realm: Realm) -> Results<Stand> {
        return realm.objects(Stand.self)
    }
    
}
