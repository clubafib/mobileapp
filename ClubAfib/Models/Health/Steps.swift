//
//  Steps.swift
//  ClubAfib
//
//  Created by Rener on 8/20/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

class Steps: Object, SingleValueHealthData {
    
    @objc dynamic var id = 0
    @objc dynamic var date : Date = Date()
    @objc dynamic var steps : Double = 0.0
    @objc dynamic var status = 0
    
    var value: Double {
        get {
            return steps
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
        self.steps                  = item["steps"].doubleValue
        self.status                 = item["status"].intValue
    }
    
    
    class func setSteps(_ steps: [Steps]) {
        try! RealmManager.default.realm.write {
            RealmManager.default.realm.add(steps, update: .modified)
        }
    }
    
    class func setStepsAsync(_ realm: Realm, _ steps: [Steps]) {
        try! realm.write {
            realm.add(steps, update: .modified)
        }
    }
    
    class func getSteps() -> Results<Steps> {
        return RealmManager.default.realm.objects(Steps.self)
    }
    
    class func getStepsAsync(_ realm: Realm) -> Results<Steps> {
        return realm.objects(Steps.self)
    }
    
}
