//
//  AlcoholUse.swift
//  ClubAfib
//
//  Created by Rener on 8/20/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

class AlcoholUse: Object, SingleValueHealthData {
    
    @objc dynamic var id = 0
    @objc dynamic var date : Date = Date()
    @objc dynamic var alcohol : Double = 0.0
    @objc dynamic var status = 0
    
    var value: Double {
        get {
            return alcohol
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
        self.alcohol                = item["alcohol"].doubleValue
        self.status                 = item["status"].intValue
    }
    
    
    class func setAlcoholUse(_ alcoholUse: AlcoholUse) {
        try! RealmManager.default.realm.write {
            RealmManager.default.realm.add(alcoholUse, update: .modified)
        }
    }
    
    class func setAlcoholUses(_ steps: [AlcoholUse]) {
        try! RealmManager.default.realm.write {
            RealmManager.default.realm.add(steps, update: .modified)
        }
    }
    
    class func setAlcoholUses(_ realm: Realm, _ steps: [AlcoholUse]) {
        try! realm.write {
            realm.add(steps, update: .modified)
        }
    }
    
    class func getAlcoholUses() -> Results<AlcoholUse> {
        return RealmManager.default.realm.objects(AlcoholUse.self)
    }
    
    class func getAlcoholUsesAsync(_ realm: Realm) -> Results<AlcoholUse> {
        return realm.objects(AlcoholUse.self)
    }

}
