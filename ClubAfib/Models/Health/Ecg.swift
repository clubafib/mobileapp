//
//  Ecg.swift
//  ClubAfib
//
//  Created by mac on 9/30/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import Foundation
import HealthKit
import RealmSwift
import SwiftyJSON
import ByteBackpacker

class Ecg : Codable {
    @objc dynamic var id = 0
    
    var type: Int = 0
    var date: Date {
        get{
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
            return df.date(from: self.dateTxt)!
        }
        
        set(newValue) {
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
            self.dateTxt = df.string(from: newValue)
        }
    }
    var dateTxt = "1970-01-01 00:00:00"
    var avgHeartRate:Double = 0
//    var voltages = [EcgItem]()
    var file_url = ""
    
    var status = 0
        
    enum CodingKeys: String, CodingKey {
        case type
        case dateTxt = "date"
        case avgHeartRate
        case file_url
    }
    
    init(_ item : JSON){
        self.type                     = item["type"].intValue
        self.dateTxt                   = item["date"].string!        
        self.avgHeartRate                  = item["avgHeartRate"].doubleValue
        self.file_url     = item["file_url"].string!
    }

    init() {
        
    }
    
    public func setVoltages() {
        if let fileName = UserDefaults.standard.string(forKey: self.file_url) {
            let filePath = getDocumentsDirectory().appendingPathComponent(fileName)
            if FileManager.default.fileExists(atPath: filePath.path) {
//                if let data = try? Data(contentsOf: filePath) {
//                    self.setVoltagesFromData(data)
                    return
//                }
            }
        }
        let fileName = UUID().uuidString
        let filePath = getDocumentsDirectory().appendingPathComponent(fileName)
//        if voltages.count > 0 {
//            let data = getVoltageData()
//            try? data.write(to: filePath)
//            UserDefaults.standard.setValue(fileName, forKey: self.file_url)
//            return
//        }
        DispatchQueue.global(qos: .background).async {
            if let data = try? Data(contentsOf: URL(string: self.file_url)!) {
                try? data.write(to: filePath)
                UserDefaults.standard.setValue(fileName, forKey: self.file_url)
//                self.setVoltagesFromData(data)
            }
        }        
    }
    
    public func getVoltageData() -> Data {
//        var array = [UInt8]()
//        for item in voltages {
//            array.append(contentsOf: ByteBackpacker.pack(item.time))
//            array.append(contentsOf: ByteBackpacker.pack(item.value))
//        }
//        var data = Data()
//        data.append(contentsOf: array)
//        return data
        if let fileName = UserDefaults.standard.string(forKey: self.file_url) {
            let filePath = getDocumentsDirectory().appendingPathComponent(fileName)
            if FileManager.default.fileExists(atPath: filePath.path) {
                if let data = try? Data(contentsOf: filePath) {
                    return data
                }
            }
        }
        return Data()
    }
    
    func getVoltagesFromData(_ data:Data) -> [EcgItem] {
//        self.voltages.removeAll()
        var array = [EcgItem]()
        let byteAry = [Byte](data)
        let cnt = byteAry.count / 16
        for i in 0..<cnt {
            let idx = i * 16
            var bytes = Array(byteAry[idx..<(idx + 8)])
            let time = ByteBackpacker.unpack(bytes) as Double
            bytes = Array(byteAry[(idx + 8)..<(idx + 16)])
            let value = ByteBackpacker.unpack(bytes) as Double
            let ecgItem = EcgItem(time, value: value)
//            self.voltages.append(ecgItem)
            array.append(ecgItem)
        }
        return array
    }

    ///////////////// Static Methods ////////////////////
    class func set(_ data: [Ecg]) {
//        data.forEach { (item) in
//            item.voltages.removeAll()
//        }
        
        let encoder = JSONEncoder()
        let json = try? encoder.encode(data)
        let filename = getDocumentsDirectory().appendingPathComponent(UserInfo.sharedInstance.userData.email + "ecg")
        try! json?.write(to: filename)
    }
    
    class func get() -> [Ecg] {
        let filename = getDocumentsDirectory().appendingPathComponent(UserInfo.sharedInstance.userData.email + "ecg")
        do {
            let json = try Data(contentsOf: filename)
            let decoder = JSONDecoder()
            if let ret = try? decoder.decode([Ecg].self, from: json) {
                ret.forEach { (item) in
                    item.setVoltages()
                }
                return ret
            } else {
                return [Ecg]()
            }
        } catch{
            return [Ecg]()
        }
    }
    
    static func append(_ data:[Ecg]) {
        var org = Ecg.get()
        var compareAry = [Ecg]()
        if let first = data.first {
            compareAry = org.filter { (ecg) -> Bool in
                return ecg.date > first.date
            }
        }
        var newAry = [Ecg]()
        newAry.reserveCapacity(data.count)
        
        for newItem in data {
            let contains = compareAry.contains { (ecg) -> Bool in
                return ecg.id == newItem.id
            }
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
        let filename = getDocumentsDirectory().appendingPathComponent(UserInfo.sharedInstance.userData.email + "ecg")
        try! json?.write(to: filename)        
    }
}

class EcgItem: Object, Codable {
    var time: TimeInterval = 0
    var value: Double = 0
    
    init(_ item : JSON){
        self.value                     = item["v"].double!
        self.time                   = item["t"].double!
    }
    
    init(_ time:Double, value:Double) {
        self.time = time
        self.value = value
    }
    
    enum CodingKeys: String, CodingKey {        
        case value = "v"
        case time = "t"
    }
    
    required override init() {
        
    }
}

func getECGDic(_ val:[Ecg]) -> [Any]! {
    let encoder = JSONEncoder()
    let json = try? encoder.encode(val)
    return convertToDictionary(data: json!)
}

func getECGFromDic(_ dic:[String: Any]) -> [Ecg]?{
    do {
        let json = try? JSONSerialization.data(withJSONObject: dic, options:[])
        let decoder = JSONDecoder()
        return try? decoder.decode([Ecg].self, from: json!)
    } catch {
        return nil
    }
}

func convertToDictionary(data: Data) -> [Any]? {
    do {
        return try JSONSerialization.jsonObject(with: data, options: []) as? [Any]
    } catch {
        print(error.localizedDescription)
    }
    return nil
}

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

