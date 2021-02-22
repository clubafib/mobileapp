//
//  HeartRate.swift
//  ClubAfib
//
//  Created by Rener on 8/19/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

class HeartRate: Codable, SingleValueHealthData {
    
    @objc dynamic var id = 0
    @objc dynamic var date: Date {
        get{
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
            if let dt = df.date(from: self.dateTxt) {
                return dt
            } else {
                return Date()
            }
        }
        
        set(newValue) {
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
            self.dateTxt = df.string(from: newValue)            
        }
    }
    var dateTxt = "1970-01-01T00:00:00-00:00"
    @objc dynamic var heart_rate : Double = 0.0
    @objc dynamic var status = 0
    
    var value: Double {
        get {
            return heart_rate
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case dateTxt = "date"
        case heart_rate
        case status
    }
    
    init() {
        
    }
    
    init(_ item : JSON){
        self.id                     = item["id"].intValue
        self.dateTxt                   = item["date"].string!
        self.heart_rate             = item["heart_rate"].doubleValue
        self.status                 = item["status"].intValue
    }
    
//    class func set(_ data: [HeartRate]) {
//        let encoder = JSONEncoder()
//        let json = try? encoder.encode(data)
//        let filename = getDocumentsDirectory().appendingPathComponent(UserInfo.sharedInstance.userData.email + "hr")
//        try! json?.write(to: filename)
//    }
    
    class func get() -> [HeartRate] {
        let filename = getDocumentsDirectory().appendingPathComponent(UserInfo.sharedInstance.userData.email + "hr")
        do {
            let json = try Data(contentsOf: filename)
            let decoder = JSONDecoder()
            return try! decoder.decode([HeartRate].self, from: json)
        } catch{
            return [HeartRate]()
        }
    }
    
    static func append(_ data:[HeartRate]) {
        var org = HeartRate.get()
        var newAry = [HeartRate]()
        newAry.reserveCapacity(data.count)
        var compareAry = [HeartRate]()
        if let first = data.first {
            compareAry = org.filter { (hr) -> Bool in
                return hr.date > first.date
            }
        }
                
        for newItem in data {
            let contains = compareAry.contains { (hr) -> Bool in
                return hr.id == newItem.id && hr.heart_rate == hr.heart_rate }
            if !contains {
                newAry.append(newItem)
            }
        }
        if newAry.count == 0 {
            return
        }
        org.append(contentsOf: newAry)
        org.sort { (left, right) -> Bool in
            return left.date < right.date
        }
        let encoder = JSONEncoder()
        let json = try? encoder.encode(org)
        let filename = getDocumentsDirectory().appendingPathComponent(UserInfo.sharedInstance.userData.email + "hr")
        try! json?.write(to: filename)
    }
}
