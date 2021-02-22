//
//  VirticalArrangedHighlighter.swift
//  ClubAfib
//
//  Created by Rener on 8/4/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit


@objc(VirticalArrangedChartHighlighter)
open class VirticalArrangedHighlighter: ChartHighlighter
{
    /// bar highlighter for supporting stacked highlighting
    private var barHighlighter: BarHighlighter?
    
    @objc public init(chart: VirticalArrangedChartDataProvider, barDataProvider: BarChartDataProvider)
    {
        super.init(chart: chart)
        
        // if there is BarData, create a BarHighlighter
        self.barHighlighter = barDataProvider.barData == nil ? nil : BarHighlighter(chart: barDataProvider)
    }
    
    open override func getHighlights(xValue: Double, x: CGFloat, y: CGFloat) -> [Highlight]
    {
        var vals = [Highlight]()
        
        guard
            let chart = self.chart as? VirticalArrangedChartDataProvider,
            let dataObjects = chart.arrangedData?.allData
            else { return vals }
        
        for i in 0..<dataObjects.count
        {
            let dataObject = dataObjects[i]

            // in case of BarData, let the BarHighlighter take over
            if barHighlighter != nil && dataObject is BarChartData,
                let high = barHighlighter?.getHighlight(x: x, y: y)
            {
                high.dataIndex = i
                vals.append(high)
            }
            else
            {
                for j in 0..<dataObject.dataSetCount
                {
                    guard let dataSet = dataObject.getDataSetByIndex(j),
                        dataSet.isHighlightEnabled      // don't include datasets that cannot be highlighted
                        else { continue }

                    let highs = buildHighlights(dataSet: dataSet, dataSetIndex: j, xValue: xValue, rounding: .closest)

                    for high in highs
                    {
                        high.dataIndex = i
                        vals.append(high)
                    }
                }
            }
        }
        
        return vals
    }
}
