//
//  JSON.swift
//  ClubAfib
//
//  Created by Rener on 8/14/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit
import SwiftyJSON

extension JSON {
    public var date: Date? {
        get {
            if let str = self.string {
                return JSON.jsonDateFormatter.date(from: str)
            }
            return nil
        }
    }
    
    public var dateValue: Date {
        get {
            if let str = self.string {
                return JSON.jsonDateFormatter.date(from: str) ?? Date()
            }
            return Date()
        }
    }

    private static let jsonDateFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        fmt.timeZone = TimeZone(secondsFromGMT: 0)
        return fmt
    }()
}
