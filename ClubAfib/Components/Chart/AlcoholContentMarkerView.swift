//
//  AlcoholContentMarkerView.swift
//  ClubAfib
//
//  Created by Rener on 8/5/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit

class AlcoholContentMarkerView: BalloonMarker {
    fileprivate var yFormatter = NumberFormatter()
    let months = ["Jan", "Feb", "Mar",
                  "Apr", "May", "Jun",
                  "Jul", "Aug", "Sep",
                  "Oct", "Nov", "Dec"]
    
    var currentXAxisType: ChartDataViewType = .Day
    
    public override init(color: UIColor, font: UIFont, textColor: UIColor, insets: UIEdgeInsets) {
        yFormatter.maximumFractionDigits = 2
        
        super.init(color: color, font: font, textColor: textColor, insets: insets)
    }
    
    public override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        let date = GetDateFromChartEntryX(value: entry.x, type: currentXAxisType)
        let df = DateFormatter()
        var strDate = ""
        var strAlcoholContent = ""
        
        if let candleEntry = entry as? CandleChartDataEntry {
            strAlcoholContent = candleEntry.low == candleEntry.high ? "\(yFormatter.string(from: NSNumber(value: candleEntry.high))!) times\n" : "\(yFormatter.string(from: NSNumber(value: candleEntry.low))!)-\(yFormatter.string(from: NSNumber(value: candleEntry.high))!) times\n"
        }
        else if let rangeBarEntry = entry as? RangeBarChartDataEntry {
            strAlcoholContent = rangeBarEntry.start == rangeBarEntry.end ? "\(yFormatter.string(from: NSNumber(value: rangeBarEntry.end))!) times\n" : "\(yFormatter.string(from: NSNumber(value: rangeBarEntry.start))!)-\(yFormatter.string(from: NSNumber(value: rangeBarEntry.end))!) times\n"
        }
        
        switch currentXAxisType {
        case .Day:
            df.dateFormat = "MMM dd, h {1} a {2}"
            break
        case .Week:
            df.dateFormat = "MMM dd, yyyy"
            break
        case .Month:
            df.dateFormat = "MMM dd, yyyy"
            break
        default:
            df.dateFormat = "MMM, yyyy"
            break
        }
        strDate = df.string(from: date)
        
        if (currentXAxisType == .Day) {
            let hour = Calendar.current.component(.hour, from: date)
            if (hour == 23) {
                strDate = strDate.replacingOccurrences(of: "{1}", with: "")
                strDate = strDate.replacingOccurrences(of: "{2}", with: "- 12 AM")
            }
            else if (hour == 11) {
                strDate = strDate.replacingOccurrences(of: "{1}", with: "")
                strDate = strDate.replacingOccurrences(of: "{2}", with: "- 12 PM")
            }
            else {
                strDate = strDate.replacingOccurrences(of: "{1}", with: "- \(hour % 12 + 1)")
                strDate = strDate.replacingOccurrences(of: "{2}", with: "")
            }
        }
        else if (currentXAxisType == .Year) {
            strDate = "\(months[Int(entry.x) % 12]), \(Int(floor(entry.x / 12)))"
        }
        
        let string = strAlcoholContent + strDate
        setLabel(string)
    }
    
}

