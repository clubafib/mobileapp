//
//  ChartUtils.swift
//  ClubAfib
//
//  Created by Rener on 7/25/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit

let minuteInSeconds: Double = 60
let hourInSeconds: Double = 60 * minuteInSeconds
let dayInSeconds: Double = 24 * hourInSeconds

func GetDateFromChartEntryX(value: Double, type: ChartDataViewType) -> Date {
    let df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd"
    let startDt = df.date(from: "2020-01-01")!
    var date = Date()
    switch type {
    case .Day:
        date = Date(timeInterval: value * hourInSeconds, since: startDt)
        break
    case .Week:
        date = Date(timeInterval: value * dayInSeconds, since: startDt)
        break
    case .Month:
        date = Date(timeInterval: value * dayInSeconds, since: startDt)
        break
    default: //.Year
        let year = Int(floor(value / 12)), month = Int(floor(value)) % 12 + 1
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy M"
        date = formatter.date(from: "\(year) \(month)") ?? date
        break
    }
    
    return date
}

//func GetXValueFromDate(date: Date, type: ChartDataViewType) -> Double {
//    switch type {
//    case .Day:
//        return round(date.timeIntervalSince1970 / hourInSeconds)
//    case .Week:
//        return round(date.timeIntervalSince1970 / dayInSeconds)
//    case .Month:
//        return round(date.timeIntervalSince1970 / dayInSeconds)
//    case .Year:
//        let component = Calendar.current.dateComponents([.year, .month], from: date)
//        return Double((component.year! - (component.month! == 12 ? 1 : 0)) * 12 + component.month! - 1)
//    default: //.Hour
//        return round(date.timeIntervalSince1970 / minuteInSeconds)
//    }
//}

func GetXValueFromDate(date: Date, type: ChartDataViewType) -> Double {
    let df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd"
    let startDt = df.date(from: "2020-01-01")
    switch type {
    case .Day:
        df.dateFormat = "yyyy-MM-dd HH"
        let strDt = df.string(from: date)
        let interval = df.date(from: strDt)!.timeIntervalSince(startDt!)
        return interval / hourInSeconds
    case .Week:
        df.dateFormat = "yyyy-MM-dd"
        let strDt = df.string(from: date)
        let interval = df.date(from: strDt)!.timeIntervalSince(startDt!)
        return interval / dayInSeconds
    case .Month:
        df.dateFormat = "yyyy-MM-dd"
        let strDt = df.string(from: date)
        let interval = df.date(from: strDt)!.timeIntervalSince(startDt!)
        return interval / dayInSeconds
    case .Year:
        let component = Calendar.current.dateComponents([.year, .month], from: date)
        return Double((component.year! - (component.month! == 12 ? 1 : 0)) * 12 + component.month! - 1)    
    }
}
