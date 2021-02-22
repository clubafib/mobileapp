//
//  Exercise.swift
//  ClubAfib
//
//  Created by Rener on 8/21/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

class Exercise: Object, SingleValueHealthData {
    
    @objc dynamic var id = 0
    @objc dynamic var date : Date = Date()
    @objc dynamic var exercise : Double = 0.0
    @objc dynamic var status = 0
    
    var value: Double {
        get {
            return exercise
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
        self.exercise               = item["exercise"].doubleValue
        self.status                 = item["status"].intValue
    }
    
    
    class func setExercises(_ exercises: [Exercise]) {
        try! RealmManager.default.realm.write {
            RealmManager.default.realm.add(exercises, update: .modified)
        }
    }
    
    class func setExercisesAsync(_ realm: Realm, _ exercises: [Exercise]) {
        try! realm.write {
            realm.add(exercises, update: .modified)
        }
    }
    
    class func getExercises() -> Results<Exercise> {
        return RealmManager.default.realm.objects(Exercise.self)
    }
    
    class func getExercisesAsync(_ realm: Realm) -> Results<Exercise> {
        return realm.objects(Exercise.self)
    }
    
}
