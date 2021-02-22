//
//  BaseHealthData.swift
//  ClubAfib
//
//  Created by Rener on 8/20/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit

protocol BaseHealthData {
    var id: Int { get set }
    var date: Date { get set }
    var status: Int { get set }
}
