//
//  ForgotPasswordVC.swift
//  Authentication
//
//  Created by Rener on 7/20/20.
//  Copyright © 2020 ExtremeMobile. All rights reserved.
//

import UIKit

class ForgotPasswordVC: UIViewController, LinkSentVCDelegate {

    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var btnNext: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setLocalizable()
    }
    
    func setLocalizable(){
        titleLabel.text = "Change Password".localized()
        emailLabel.text = "Email Address".localized()
        btnNext.setTitle("Next".localized(), for: .normal)
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onNextPressed(_ sender: Any) {
        self.view.endEditing(true)
        
        let email = tfEmail.text!
        
        if email.isEmpty
        {
            showToast(message: "Enter Email Address".localized(), delay: 8)
            return
        }
        else if !Validator.isValidEmail(email)
        {
            showToast(message: "Invalid Email Address".localized(), delay: 8)
            return
        }
        
        let params : [String : Any] = [
            "email" : email
        ]
        
        showLoadingProgress(view: self.navigationController?.view)
        
        // Call forgot password api
        ApiManager.sharedInstance.requestResetPassword(params: params) { (success, errorMsg) in
            DispatchQueue.main.async {
                
                // Hide the loading progress
                self.dismissLoadingProgress(view: self.navigationController?.view)
                
                if success {
                    // Show link sent pop up
                    self.showPopup()
                }
                else{
                    // Show the error message
                    let errorMessage = errorMsg ?? "Something went wrong, try again later"
                    self.showToast(message: errorMessage, delay: 8)
                }
            }
        }
    }
    
    func showPopup() {
        let linkSentVC = AUTHENTICATION_STORYBOARD.instantiateViewController(withIdentifier: "LinkSentVC") as! LinkSentVC
        linkSentVC.delegate = self
        presentPopController(vc: linkSentVC)
    }
    
    func didContinue(sender: LinkSentVC) {
        let email = tfEmail.text!
        
        let verificationCodeVC = AUTHENTICATION_STORYBOARD.instantiateViewController(withIdentifier: "VerificationCodeVC") as! VerificationCodeVC
        verificationCodeVC.fromScreen = 2 // From Forget Password
        verificationCodeVC.userEmail = email
        self.navigationController?.pushViewController(verificationCodeVC, animated: true)
    }
}
