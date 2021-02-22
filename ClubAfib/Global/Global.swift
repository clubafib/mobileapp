//
//  Global.swift
//  Global
//
//  Created by Rener on 7/22/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit

enum MenuType {
    case Home
    case Profile
    case Terms
    case Privacy
    case AboutUs
    case Contact
    case Share
    case Setting
    case Logout
    case Other
}

enum HealthCategoryType {
    case Activity
    case ActivityMove
    case ActivityExercise
    case ActivityStand
    case BodyMeasurements
    case BodyHeight
    case BodyWeight
    case Steps
    case Sleep
    case AlcoholUse
    case BloodAlcoholContent
    case BloodPressure
    case BloodPressureSystolic
    case BloodPressureDiastolic
    case HeartRate
    case ECG
}


let SCREEN_WIDTH = Int(UIScreen.main.bounds.width)
let SCREEN_HEIGHT = Int(UIScreen.main.bounds.height)
let STATUS_BAR_HEIGHT = Int(UIApplication.shared.statusBarFrame.height)
let TOP_BAR_LOGO_WIDTH = 120
let TOP_BAR_HEIGHT = 50

var HeartRateData: [(Date, Double)]?

let MAX_WEIGHT = 800.0
let MAX_ALCOHOL_PERCENT = 0.4
let MAX_ALCOHOL_USE = 20.0
let MIN_BLOOD_PRESSURE_SYSASTOLIC = 30.0
let MAX_BLOOD_PRESSURE_SYSASTOLIC = 200.0
let MIN_BLOOD_PRESSURE_DIASTOLIC = 40.0
let MAX_BLOOD_PRESSURE_DIASTOLIC = 300.0

let USER_NOTIFICATION_PROFILE_CHANGED       = "PROFILE_CHANGED"
let USER_NOTIFICATION_OPEN_MENU             = "OPEN_MENU"
let USER_NOTIFICATION_HEALTHDATA_CHANGED    = "HEALTHDATA_CHANGED"
let USER_NOTIFICATION_ARTICLE_UPDATED       = "ARTICLE_UPDATED"
let USER_NOTIFICATION_GOODS_UPDATED         = "GOODS_UPDATED"
let USER_NOTIFICATION_POST_UPDATED          = "POST_UPDATED"
let USER_NOTIFICATION_POST_DELETED          = "POST_DELETED"
let USER_NOTIFICATION_SUBSCRIBED            = "USER_NOTIFICATION_SUBSCRIBED"
let USER_NOTIFICATION_FECTED_DATA    = "HEALTHDATA_FETCH"

let ONE_TIME_CHAT_FEE = 99.0
let MONTHLY_SUBSCRIPTION = 49.0
let ANNUAL_SUBSCRIPTION = 550.0

extension UIView {
    public func toImage() -> UIImage{
        let renderer = UIGraphicsImageRenderer(bounds: self.bounds)
        return renderer.image { rendererContext in
            self.layer.render(in: rendererContext.cgContext)
        }
    }
}
