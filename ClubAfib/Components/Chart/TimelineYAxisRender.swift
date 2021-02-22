//
//  TimelineYAxisRender.swift
//  ClubAfib
//
//  Created by Rener on 9/3/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit

class TimelineYAxisRender: YAxisRenderer{

    @objc open override func computeAxisValues(min: Double, max: Double) {
        guard let axis = self.axis else {
            return super.computeAxisValues(min: min, max: max)
        }

        let lowestHour = Int((min/60).rounded(.down))
        let highestHour = Int((max/60).rounded(.up))
        
        super.computeAxisValues(min: Double(lowestHour), max: Double(highestHour))
        
        for (index, entry) in axis.entries.enumerated() {
            axis.entries[index] = entry * 60.0
        }
    }
    
}
