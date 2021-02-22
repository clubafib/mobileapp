//
//  DayAxisValueFormatter.swift
//  ClubAfib
//
//  Created by Rener on 7/22/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit

public class DayAxisValueFormatter: NSObject, IAxisValueFormatter {
    weak var chart: BarLineChartViewBase?
    let months = ["Jan", "Feb", "Mar",
                  "Apr", "May", "Jun",
                  "Jul", "Aug", "Sep",
                  "Oct", "Nov", "Dec"]
    
    var currentXAxisType: ChartDataViewType = .Day
    
    init(chart: BarLineChartViewBase) {
        self.chart = chart
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let df = DateFormatter()
        var date = GetDateFromChartEntryX(value: value, type: currentXAxisType)
        switch currentXAxisType {
        case .Day:
            df.dateFormat = "h a"
            date.addTimeInterval(3600 * 2)
            break
        case .Week:
            df.dateFormat = "EEE"
            break
        case .Month:
            df.dateFormat = "dd"
            date.addTimeInterval(3600 * 24 * 5)
            break
        default:
            df.dateFormat = "MM"
            let component = Calendar.current.dateComponents([.year, .month], from: date)
            var nextMonth = component.month! + 1
            if nextMonth > 12 {
                nextMonth = 1
            }
            let dtStr = String(format: "%02d", nextMonth)
            let nextdate = df.date(from: dtStr)!
            df.dateFormat = "MMM"
            return df.string(from: date) + "-" + df.string(from: nextdate)
        }
        return df.string(from: date)
    }
}
