//
//  ProfileVC.swift
//  ClubAfib
//
//  Created by Rener on 8/21/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController {

    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblPhone: UILabel!
    
    @IBOutlet weak var subscribeContainer: UIView!
    @IBOutlet weak var subscriptionContainer: UIView!
    @IBOutlet weak var lblPaymentStatus: UILabel!
    @IBOutlet weak var btnCancelSubscription: UIButton!
    
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateProfile()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onProfileUpdated), name: NSNotification.Name(USER_NOTIFICATION_PROFILE_CHANGED), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onSubscribed), name: NSNotification.Name(USER_NOTIFICATION_SUBSCRIBED), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ApiManager.sharedInstance.getGetActivePayments() { _, _ in
            self.updateSubscription()
        }
    }
    
    private func updateProfile() {
        user = UserInfo.sharedInstance.userData
        
        if user.photo != nil && !user.photo!.isEmpty
        {
            imgAvatar.sd_setImage(with: URL(string: user.photo!))
        }
        else
        {
            imgAvatar.image = UIImage(named: "default_avatar")
        }
        lblName.text = "\(user.firstName!) \(user.lastName!)"
        lblUsername.text = user.username
        lblEmail.text = user.email
        lblAddress.text = user.address
        lblPhone.text = user.phonenumber
        
        self.updateSubscription()
    }
    
    private func updateSubscription() {
        if let payment = UserInfo.sharedInstance.userPayment {
            subscribeContainer.isHidden = true
            subscriptionContainer.isHidden = false
            switch payment.type {
            case 0: // One time fee
                lblPaymentStatus.text = "You have the One Time Chat service"
                btnCancelSubscription.isHidden = true
                break
            case 1:
                lblPaymentStatus.text = "You have the Monthly subscription service"
                btnCancelSubscription.isHidden = false
                break
            case 2:
                lblPaymentStatus.text = "You have the Annual subscription service"
                btnCancelSubscription.isHidden = false
                break
            default:
                break
            }
        }
        else {
            subscribeContainer.isHidden = false
            subscriptionContainer.isHidden = true
            lblPaymentStatus.text = "Subscribe to chat with our Afib Experts"
        }
    }
    
    
    @objc func onProfileUpdated() {
        self.updateProfile()
    }
    
    @objc func onSubscribed() {
        self.updateSubscription()
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onEditButtonPressed(_ sender: Any) {
        let editProfileVC = HOME_STORYBOARD.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC
        self.navigationController?.pushViewController(editProfileVC, animated: true)
    }
    
    @IBAction func onSubscribeButtonTapped(_ sender: Any) {
        let subscriptionVC = HOME_STORYBOARD.instantiateViewController(withIdentifier: "SubscriptionVC") as! SubscriptionVC
        self.navigationController?.pushViewController(subscriptionVC, animated: true)
    }
    
    @IBAction func onCancelButtonTapped(_ sender: Any) {
        if let payment = UserInfo.sharedInstance.userPayment {
            let alertController = UIAlertController(
                title: "Cancel Subscription",
                message: "Are you sure to cancel subscription?",
                preferredStyle: .alert
            )
            let cancel = UIAlertAction(title: "No", style: .cancel, handler: nil)
            let retry = UIAlertAction(title: "Yes", style: .default, handler: { action in
                self.showLoadingProgress(view: self.view)
                
                let params: [String : Any] = [
                    "subscription_id": payment.stripe_id!
                ]
                ApiManager.sharedInstance.cancelSubscription(params: params) { success, error in
                    self.dismissLoadingProgress(view: self.view)
                    if success {
                        DispatchQueue.main.async {
                            UserInfo.sharedInstance.userPayment = nil
                            self.updateSubscription()
                        }
                    }
                }
            })
            alertController.addAction(cancel)
            alertController.addAction(retry)
            self.present(alertController, animated: true, completion: nil)
            
        }
    }
    
}
