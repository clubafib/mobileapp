//
//  VirticalArrangedChartView.swift
//  ClubAfib
//
//  Created by Rener on 8/4/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit

open class VirticalArrangedChartView: BarLineChartViewBase, VirticalArrangedChartDataProvider
{
    /// the fill-formatter used for determining the position of the fill-line
    internal var _fillFormatter: IFillFormatter!
    
    /// enum that allows to specify the order in which the different data objects for the arranged-chart are drawn
    @objc(VirticalArrangedChartDrawOrder)
    public enum DrawOrder: Int
    {
        case bar
        case bubble
        case line
        case candle
        case scatter
        case rangeBar
    }
    
    open override func initialize()
    {
        super.initialize()
        
        self.highlighter = VirticalArrangedHighlighter(chart: self, barDataProvider: self)
        
        // Old default behaviour
        self.highlightFullBarEnabled = true
        
        _fillFormatter = DefaultFillFormatter()
        
        renderer = VirticalArrangedChartRenderer(chart: self, animator: _animator, viewPortHandler: _viewPortHandler)
    }
    
    open override var data: ChartData?
    {
        get
        {
            return super.data
        }
        set
        {
            super.data = newValue
            
            self.highlighter = VirticalArrangedHighlighter(chart: self, barDataProvider: self)
            
            (renderer as? VirticalArrangedChartRenderer)?.createRenderers()
            renderer?.initBuffers()
        }
    }
    
    @objc open var fillFormatter: IFillFormatter
    {
        get
        {
            return _fillFormatter
        }
        set
        {
            _fillFormatter = newValue
            if _fillFormatter == nil
            {
                _fillFormatter = DefaultFillFormatter()
            }
        }
    }
    
    /// - Returns: The Highlight object (contains x-index and DataSet index) of the selected value at the given touch point inside the VirticalArrangedChart.
    open override func getHighlightByTouchPoint(_ pt: CGPoint) -> Highlight?
    {
        if _data === nil
        {
            Swift.print("Can't select by touch. No data set.")
            return nil
        }
        
        guard let h = self.highlighter?.getHighlight(x: pt.x, y: pt.y)
            else { return nil }
        
        if !isHighlightFullBarEnabled { return h }
        
        // For isHighlightFullBarEnabled, remove stackIndex
        return Highlight(
            x: h.x, y: h.y,
            xPx: h.xPx, yPx: h.yPx,
            dataIndex: h.dataIndex,
            dataSetIndex: h.dataSetIndex,
            stackIndex: -1,
            axis: h.axis)
    }
    
    // MARK: - VirticalArrangedChartDataProvider
    
    open var arrangedData: VirticalArrangedChartData?
    {
        get
        {
            return _data as? VirticalArrangedChartData
        }
    }
    
    // MARK: - LineChartDataProvider
    
    open var lineData: LineChartData?
    {
        get
        {
            return arrangedData?.lineData
        }
    }
    
    // MARK: - BarChartDataProvider
    
    open var barData: BarChartData?
    {
        get
        {
            return arrangedData?.barData
        }
    }
    
    // MARK: - ScatterChartDataProvider
    
    open var scatterData: ScatterChartData?
    {
        get
        {
            return arrangedData?.scatterData
        }
    }
    
    // MARK: - CandleChartDataProvider
    
    open var candleData: CandleChartData?
    {
        get
        {
            return arrangedData?.candleData
        }
    }
    
    // MARK: - BubbleChartDataProvider
    
    open var bubbleData: BubbleChartData?
    {
        get
        {
            return arrangedData?.bubbleData
        }
    }
    
    // MARK: - RangeBarChartDataProvider
    
    open var rangeBarData: RangeBarChartData?
    {
        get
        {
            return arrangedData?.rangeBarData
        }
    }
    
    // MARK: - Accessors
    
    /// if set to true, all values are drawn above their bars, instead of below their top
    @objc open var drawValueAboveBarEnabled: Bool
        {
        get { return (renderer as! VirticalArrangedChartRenderer).drawValueAboveBarEnabled }
        set { (renderer as! VirticalArrangedChartRenderer).drawValueAboveBarEnabled = newValue }
    }
    
    /// if set to true, a grey area is drawn behind each bar that indicates the maximum value
    @objc open var drawBarShadowEnabled: Bool
    {
        get { return (renderer as! VirticalArrangedChartRenderer).drawBarShadowEnabled }
        set { (renderer as! VirticalArrangedChartRenderer).drawBarShadowEnabled = newValue }
    }
    
    /// `true` if drawing values above bars is enabled, `false` ifnot
    open var isDrawValueAboveBarEnabled: Bool { return (renderer as! VirticalArrangedChartRenderer).drawValueAboveBarEnabled }
    
    /// `true` if drawing shadows (maxvalue) for each bar is enabled, `false` ifnot
    open var isDrawBarShadowEnabled: Bool { return (renderer as! VirticalArrangedChartRenderer).drawBarShadowEnabled }
    
    /// the order in which the provided data objects should be drawn.
    /// The earlier you place them in the provided array, the further they will be in the background.
    /// e.g. if you provide [DrawOrder.Bar, DrawOrder.Line], the bars will be drawn behind the lines.
    @objc open var drawOrder: [Int]
    {
        get
        {
            return (renderer as! VirticalArrangedChartRenderer).drawOrder.map { $0.rawValue }
        }
        set
        {
            (renderer as! VirticalArrangedChartRenderer).drawOrder = newValue.map { DrawOrder(rawValue: $0)! }
        }
    }
    
    /// Set this to `true` to make the highlight operation full-bar oriented, `false` to make it highlight single values
    @objc open var highlightFullBarEnabled: Bool = false
    
    /// `true` the highlight is be full-bar oriented, `false` ifsingle-value
    open var isHighlightFullBarEnabled: Bool { return highlightFullBarEnabled }
    
    // MARK: - ChartViewBase
    
    /// draws all MarkerViews on the highlighted positions
    override func drawMarkers(context: CGContext)
    {
        guard
            let marker = marker,
            isDrawMarkersEnabled && valuesToHighlight()
            else { return }
        
        for i in 0 ..< _indicesToHighlight.count
        {
            let highlight = _indicesToHighlight[i]
            
            guard
                let set = arrangedData?.getDataSetByHighlight(highlight),
                let e = _data?.entryForHighlight(highlight)
                else { continue }
            
            let entryIndex = set.entryIndex(entry: e)
            if entryIndex > Int(Double(set.entryCount) * _animator.phaseX)
            {
                continue
            }
            
            let pos = getMarkerPosition(highlight: highlight)
            
            // check bounds
            if !_viewPortHandler.isInBounds(x: pos.x, y: pos.y)
            {
                continue
            }
            
            // callbacks to update the content
            marker.refreshContent(entry: e, highlight: highlight)
            
            // draw the marker
            marker.draw(context: context, point: pos)
        }
    }
}
