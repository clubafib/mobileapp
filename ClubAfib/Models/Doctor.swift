//
//  Doctor.swift
//  ClubAfib
//
//  Created by Rener on 8/10/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

class Doctor: Object {
    
    @objc dynamic var userId = 0
    @objc dynamic var firstName : String?
    @objc dynamic var lastName : String?
    @objc dynamic var subject : String?
    @objc dynamic var email : String?
    @objc dynamic var imageUrl : String?
    @objc dynamic var language : String?
    @objc dynamic var address : String?
    @objc dynamic var phone : String?
    @objc dynamic var about : String?
    @objc dynamic var rating : Double = 0.0
    var feedbacks = List<Feedback>()
    
    required override init() {
    }
    
    override static func primaryKey() -> String? {
        return "userId"
    }
    
    init(_ item : JSON){
        self.userId                 = item["id"].intValue
        self.firstName              = item["first_name"].stringValue
        self.lastName               = item["last_name"].stringValue
        self.subject                = item["subject"].stringValue
        self.email                  = item["email"].stringValue
        self.imageUrl               = item["photo"].stringValue
        self.language               = item["language"].stringValue
        self.address                = item["address"].stringValue
        self.phone                  = item["phonenumber"].stringValue
        self.about                  = item["about"].stringValue
        self.rating                 = 0.0
        
        super.init()

        try! RealmManager.default.realm.write {
            RealmManager.default.realm.add(self, update: .modified)
        }
        
        var totalRating = 0.0
        if let feedbackArray = item["feedbacks"].array {
            var feedbacks = [Feedback]()
            for fbJson in feedbackArray {
                let feedback = Feedback(fbJson)
                totalRating += feedback.rating
                feedbacks.append(feedback)
            }
            try! RealmManager.default.realm.write {
                self.feedbacks.append(objectsIn: feedbacks.sorted(by: { $0.create_date!.compare($1.create_date!) == .orderedDescending }))
                if feedbackArray.count > 0 {
                    self.rating = totalRating / Double(feedbackArray.count)
                }
            }
        }
    }
    
    class func getDoctor(_ id: Int) -> Doctor? {
        return RealmManager.default.realm.object(ofType: Doctor.self, forPrimaryKey: id)
    }
    
    class func getDoctors() -> Results<Doctor> {
        return RealmManager.default.realm.objects(Doctor.self)
    }
}
