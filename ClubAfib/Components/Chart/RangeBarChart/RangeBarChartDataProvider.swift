//
//  RangeBarChartDataProvider.swift
//  ClubAfib
//
//  Created by Rener on 7/29/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit

@objc
public protocol RangeBarChartDataProvider: BarLineScatterCandleBubbleChartDataProvider
{
    var rangeBarData: RangeBarChartData? { get }
    
    var isDrawBarShadowEnabled: Bool { get }
    var isDrawValueAboveBarEnabled: Bool { get }
    var isHighlightFullBarEnabled: Bool { get }
}
