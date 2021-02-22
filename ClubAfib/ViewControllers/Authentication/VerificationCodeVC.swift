//
//  VerificationCodeVC.swift
//  Authentication
//
//  Created by Rener on 7/20/20.
//  Copyright © 2020 ExtremeMobile. All rights reserved.
//

import UIKit

class VerificationCodeVC: UIViewController {

    @IBOutlet weak var tfVerificationCode: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var btnNext: UIButton!
    
    var fromScreen = 0 // 0: SignUp, 1: Login, 2: Reset Password
    var userEmail = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setLocalizable()
    }
    
    func setLocalizable(){
        self.titleLabel.text = "Verification Code".localized().uppercased()
        self.codeLabel.text  = "Verification Code".localized()
        self.btnNext.setTitle("Next".localized(), for: .normal)
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onNextPressed(_ sender: Any) {
        self.view.endEditing(true)
        
        let code = tfVerificationCode.text!
        
        if code.isEmpty
        {
            showToast(message: "Enter Verification Code".localized(), delay:8)
            return
        }
        
        // If reset password, go to reset screen with code directly without verification
        if self.fromScreen == 2 {
            self.navigateToResetPasswrod(code)
            return
        }
        
        // Else if sign up, verify code
        let params : [String : Any] = [
            "email" : self.userEmail,
            "code" : code,
            "login_type" : 1
        ]
        
        showLoadingProgress(view: self.navigationController?.view)
        
        // Call verify api
        ApiManager.sharedInstance.verify(params: params) { (success, errorMsg) in
            DispatchQueue.main.async {
                
                // Hide the loading progress
                self.dismissLoadingProgress(view: self.navigationController?.view)
                
                if success {
                    if self.fromScreen == 0{
                        // Go to home page
                        self.navigateToHome()
                    }
                } else {
                    // Show the error message
                    let errorMessage = errorMsg ?? "Something went wrong, try again later"
                    self.showToast(message: errorMessage, delay:8)
                }
            }
        }
    }
    
    func navigateToResetPasswrod(_ code: String) {
        let resetPasswordVC = AUTHENTICATION_STORYBOARD.instantiateViewController(withIdentifier: "ResetPasswordVC") as! ResetPasswordVC
        resetPasswordVC.userEmail = self.userEmail
        resetPasswordVC.verificationCode = code
        self.navigationController?.pushViewController(resetPasswordVC, animated: true)
    }
    
    func navigateToSignin() {
        for vc in (self.navigationController?.viewControllers ?? []) {
            if vc is SigninVC
            {
                self.navigationController?.popToViewController(vc, animated:true)
                return
            }
        }
        
        let signinVC = AUTHENTICATION_STORYBOARD.instantiateViewController(withIdentifier: "SigninVC") as! SigninVC
        self.navigationController?.pushViewController(signinVC, animated: true)
    }
    
    func navigateToHome() {
        NotificationCenter.default.post(name: Notification.Name("UserLoggedIn"), object: nil)
        
        let signupVC = HOME_STORYBOARD.instantiateViewController(withIdentifier: "HomeTabVC") as! HomeTabVC
        self.navigationController?.pushViewController(signupVC, animated: true)
    }
}
