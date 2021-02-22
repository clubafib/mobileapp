//
//  ResetPasswordVC.swift
//  Authentication
//
//  Created by Rener on 7/20/20.
//  Copyright © 2020 ExtremeMobile. All rights reserved.
//

import UIKit

class ResetPasswordVC: UIViewController {

    @IBOutlet weak var tfNewPassword: UITextField!
    @IBOutlet weak var tfConfirmNewPassword: UITextField!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var newPwdLabel: UILabel!
    @IBOutlet weak var confirmNewPwdLabel: UILabel!
    @IBOutlet weak var btnReset: UIButton!
    
    var userEmail: String!
    var verificationCode: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setLocalizable()
    }
    
    func setLocalizable(){        
        titleLabel.text = "Reset Your Password".localized()
        newPwdLabel.text = "New Password".localized()
        confirmNewPwdLabel.text = "Confirm New Password".localized()
        btnReset.setTitle("Login Again".localized(), for: .normal)
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onLoginAgainPressed(_ sender: Any) {
        self.view.endEditing(true)
        
        let newPassword = tfNewPassword.text!
        let confirmNewPassword = tfConfirmNewPassword.text!
        
        if newPassword.isEmpty
        {
            showToast(message: "Enter New Password".localized(), delay:8)
            return
        }
        else if newPassword.count < 8
        {
            showToast(message: "Invalid Password length".localized(), delay:8)
            return
        }
        else if !Validator.isValidPassword(newPassword)
        {
            showToast(message: "Invalid Password".localized(), delay:8)
            return
        }
        
        if confirmNewPassword.isEmpty
        {
            showToast(message: "Enter Confirm New Password".localized(), delay:8)
            return
        }
        else if newPassword != confirmNewPassword
        {
            showToast(message: "Password no match".localized(), delay:8)
            return
        }
        
        let params : [String : Any] = [
            "email": self.userEmail!,
            "code": self.verificationCode!,
            "password": newPassword
        ]
        
        showLoadingProgress(view: self.navigationController?.view)
        
        // Call reset password api
        ApiManager.sharedInstance.resetPassword(params: params) { (success, errorMsg) in
            DispatchQueue.main.async {
                
                // Hide the loading progress
                self.dismissLoadingProgress(view: self.navigationController?.view)
                
                if success {
                    self.showToast(message: "Change Password Success".localized(), isError: false, complete: {
                        // Go to sign in page
                        self.navigateToSignin()
                    })
                }
                else{
                    // Show the error message
                    let errorMessage = errorMsg ?? "Something went wrong, try again later"
                    self.showToast(message: errorMessage, delay:8)
                }
            }
        }
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
}
