//
//  VirticalArrangedChartDataProvider.swift
//  ClubAfib
//
//  Created by Rener on 8/4/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit

@objc
public protocol VirticalArrangedChartDataProvider: LineChartDataProvider, BarChartDataProvider, BubbleChartDataProvider, CandleChartDataProvider, ScatterChartDataProvider, RangeBarChartDataProvider
{
    var arrangedData: VirticalArrangedChartData? { get }
}
