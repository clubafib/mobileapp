//
//  Sleep.swift
//  ClubAfib
//
//  Created by Rener on 9/3/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

class Sleep: Object {
    
    @objc dynamic var id = 0
    @objc dynamic var UUID = ""
    @objc dynamic var start : Date = Date()
    @objc dynamic var end : Date = Date()
    @objc dynamic var type = 0
    @objc dynamic var status = 0
    
    required override init() {
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    init(_ item : JSON){
        self.id                     = item["id"].intValue
        self.UUID                   = item["uuid"].stringValue
        self.start                  = item["start"].dateValue
        self.end                    = item["end"].dateValue
        self.type                   = item["type"].intValue
        self.status                 = item["status"].intValue
    }
    
    
    class func setSleep(_ sleep: Sleep) {
        try! RealmManager.default.realm.write {
            RealmManager.default.realm.add(sleep, update: .modified)
        }
    }
    
    class func setSleeps(_ sleeps: [Sleep]) {
        try! RealmManager.default.realm.write {
            RealmManager.default.realm.add(sleeps, update: .modified)
        }
    }
    
    class func setSleepsAsync(_ realm: Realm, _ sleeps: [Steps]) {
        try! realm.write {
            realm.add(sleeps, update: .modified)
        }
    }
    
    class func getSleeps() -> Results<Sleep> {
        return RealmManager.default.realm.objects(Sleep.self)
    }
    
    class func getSleepsAsync(_ realm: Realm) -> Results<Sleep> {
        return realm.objects(Sleep.self)
    }
    
}
