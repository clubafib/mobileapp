//
//  Weight.swift
//  ClubAfib
//
//  Created by Rener on 8/20/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

class Weight: Object, SingleValueHealthData {
    
    @objc dynamic var id = 0
    @objc dynamic var UUID = ""
    @objc dynamic var date : Date = Date()
    @objc dynamic var weight : Double = 0.0
    @objc dynamic var status = 0
    
    var value: Double {
        get {
            return weight
        }
    }
    
    required override init() {
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    init(_ item : JSON){
        self.id                     = item["id"].intValue
        self.UUID                   = item["uuid"].stringValue
        self.date                   = item["date"].dateValue
        self.weight                 = item["weight"].doubleValue
        self.status                 = item["status"].intValue
    }
    
    
    class func setWeight(_ weight: Weight) {
        try! RealmManager.default.realm.write {
            RealmManager.default.realm.add(weight, update: .modified)
        }
    }
    
    class func setWeights(_ weights: [Weight]) {
        try! RealmManager.default.realm.write {
            RealmManager.default.realm.add(weights, update: .modified)
        }
    }
    
    class func setWeightsAsync(_ realm: Realm, _ weights: [Weight]) {
        try! realm.write {
            realm.add(weights, update: .modified)
        }
    }
    
    class func getWeights() -> Results<Weight> {
        return RealmManager.default.realm.objects(Weight.self)
    }
    
    class func getWeightsAsync(_ realm: Realm) -> Results<Weight> {
        return realm.objects(Weight.self)
    }
    
}
