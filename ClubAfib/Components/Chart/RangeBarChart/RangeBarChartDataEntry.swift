//
//  RnageBarChartDataEntry.swift
//  ClubAfib
//
//  Created by Rener on 7/29/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit

open class RangeBarChartDataEntry: ChartDataEntry
{
    
    /// the ranges for the individual stack values - automatically calculated
    private var _ranges: [Range]?
    
    /// start value
    @objc open var start = Double(0.0)
    
    /// end value
    @objc open var end = Double(0.0)
    
    public required init()
    {
        super.init()
    }
    
    @objc public init(x: Double, start: Double, end: Double)
    {
        super.init(x: x, y: end > start ? end : start)
        
        self.start = start
        self.end = end
    }

    @objc public convenience init(x: Double, start: Double, end: Double, icon: NSUIImage?)
    {
        self.init(x: x, start: start, end: end)
        self.icon = icon
    }

    @objc public convenience init(x: Double, start: Double, end: Double, ata: Any?)
    {
        self.init(x: x, start: start, end: end)
        self.data = data
    }

    @objc public convenience init(x: Double, start: Double, end: Double, icon: NSUIImage?, data: Any?)
    {
        self.init(x: x, start: start, end: end)
        self.icon = icon
        self.data = data
    }
    
    /// The body size (difference between open and close).
    @objc open var bodyRange: Double
    {
        return abs(end - start)
    }
    
    /// the top value of the bar. (The bigger one between start and end value)
    open override var y: Double
    {
        get
        {
            return super.y
        }
        set
        {
            super.y = end > start ? end : start
        }
    }
    
    // MARK: NSCopying
    
    open override func copy(with zone: NSZone? = nil) -> Any
    {
        let copy = super.copy(with: zone) as! RangeBarChartDataEntry
        copy._ranges = _ranges
        copy.start = start
        copy.end = end
        return copy
    }
    
    /// The ranges of the individual stack-entries. Will return null if this entry is not stacked.
    @objc open var ranges: [Range]?
    {
        return _ranges
    }
}
