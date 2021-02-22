//
//  SignupVC.swift
//  Authentication
//
//  Created by Rener on 7/20/20.
//  Copyright © 2020 ExtremeMobile. All rights reserved.
//

import UIKit
import DropDown
import GoogleSignIn
import FBSDKLoginKit
import FBSDKCoreKit
import AuthenticationServices

class SignupVC: UIViewController {
    
    @IBOutlet weak var vwScroll: UIScrollView!
    @IBOutlet weak var vwContent: UIView!
    @IBOutlet weak var tfFirstName: UITextField!
    @IBOutlet weak var tfLastName: UITextField!
    @IBOutlet weak var tfUsername: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfMobile: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfConfirmPassword: UITextField!
    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var btnSignup: UIButton!
    
    // Labels
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lblAgreement:UITextView!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var mobileLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var confirmPasswordLabel: UILabel!
    
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vwScroll.contentSize = vwContent.frame.size
        
        let text = lblAgreement.text!
        var url = URL(string: "https://clubafib.com/privacy-policy")!
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.setAttributes([.link: url], range: NSMakeRange(13, 14))
                
        url = URL(string: "https://clubafib.com/terms-and-conditions")!
        attributedString.setAttributes([.link: url], range: NSMakeRange(67, 18))
        
        lblAgreement.attributedText = attributedString
        lblAgreement.linkTextAttributes = [
            .foregroundColor: UIColor.blue,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setLocalizable()
        
    }
    
