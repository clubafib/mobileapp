//
//  EnergyBurn.swift
//  ClubAfib
//
//  Created by Rener on 8/21/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

class EnergyBurn: Object, SingleValueHealthData {
    
    @objc dynamic var id = 0
    @objc dynamic var date : Date = Date()
    @objc dynamic var energy : Double = 0.0
    @objc dynamic var status = 0
    
    var value: Double {
        get {
            return energy
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
        self.energy                 = item["energy"].doubleValue
        self.status                 = item["status"].intValue
    }
    
    
    class func setEnergyBurned(_ energyBurned: [EnergyBurn]) {
        try! RealmManager.default.realm.write {
            RealmManager.default.realm.add(energyBurned, update: .modified)
        }
    }
    
    class func setEnergyBurnedAsync(_ realm: Realm, _ energyBurned: [EnergyBurn]) {
        try! realm.write {
            realm.add(energyBurned, update: .modified)
        }
    }
    
    class func getEnergyBurned() -> Results<EnergyBurn> {
        return RealmManager.default.realm.objects(EnergyBurn.self)
    }
    
    class func getEnergyBurnedAsync(_ realm: Realm) -> Results<EnergyBurn> {
        return realm.objects(EnergyBurn.self)
    }
    
}
