//
//  RangeValueHealthData.swift
//  ClubAfib
//
//  Created by Rener on 8/21/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit

protocol RangeValueHealthData: BaseHealthData {
    var low: Double { get }
    var high: Double { get }
}
