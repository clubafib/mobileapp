//
//  SubscriptionVC.swift
//  ClubAfib
//
//  Created by Rener on 8/20/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit


class SubscriptionVC: UIViewController {

    @IBOutlet weak var lblSubscriptionStatus: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let payment = UserInfo.sharedInstance.userPayment {
            self.lblSubscriptionStatus.isHidden = false
            switch payment.type {
            case 0: // One time fee
                self.lblSubscriptionStatus.text = "You have the One Time Chat service"
                break
            case 1:
                self.lblSubscriptionStatus.text = "You have the Monthly subscription service"
                break
            case 2:
                self.lblSubscriptionStatus.text = "You have the Annual subscription service"
                break
            default:
                break
            }
        }
        else {
            self.lblSubscriptionStatus.isHidden = true
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onSubscribed), name: NSNotification.Name(USER_NOTIFICATION_SUBSCRIBED), object: nil)
    }
    
    private func gotoCheckout(_ type: Int) {
        if let payment = UserInfo.sharedInstance.userPayment {
            var alertText = ""
            switch payment.type {
            case 0: // One time fee
                alertText = "You have the One Time Chat service"
                break
            case 1:
                alertText = "You have the Monthly subscription service"
                break
            case 2:
                alertText = "You have the Annual subscription service"
                break
            default:
                break
            }
            self.showToast(message: alertText)
        }
        else {
            let checkoutVC = HOME_STORYBOARD.instantiateViewController(withIdentifier: "CheckoutCV") as! CheckoutCV
            checkoutVC.subscriptionTitle = type == 2 ? "Annual Subscription" : (type == 1 ? "Monthly Subscription" : "One Time Fee")
            checkoutVC.type = type
            checkoutVC.price = type == 2 ? ANNUAL_SUBSCRIPTION : (type == 1 ? MONTHLY_SUBSCRIPTION : ONE_TIME_CHAT_FEE)
            self.navigationController?.pushViewController(checkoutVC, animated: true)
        }
    }
    
    @objc func onSubscribed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onMonthlySubscriptionTapped(_ sender: Any) {
        gotoCheckout(1)
    }
    
    @IBAction func onOneTimeFeeTapped(_ sender: Any) {
        gotoCheckout(0)
    }
    
    @IBAction func onAnnualSubscriptionTapped(_ sender: Any) {
        gotoCheckout(2)
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}
