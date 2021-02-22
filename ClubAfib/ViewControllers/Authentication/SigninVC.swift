//
//  SigninVC.swift
//  Authentication
//
//  Created by Rener on 7/20/20.
//  Copyright © 2020 ExtremeMobile. All rights reserved.
//

import UIKit
import LocalAuthentication
import GoogleSignIn
import FBSDKLoginKit
import FBSDKCoreKit
import AuthenticationServices

class SigninVC: UIViewController {
    
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var btnRememberMe: UIButton!
    @IBOutlet weak var btnSignin: UIButton!
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var noAccountLabel: UILabel!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var fbButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var joinUsButton: UIButton!
    @IBOutlet weak var facialGroup: UIView!
    @IBOutlet weak var facialGroupHeightConstraint: NSLayoutConstraint!
    
    override func viewWillAppear(_ animated: Bool) {
        self.setLocalizable()
        
        facialGroupHeightConstraint.priority = (UserInfo.sharedInstance.userAuth == nil) ? .required : .defaultLow
    }
    
    override func viewDidLoad() {
        if !UserDefaults.standard.bool(forKey: "is_first_time") {
            UserDefaults.standard.setValue(true, forKey: "is_first_time")
            self.onSignupPressed(UIButton())
        }
        
        let facialTap = UITapGestureRecognizer(target: self, action: #selector(self.facialLoginTapped(_:)))
        facialGroup.isUserInteractionEnabled = true
        facialGroup.addGestureRecognizer(facialTap)
        
        if UserInfo.sharedInstance.isRemembered {
            tfEmail.text = UserInfo.sharedInstance.userAuth?.email
            tfPassword.text = UserInfo.sharedInstance.userAuth?.password
            btnRememberMe.isSelected = true
        }

//        tfEmail.text = "dr.rumsey@gmail.com"
//        tfEmail.text = "harry19950321@outlook.com"
//        tfPassword.text = "123123"
    }
    
    func clearForm() {
        self.tfEmail.text = ""
        self.tfPassword.text = ""
    }
    
    func setLocalizable(){
        welcomeLabel.text = "Welcome".localized()
        orLabel.text = "OR".localized()
        emailLabel.text = "Email Address".localized()
        passwordLabel.text = "Password".localized()
        btnSignin.setTitle("Sign In".localized(), for: .normal)
        
        btnRememberMe.setTitle("Remember Me", for: .normal)
        forgotPasswordButton.setTitle("Forgot Password", for: .normal)
        fbButton.setTitle("Sign In with Facebook".localized(), for: .normal)
        googleButton.setTitle("Sign In with Google".localized(), for: .normal)
        noAccountLabel.text = "No Account".localized()
        joinUsButton.setTitle("Sign Up", for: .normal)
    }
    
    @IBAction func onRememberMePressed(_ sender: Any) {
        btnRememberMe.isSelected = !btnRememberMe.isSelected
    }
    
    @IBAction func onForgotPasswordPressed(_ sender: Any) {
        let forgotPasswordVC = AUTHENTICATION_STORYBOARD.instantiateViewController(withIdentifier: "ForgotPasswordVC") as! ForgotPasswordVC
        self.navigationController?.pushViewController(forgotPasswordVC, animated: true)
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
    
    @IBAction func onLoginPressed(_ sender: Any) {
        self.view.endEditing(true)
        
        let email = tfEmail.text!
        let password = tfPassword.text!
        
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
        
        if password.isEmpty
        {
            showToast(message: "Enter Password".localized(), delay:8)
            return
        }
        else if password.count < 4
        {
            showToast(message: "Invalid Password".localized(), delay:8)
            return
        }
        
        let params : [String : Any] = [
            "email" : email,
            "password" : password,
            "login_type" : 1
        ]
        
        showLoadingProgress(view: self.navigationController?.view)
        
        // Call login api
        ApiManager.sharedInstance.login(params: params) { (success, errorMsg) in
            DispatchQueue.main.async {
                
                // Hide the loading progress
                self.dismissLoadingProgress(view: self.navigationController?.view)
                
                if success {
                    UserInfo.sharedInstance.isRemembered = self.btnRememberMe.isSelected
                    if (UserInfo.sharedInstance.isRemembered)
                    {
                        UserInfo.sharedInstance.saveUserDataToLocal()
                    }
                    
                    // save user auth info for facial login
                    UserInfo.sharedInstance.userAuth = UserAuth(email: email, password: password)
                    
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
    
    @objc private func facialLoginTapped(_ sender: UITapGestureRecognizer) {
        if let userAuth = UserInfo.sharedInstance.userAuth {
            let context = LAContext()
            var error: NSError?

            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "Identify yourself!"

                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                    [weak self] success, authenticationError in

                    DispatchQueue.main.async {
                        if success {
                            self?.tfEmail.text = userAuth.email
                            self?.tfPassword.text = userAuth.password
                            
                            self?.onLoginPressed(sender)
                        }
                    }
                }
            } else {
                showSimpleAlert(title: "Permission required", message: "Please allow Face ID permission.", complete: nil)
            }
        }
        else {
            // impossible facial login
            facialGroupHeightConstraint.priority = .required
        }
    }
    
    @IBAction func onSignupPressed(_ sender: Any) {
        self.view.endEditing(true)
        
        let signupVC = AUTHENTICATION_STORYBOARD.instantiateViewController(withIdentifier: "SignupVC") as! SignupVC
        self.navigationController?.pushViewController(signupVC, animated: true)
    }
    
    func navigateToHome() {
        NotificationCenter.default.post(name: Notification.Name("UserLoggedIn"), object: nil)
        self.clearForm()
        
        UserInfo.sharedInstance.saveUsername()
        
        let signupVC = HOME_STORYBOARD.instantiateViewController(withIdentifier: "HomeTabVC") as! HomeTabVC
        self.navigationController?.pushViewController(signupVC, animated: true)
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

extension SigninVC : ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
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
extension SigninVC:GIDSignInDelegate{
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
