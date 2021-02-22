//
//  OneButtonAlertVC.swift
//  nagi
//
//  Created by Fresh on 3/24/20.
//  Copyright © 2020 Fresh. All rights reserved.
//

import UIKit
import Cosmos

class DoctorReviewVC: UIViewController {

    @IBOutlet weak var alertTitle: UILabel!
    @IBOutlet weak var ratingBar: CosmosView!
    @IBOutlet weak var tvReview: UITextView!
    @IBOutlet weak var btnRate: UIView!
    
    var confirmAction: ((Bool, Int, String) -> Void )!
    private let startRating: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ratingBar.rating = startRating
        ratingBar.settings.fillMode = .full
    }
    
    @IBAction func onClose(_ sender: Any) {
        self.dismiss(animated: false) {
            self.confirmAction(false, 0, "")
        }
    }
    
    @IBAction func onReview(_ sender: Any) {
        
        let reviewRate = ratingBar.rating
        let reviewTxt = tvReview.text!
        
        if reviewRate == 0{
            return
        }
        if reviewTxt.isEmpty{
            return
        }
        
        self.dismiss(animated: false) {
            self.confirmAction(true, Int(reviewRate), reviewTxt)
        }
    }
    
    func checkValidation(){
    }
}
