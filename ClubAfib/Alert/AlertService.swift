//
//  AlertService.swift
//  nagi
//
//  Created by Fresh on 3/21/20.
//  Copyright © 2020 Fresh. All rights reserved.
//

import UIKit

class AlertService{
    func showReviewAlert(completion: @escaping(Bool, Int, String) -> Void) -> DoctorReviewVC {
        let storyboard = UIStoryboard(name: "Alert", bundle: .main)
        let alertVC = storyboard.instantiateViewController(withIdentifier: "DoctorReviewVC") as! DoctorReviewVC
        alertVC.confirmAction = completion
        
        return alertVC
    }
}
