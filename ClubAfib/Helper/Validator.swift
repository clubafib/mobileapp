//
//  Validator.swift
//  Helper
//
//  Created by Rener on 7/20/20.
//  Copyright © 2020 ExtremeMobile. All rights reserved.
//

import UIKit

class Validator: NSObject {
    
    /*
     @brief This function is to check username is valid or not
     @param username user entered
     */
    static func isValidUsername(_ username : String) -> Bool {
        let usernameRegEx = "^(?=.{4,20}$)(?![_.])(?!.*[_.]{2})[a-zA-Z0-9._]+(?<![_.])$"
        
        let usernameTest = NSPredicate(format:"SELF MATCHES %@", usernameRegEx)
        return usernameTest.evaluate(with: username)
    }
    
    /*
     @brief This function is to check email is valid or not
     @param Email address user entered
     */
    static func isValidEmail(_ email : String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    /*
     @brief This function is to check phone number is valid or not
     @param phone number user entered
     */
    static func isValidPhonenumber(_ phonenumber : String) -> Bool {
        let phoneRegEx = "^[0-9+]{0,1}+[0-9]{5,16}$"
        
        let phoneTest = NSPredicate(format:"SELF MATCHES %@", phoneRegEx)
        return phoneTest.evaluate(with: phonenumber)
    }
    
    /*
     @brief This function is to check password is valid or not
     Password must bigger than 8 letters
     Password must contains at least one capital character, one special character and one numerical character
     @param password user entered
     */
    static func isValidPassword(_ password : String) -> Bool {
        let passwordRegEx = "^(?=.*[A-Z])(?=.*[$@$#!%*?&])(?=.*[0-9]).{8,}$"
        
        let passwordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: password)
    }
    
}