    func setLocalizable(){
        titleLabel.text = "SignUp Title".localized()
        firstNameLabel.text = "FirstName_S".localized()
        lastNameLabel.text = "LastName_S".localized()
        usernameLabel.text = "Username_S".localized()
        emailLabel.text = "Email_S".localized()
        mobileLabel.text = "Mobile_S".localized()
        passwordLabel.text = "Password_S".localized()
        confirmPasswordLabel.text = "Confirm Password_S".localized()
        btnSignup.titleLabel?.text = "Join Now".localized()
        
        btnAccept.setTitle("Accept Terms".localized(), for: .normal)
        signInButton.setTitle("Sign In".localized(), for: .normal)        
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onCategoryPressed(_ sender: Any) {
    }
    
    @IBAction func onBusinessCategoryPressed(_ sender: Any) {
    }
    
    @IBAction func onAcceptPressed(_ sender: Any) {
        btnAccept.isSelected = !btnAccept.isSelected
    }
    
    @IBAction func onPrivacy(){
//        UIApplication.shared.openURL(URL(string: "https://clubafib.com/privacy-policy"))
    }
    
    @IBAction func onTermsPressed(_ sender: Any) {
        let termsVC = HOME_STORYBOARD.instantiateViewController(withIdentifier: "TermsVC") as! TermsVC
        self.navigationController?.pushViewController(termsVC, animated: true)
    }
    
    @IBAction func onSignupPressed(_ sender: Any) {
        self.view.endEditing(true)
        
        let firstName = tfFirstName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastName = tfLastName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let username = tfUsername.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = tfEmail.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let mobile = tfMobile.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = tfPassword.text!
        let confirmPassword = tfConfirmPassword.text!
        
        if firstName.isEmpty
        {
            showToast(message: "Enter First Name".localized(), delay:8)
            return
        }
        
        if lastName.isEmpty
        {
            showToast(message: "Enter Last Name".localized(), delay:8)
            return
        }
        
        if username.isEmpty
        {
            showToast(message: "Enter Username".localized(), delay:8)
            return
        }
        else if !Validator.isValidUsername(username)
        {
            showToast(message: "Invalid Username".localized(), delay:8)
            return
        }
        
        if email.isEmpty
        {
            showToast(message: "Enter Email Address".localized(), delay:8)
            return
        }
        else if !Validator.isValidEmail(email)
        {
            showToast(message: "Invalid Email Address".localized(), delay:8)
            return
        }
        
        if mobile.isEmpty
        {
            showToast(message: "Enter Phone Number".localized(), delay:8)
            return
        }
        else if !Validator.isValidPhonenumber(mobile)
        {
            showToast(message: "Invalid Phone Number".localized(), delay:8)
            return
        }
        
        if password.isEmpty
        {
            showToast(message: "Enter Password".localized(), delay:8)
            return
        }
        else if password.count < 8
        {
            showToast(message: "Invalid Password length".localized(), delay: 8)
            return
        }
        else if !Validator.isValidPassword(password)
        {
            showToast(message: "Invalid Password".localized(), delay: 8)
            return
        }
        
        if confirmPassword.isEmpty
        {
            showToast(message: "Enter Confirm Password".localized(), delay:8)
            return
        }
        else if password != confirmPassword
        {
            showToast(message: "Password no match".localized(), delay:8)
            return
        }
        
        if !btnAccept.isSelected
        {
            showToast(message: "Confirm Terms Conditions".localized(), delay:8)
            return
        }
        
        let params : [String : Any] = [
            "first_name" : firstName,
            "last_name" : lastName,
            "phonenumber" : mobile,
            "username" : username,
            "email" : email,
            "password" : password,
            "type" : 0,
            "login_type" : 1
        ]
        
        showLoadingProgress(view: self.navigationController?.view)

        // Call register api
        ApiManager.sharedInstance.register(params: params) { (success, errorMsg) in
            DispatchQueue.main.async {

                // Hide the loading progress
                self.dismissLoadingProgress(view: self.navigationController?.view)

                if success {
                    // save user auth info for facial login
                    UserInfo.sharedInstance.userAuth = UserAuth(email: email, password: password)

                    // Go to verification page
                    self.navigateToVerification()
                }
                else{
                    // Show the error message
                    let errorMessage = errorMsg ?? "Something went wrong, try again later"
                    self.showToast(message: errorMessage, delay:8)
                }
            }
        }
    }
    
    @IBAction func onSigninPressed(_ sender: Any) {
        navigateToSignin()
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
    
    func navigateToVerification() {
        let verificationVC = AUTHENTICATION_STORYBOARD.instantiateViewController(withIdentifier: "VerificationCodeVC") as! VerificationCodeVC
        verificationVC.fromScreen = 0 // From Sign Up
        verificationVC.userEmail = UserInfo.sharedInstance.userData.email!
        self.navigationController?.pushViewController(verificationVC, animated: true)
    }
    
    // Login with Google
    @IBAction func onGoogleLogin(_ sender : Any){
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
                
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().signIn()
    }
    
    // Login with Facebook
    @IBAction func onFacebookPressed(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["email", "public_profile"], from: self) { (loginResult, error) in
            if let loginError = error {
                print("Facebook Login Error :")
                print(loginError.localizedDescription)
                return
            }
            
            guard let accessToken = AccessToken.current else {
                print("Failed to get Facebook access token")
                return
            }
            
            print("Facebook access token = \(accessToken.tokenString)")
            
            // Login via Restful api
            let param : [String : Any] = [
                "access_token" : accessToken.tokenString,
                "login_type" : 1
            ]
            
            self.showLoadingProgress(view: self.navigationController?.view)
            
            ApiManager.sharedInstance.loginWithSocial(params: param) { (success, errorMsg) in
                DispatchQueue.main.async {
                    
                    // Hide the loading progress
                    self.dismissLoadingProgress(view: self.navigationController?.view)
                    
                    if success {
                        UserInfo.sharedInstance.isRemembered = false // disable auto login when social auth
                        
                        // Go to home page
                        self.navigateToHome()
                    }
                    else{
                        // Show the error message
                        let errorMessage = errorMsg ?? "Something went wrong, try again later"
                        self.showToast(message: errorMessage, delay:8)
                    }
                }
            }
        }
    }
    
    @IBAction func onSignWithApple() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

extension SignupVC : ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            // Create an account in your system.
            var firstName = "", lastName = "", email = ""
            
            if let name = appleIDCredential.fullName {
                if let val = name.givenName {
                    firstName = val
                }
                if let val = name.familyName {
                    lastName = val
                }
            }
            if let val = appleIDCredential.email {
                email = val
            }
            let param : [String : String] = [
                "apple_id" : appleIDCredential.user,
                "email" : email,
                "last_name": firstName,
                "first_name": lastName,
                "photo":""
            ]
            self.showLoadingProgress(view: self.navigationController?.view)
            
            ApiManager.sharedInstance.loginWithApple(params: param) { (success, errorMsg) in
                DispatchQueue.main.async {
                    
                    // Hide the loading progress
                    self.dismissLoadingProgress(view: self.navigationController?.view)
                    
                    if success {
                        UserInfo.sharedInstance.isRemembered = false // disable auto login when social auth
                        
                        // Go to home page
                        self.navigateToHome()
                    }
                    else{
                        // Show the error message
                        let errorMessage = errorMsg ?? "Something went wrong, try again later"
                        self.showToast(message: errorMessage, delay:8)
                    }
                }
            }
            break
        default:
            break
        }
    }
}
// MARK :- GIDSignInDelegate
extension SignupVC:GIDSignInDelegate{
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let error = error {
            print("Google Sign Error : \(error.localizedDescription)")
        } else {
            // Perform any operations on signed in user here.
            guard let authentication = user.authentication else { return }
            
            let googleAccessToken = authentication.accessToken
            print("Google Access Token : \(googleAccessToken!)")
            
            // Login via Restful api
            let param : [String : Any] = [
                "access_token" : googleAccessToken!,
                "login_type" : 1,
                "email" : user.profile.email,
                "last_name": user.profile.familyName,
                "first_name": user.profile.givenName,
                "photo":""
            ]
            
            self.showLoadingProgress(view: self.navigationController?.view)
            
            ApiManager.sharedInstance.loginWithSocial(params: param, isFacebook : false) { (success, errorMsg) in
                DispatchQueue.main.async {
                    
                    // Hide the loading progress
                    self.dismissLoadingProgress(view: self.navigationController?.view)
                    
                    if success {
                        UserInfo.sharedInstance.isRemembered = false // disable auto login when social auth
                        
                        // Go to home page
                        self.navigateToHome()
                    }
                    else{
                        // Show the error message
                        let errorMessage = errorMsg ?? "Something went wrong, try again later"
                        self.showToast(message: errorMessage, delay:8)
                    }
                }
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func sign(_ signIn: GIDSignIn!,
              dismiss viewController: UIViewController!) {
        
        GIDSignIn.sharedInstance().signOut()
        self.dismiss(animated: true, completion: nil)
    }
    
}

