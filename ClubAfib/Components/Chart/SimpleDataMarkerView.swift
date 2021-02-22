//
//  BarChartMakerView.swift
//  ClubAfib
//
//  Created by Rener on 8/5/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit

public class SimpleDataMarkerView: BalloonMarker {
    fileprivate var yFormatter = NumberFormatter()
    let months = ["Jan", "Feb", "Mar",
                  "Apr", "May", "Jun",
                  "Jul", "Aug", "Sep",
                  "Oct", "Nov", "Dec"]
    
    var currentXAxisType: ChartDataViewType = .Day
    var healthType: HealthCategoryType = .HeartRate
    
    public override init(color: UIColor, font: UIFont, textColor: UIColor, insets: UIEdgeInsets) {
        yFormatter.numberStyle = .decimal
        yFormatter.groupingSeparator = ","
        yFormatter.maximumFractionDigits = 0
        
        super.init(color: color, font: font, textColor: textColor, insets: insets)
    }
    
    public override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        let date = GetDateFromChartEntryX(value: entry.x, type: currentXAxisType)
        let df = DateFormatter()
        var valueFormatter = yFormatter
        var measurement = ""
        var strDate = ""
        
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
        
        switch healthType {
        case .ActivityMove:
            measurement = "kcal"
            break
        case .ActivityExercise:
            measurement = "min"
            break
        case .ActivityStand:
            measurement = "hr"
            break
        case .BodyWeight:
            measurement = "lbs"
            
            valueFormatter = NumberFormatter()
            valueFormatter.maximumFractionDigits = 1
            
            break
        case .Steps:
            measurement = entry.y < 2 ? " step" : " steps"
            break
        case .Sleep:
            let hours = Int(floor(entry.y / 60.0))
            let mins = Int(round(entry.y)) % 60
            let hasHours = hours > 0
            
            let string = (hasHours ? "\(hours) hr " : "")
                + "\(mins) min\n"
                + strDate
            setLabel(string)
            return
        case .AlcoholUse:
            measurement = entry.y < 2 ? " drink" : " drinks"
            break
        default:
            break
        }
        
        let string = valueFormatter.string(from: NSNumber(floatLiteral: entry.y))!
            + " " + measurement + "\n"
            + strDate
        setLabel(string)
    }
    
}
