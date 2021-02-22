//
//  BloodPressure.swift
//  ClubAfib
//
//  Created by Rener on 8/21/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

class BloodPressure: Object, RangeValueHealthData {
    
    @objc dynamic var id = 0
    @objc dynamic var date : Date = Date()
    @objc dynamic var sysUUID = ""
    @objc dynamic var systolic : Double = 0.0
    @objc dynamic var diaUUID = ""
    @objc dynamic var diastolic : Double = 0.0
    @objc dynamic var status = 0
    
    var high: Double {
        get {
            return systolic
        }
    }
    
    var low: Double {
        get {
            return diastolic
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
        self.sysUUID                = item["sys_uuid"].stringValue
        self.systolic               = item["systolic"].doubleValue
        self.diaUUID                = item["dia_uuid"].stringValue
        self.diastolic              = item["diastolic"].doubleValue
        self.status                 = item["status"].intValue
    }
    
    
    class func setBloodPressure(_ bloodPressure: BloodPressure) {
        try! RealmManager.default.realm.write {
            RealmManager.default.realm.add(bloodPressure, update: .modified)
        }
    }
    
    class func setBloodPressures(_ bloodPressures: [BloodPressure]) {
        try! RealmManager.default.realm.write {
            RealmManager.default.realm.add(bloodPressures, update: .modified)
        }
    }
    
    class func setBloodPressuresAsync(_ realm: Realm, _ bloodPressures: [BloodPressure]) {
        try! realm.write {
            realm.add(bloodPressures, update: .modified)
        }
    }
    
    class func getBloodPressures() -> Results<BloodPressure> {
        return RealmManager.default.realm.objects(BloodPressure.self)
    }
    
    class func getBloodPressuresAsync(_ realm: Realm) -> Results<BloodPressure> {
        return realm.objects(BloodPressure.self)
    }

}
