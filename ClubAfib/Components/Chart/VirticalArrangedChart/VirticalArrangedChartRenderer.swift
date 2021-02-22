//
//  VirticalArrangedChartRenderer.swift
//  ClubAfib
//
//  Created by Rener on 8/4/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit

open class VirticalArrangedChartRenderer: DataRenderer
{
    @objc open weak var chart: VirticalArrangedChartView?
    
    /// if set to true, all values are drawn above their bars, instead of below their top
    @objc open var drawValueAboveBarEnabled = true
    
    /// if set to true, a grey area is drawn behind each bar that indicates the maximum value
    @objc open var drawBarShadowEnabled = false
    
    internal var _renderers = [DataRenderer]()
    
    internal var _drawOrder: [VirticalArrangedChartView.DrawOrder] = [.bar, .bubble, .line, .candle, .scatter, .rangeBar]
    
    internal var _drawWeights: [Double] = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
    
    @objc public init(chart: VirticalArrangedChartView, animator: Animator, viewPortHandler: ViewPortHandler)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
        
        self.chart = chart
        
        createRenderers()
    }
    
    internal func getPartialViewPortHandler(weight: Double, lastWeight: Double, totalWeight: Double, originViewPortHandler: ViewPortHandler) -> ViewPortHandler {
        let viewPortHandler = ViewPortHandler(width: originViewPortHandler.chartWidth, height: originViewPortHandler.chartHeight * CGFloat(weight / totalWeight))
        
        viewPortHandler.restrainViewPort(offsetLeft: originViewPortHandler.offsetLeft, offsetTop: originViewPortHandler.chartHeight * CGFloat(lastWeight / totalWeight), offsetRight: originViewPortHandler.offsetRight, offsetBottom: originViewPortHandler.chartHeight * CGFloat((totalWeight - lastWeight - weight) / totalWeight))
        
        return viewPortHandler
    }
    
    /// Creates the renderers needed for this arranged-renderer in the required order. Also takes the DrawOrder into consideration.
    internal func createRenderers()
    {
        _renderers = [DataRenderer]()
        
        guard let chart = chart else { return }

        var weightIndex = 0, lastWeight = 0.0
        let totalWeight = drawWeights.reduce(0, +)
        
        for order in drawOrder
        {
            let weight = drawWeights.count > weightIndex ? drawWeights[weightIndex] : 0.0
            
            switch (order)
            {
            case .bar:
                if chart.barData !== nil
                {
                    _renderers.append(BarChartRenderer(dataProvider: chart, animator: animator, viewPortHandler: getPartialViewPortHandler(weight: weight, lastWeight: lastWeight, totalWeight: totalWeight, originViewPortHandler: viewPortHandler)))
                    lastWeight += weight
                    weightIndex += 1
                }
                break
                
            case .line:
                if chart.lineData !== nil
                {
                    _renderers.append(LineChartRenderer(dataProvider: chart, animator: animator, viewPortHandler: getPartialViewPortHandler(weight: weight, lastWeight: lastWeight, totalWeight: totalWeight, originViewPortHandler: viewPortHandler)))
                    lastWeight += weight
                    weightIndex += 1
                }
                break
                
            case .candle:
                if chart.candleData !== nil
                {
                    _renderers.append(CandleStickChartRenderer(dataProvider: chart, animator: animator, viewPortHandler: getPartialViewPortHandler(weight: weight, lastWeight: lastWeight, totalWeight: totalWeight, originViewPortHandler: viewPortHandler)))
                    lastWeight += weight
                    weightIndex += 1
                }
                break
                
            case .scatter:
                if chart.scatterData !== nil
                {
                    _renderers.append(ScatterChartRenderer(dataProvider: chart, animator: animator, viewPortHandler: getPartialViewPortHandler(weight: weight, lastWeight: lastWeight, totalWeight: totalWeight, originViewPortHandler: viewPortHandler)))
                    lastWeight += weight
                    weightIndex += 1
                }
                break
                
            case .bubble:
                if chart.bubbleData !== nil
                {
                    _renderers.append(BubbleChartRenderer(dataProvider: chart, animator: animator, viewPortHandler: getPartialViewPortHandler(weight: weight, lastWeight: lastWeight, totalWeight: totalWeight, originViewPortHandler: viewPortHandler)))
                    lastWeight += weight
                    weightIndex += 1
                }
                break
                
            case .rangeBar:
                if chart.rangeBarData !== nil
                {
                    _renderers.append(RangeBarChartRenderer(dataProvider: chart, animator: animator, viewPortHandler: getPartialViewPortHandler(weight: weight, lastWeight: lastWeight, totalWeight: totalWeight, originViewPortHandler: viewPortHandler)))
                    lastWeight += weight
                    weightIndex += 1
                }
                break
            }
        }

    }
    
    open override func initBuffers()
    {
        _renderers.forEach { $0.initBuffers() }
    }
    
    open override func drawData(context: CGContext)
    {
        // If we redraw the data, remove and repopulate accessible elements to update label values and frames
        accessibleChartElements.removeAll()

        if
            let arrangedChart = chart,
            let data = arrangedChart.data {
            // Make the chart header the first element in the accessible elements array
            let element = createAccessibleHeader(usingChart: arrangedChart,
                                                 andData: data,
                                                 withDefaultDescription: "Virtical Arranged Chart")
            accessibleChartElements.append(element)
        }

        // TODO: Due to the potential complexity of data presented in VirticalArranged charts, a more usable way
        // for VO accessibility would be to use axis based traversal rather than by dataset.
        // Hence, accessibleChartElements is not populated below. (Individual renderers guard against dataSource being their respective views)
        _renderers.forEach { $0.drawData(context: context) }
    }
    
    open override func drawValues(context: CGContext)
    {
        _renderers.forEach { $0.drawValues(context: context) }
    }
    
    open override func drawExtras(context: CGContext)
    {
        _renderers.forEach { $0.drawExtras(context: context) }
    }
    
    open override func drawHighlighted(context: CGContext, indices: [Highlight])
    {
        for renderer in _renderers
        {
            var data: ChartData?
            
            if renderer is BarChartRenderer
            {
                data = (renderer as! BarChartRenderer).dataProvider?.barData
            }
            else if renderer is LineChartRenderer
            {
                data = (renderer as! LineChartRenderer).dataProvider?.lineData
            }
            else if renderer is CandleStickChartRenderer
            {
                data = (renderer as! CandleStickChartRenderer).dataProvider?.candleData
            }
            else if renderer is ScatterChartRenderer
            {
                data = (renderer as! ScatterChartRenderer).dataProvider?.scatterData
            }
            else if renderer is BubbleChartRenderer
            {
                data = (renderer as! BubbleChartRenderer).dataProvider?.bubbleData
            }
            
            let dataIndex: Int? = {
                guard let data = data else { return nil }
                return (chart?.data as? VirticalArrangedChartData)?
                    .allData
                    .firstIndex(of: data)
            }()
            
            let dataIndices = indices.filter{ $0.dataIndex == dataIndex || $0.dataIndex == -1 }
            
            renderer.drawHighlighted(context: context, indices: dataIndices)
        }
    }

    /// - Returns: The sub-renderer object at the specified index.
    @objc open func getSubRenderer(index: Int) -> DataRenderer?
    {
        if index >= _renderers.count || index < 0
        {
            return nil
        }
        else
        {
            return _renderers[index]
        }
    }

    /// All sub-renderers.
    @objc open var subRenderers: [DataRenderer]
    {
        get { return _renderers }
        set { _renderers = newValue }
    }
    
    // MARK: Accessors
    
    /// `true` if drawing values above bars is enabled, `false` ifnot
    @objc open var isDrawValueAboveBarEnabled: Bool { return drawValueAboveBarEnabled }
    
    /// `true` if drawing shadows (maxvalue) for each bar is enabled, `false` ifnot
    @objc open var isDrawBarShadowEnabled: Bool { return drawBarShadowEnabled }
    
    /// the order in which the provided data objects should be drawn.
    /// The earlier you place them in the provided array, the further they will be in the background.
    /// e.g. if you provide [DrawOrder.Bar, DrawOrder.Line], the bars will be drawn behind the lines.
    open var drawOrder: [VirticalArrangedChartView.DrawOrder]
    {
        get
        {
            return _drawOrder
        }
        set
        {
            if newValue.count > 0
            {
                _drawOrder = newValue
            }
        }
    }
    
    open var drawWeights: [Double]
    {
        get
        {
            return _drawWeights
        }
        set
        {
            if newValue.count > 0
            {
                _drawWeights = newValue
            }
        }
    }
}
