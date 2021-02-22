//
//  SingleValueHealthData.swift
//  ClubAfib
//
//  Created by Rener on 8/20/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit

protocol SingleValueHealthData: BaseHealthData {
    var value: Double { get }
}
