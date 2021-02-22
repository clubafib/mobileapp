//
//  PeriodTimeAxisValueFormatter.swift
//  ClubAfib
//
//  Created by Rener on 9/3/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit

class PeriodTimeAxisValueFormatter: NSObject, IAxisValueFormatter {
    
    weak var chart: BarLineChartViewBase?
    private var formatter = NumberFormatter()
    
    init(chart: BarLineChartViewBase) {
        self.chart = chart
        self.formatter.numberStyle = .decimal
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let hours = round(value / 60.0)

        return "\(self.formatter.string(from: NSNumber(floatLiteral: hours))!) hrs"
    }
}
