//
//  DateFormatter.swift
//  ClubAfib
//
//  Created by Dale Ninmann on 9/16/21.
//  Copyright © 2021 ETU. All rights reserved.
//

import Foundation

extension DateFormatter {
    static let standardDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
        return dateFormatter
    }()
}
