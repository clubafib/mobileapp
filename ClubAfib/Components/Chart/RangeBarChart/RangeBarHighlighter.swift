//
//  RangeBarHighlighter.swift
//  ClubAfib
//
//  Created by Rener on 8/4/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit

@objc(RangeBarChartHighlighter)
open class RangeBarHighlighter: ChartHighlighter
{
    open override func getHighlight(x: CGFloat, y: CGFloat) -> Highlight?
    {
        guard
            let rangeBarData = (self.chart as? RangeBarChartDataProvider)?.rangeBarData,
            let high = super.getHighlight(x: x, y: y)
            else { return nil }
        
        let pos = getValsForTouch(x: x, y: y)

        if let set = rangeBarData.getDataSetByIndex(high.dataSetIndex) as? IRangeBarChartDataSet,
            set.isStacked
        {
            return getStackedHighlight(high: high,
                                       set: set,
                                       xValue: Double(pos.x),
                                       yValue: Double(pos.y))
        }
        else
        {
            return high
        }
    }
    
    internal override func getDistance(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat) -> CGFloat
    {
        return abs(x1 - x2)
    }
    
    internal override var data: ChartData?
    {
        return (chart as? RangeBarChartDataProvider)?.rangeBarData
    }
    
    /// This method creates the Highlight object that also indicates which value of a stacked BarEntry has been selected.
    ///
    /// - Parameters:
    ///   - high: the Highlight to work with looking for stacked values
    ///   - set:
    ///   - xIndex:
    ///   - yValue:
    /// - Returns:
    @objc open func getStackedHighlight(high: Highlight,
                                  set: IRangeBarChartDataSet,
                                  xValue: Double,
                                  yValue: Double) -> Highlight?
    {
        guard
            let chart = self.chart as? BarLineScatterCandleBubbleChartDataProvider,
            let entry = set.entryForXValue(xValue, closestToY: yValue) as? RangeBarChartDataEntry
            else { return nil }
        
        // Not stacked
        if entry.ranges == nil
        {
            return high
        }
        
        guard
            let ranges = entry.ranges,
            ranges.count > 0
            else { return nil }

        let stackIndex = getClosestStackIndex(ranges: ranges, value: yValue)
        let pixel = chart
            .getTransformer(forAxis: set.axisDependency)
            .pixelForValues(x: high.x, y: ranges[stackIndex].to)

        return Highlight(x: entry.x,
                         y: entry.y,
                         xPx: pixel.x,
                         yPx: pixel.y,
                         dataSetIndex: high.dataSetIndex,
                         stackIndex: stackIndex,
                         axis: high.axis)
    }
    
    /// - Parameters:
    ///   - entry:
    ///   - value:
    /// - Returns: The index of the closest value inside the values array / ranges (stacked barchart) to the value given as a parameter.
    @objc open func getClosestStackIndex(ranges: [Range]?, value: Double) -> Int
    {
        guard let ranges = ranges else { return 0 }
        if let stackIndex = ranges.firstIndex(where: { $0.contains(value) }) {
            return stackIndex
        } else {
            let length = max(ranges.count - 1, 0)
            return (value > ranges[length].to) ? length : 0
        }
    }
}
