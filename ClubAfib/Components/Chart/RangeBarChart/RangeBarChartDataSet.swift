//
//  RangeBarChartDataSet.swift
//  ClubAfib
//
//  Created by Rener on 7/29/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit

open class RangeBarChartDataSet: LineScatterCandleRadarChartDataSet, IRangeBarChartDataSet
{
    private func initialize()
    {
        self.highlightColor = NSUIColor.black
        
        self.calcStackSize(entries: entries as! [RangeBarChartDataEntry])
        self.calcEntryCountIncludingStacks(entries: entries as! [RangeBarChartDataEntry])
    }
    
    public required init()
    {
        super.init()
        initialize()
    }
    
    public override init(entries: [ChartDataEntry]?, label: String?)
    {
        super.init(entries: entries, label: label)
        initialize()
    }

    // MARK: - Data functions and accessors
    
    /// the maximum number of bars that are stacked upon each other, this value
    /// is calculated from the Entries that are added to the DataSet
    private var _stackSize = 1
    
    /// the overall entry count, including counting each stack-value individually
    private var _entryCountStacks = 0
    
    /// Calculates the total number of entries this DataSet represents, including
    /// stacks. All values belonging to a stack are calculated separately.
    private func calcEntryCountIncludingStacks(entries: [RangeBarChartDataEntry])
    {
        _entryCountStacks = 0
        
        for i in 0 ..< entries.count
        {
            if let vals = entries[i].ranges
            {
                _entryCountStacks += vals.count
            }
            else
            {
                _entryCountStacks += 1
            }
        }
    }
    
    /// calculates the maximum stacksize that occurs in the Entries array of this DataSet
    private func calcStackSize(entries: [RangeBarChartDataEntry])
    {
        for i in 0 ..< entries.count
        {
            if let vals = entries[i].ranges
            {
                if vals.count > _stackSize
                {
                    _stackSize = vals.count
                }
            }
        }
    }
    
    open override func calcMinMax(entry e: ChartDataEntry)
    {
        guard let e = e as? RangeBarChartDataEntry
            else { return }
            
        if e.start < _yMin
        {
            _yMin = e.start
        }
        
        if e.end > _yMax
        {
            _yMax = e.end
        }
        
        calcMinMaxX(entry: e)
    }
    
    open override func calcMinMaxY(entry e: ChartDataEntry)
    {
        guard let e = e as? RangeBarChartDataEntry
            else { return }
        
        if e.end < _yMin
        {
            _yMin = e.end
        }
        if e.end > _yMax
        {
            _yMax = e.end
        }
        
        if e.start < _yMin
        {
            _yMin = e.start
        }
        if e.start > _yMax
        {
            _yMax = e.start
        }
    }
    
    /// The maximum number of bars that can be stacked upon another in this DataSet.
    open var stackSize: Int
    {
        return _stackSize
    }
    
    /// `true` if this DataSet is stacked (stacksize > 1) or not.
    open var isStacked: Bool
    {
        return _stackSize > 1 ? true : false
    }
    
    /// The overall entry count, including counting each stack-value individually
    @objc open var entryCountStacks: Int
    {
        return _entryCountStacks
    }
    
    /// array of labels used to describe the different values of the stacked bars
    open var stackLabels: [String] = []
    
    // MARK: - Styling functions and accessors
    
    /// the color used for drawing the bar-shadows. The bar shadows is a surface behind the bar that indicates the maximum value
    open var barShadowColor = NSUIColor(red: 215.0/255.0, green: 215.0/255.0, blue: 215.0/255.0, alpha: 1.0)

    /// the width used for drawing borders around the bars. If borderWidth == 0, no border will be drawn.
    open var barBorderWidth : CGFloat = 0.0

    /// the color drawing borders around the bars.
    open var barBorderColor = NSUIColor.black

    /// the alpha value (transparency) that is used for drawing the highlight indicator bar. min = 0.0 (fully transparent), max = 1.0 (fully opaque)
    open var highlightAlpha = CGFloat(120.0 / 255.0)
    
    // MARK: - NSCopying
    
    open override func copy(with zone: NSZone? = nil) -> Any
    {
        let copy = super.copy(with: zone) as! RangeBarChartDataSet
        copy._stackSize = _stackSize
        copy._entryCountStacks = _entryCountStacks
        copy.stackLabels = stackLabels

        copy.barShadowColor = barShadowColor
        copy.barBorderWidth = barBorderWidth
        copy.barBorderColor = barBorderColor
        copy.highlightAlpha = highlightAlpha
        return copy
    }
}
