//
//  UserInfo.swift
//  Helper
//
//  Created by Rener on 7/20/20.
//  Copyright © 2020 ExtremeMobile. All rights reserved.
//

import UIKit
import CoreLocation


class UserAuth: NSObject, NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(email, forKey: "email")
        aCoder.encode(password, forKey: "password")
    }
    
    required init?(coder aDecoder: NSCoder) {
        email = aDecoder.decodeObject(forKey: "email") as? String
        password = aDecoder.decodeObject(forKey: "password") as? String
    }
    
    var email : String?
    var password : String?
    
    override init() {
        
    }
    
    init(email : String, password: String){
        self.email = email
        self.password = password
    }
}

class UserInfo: NSObject {
    public static var sharedInstance:UserInfo = {
        let instance = UserInfo()
        return instance
    }()
    
    var currentLanguage : String {
        get{
            guard let language = UserDefaults(suiteName: "group.com.mr.clubafib.share")!.object(forKey: KEY_LANGUAGE) as? String else {
                return KEY_ENGLISH
            }
            return language
        }
        set{
            UserDefaults(suiteName: "group.com.mr.clubafib.share")!.set(newValue, forKey: KEY_LANGUAGE)
        }
    }
    
    // Login status
    var isLoggedIn : Bool!
    
    // Open status
    var isOpened : Bool{
        get{
            return UserDefaults(suiteName: "group.com.mr.clubafib.share")!.bool(forKey: KEY_OPENED)
        }
        set{
            UserDefaults(suiteName: "group.com.mr.clubafib.share")!.set(newValue, forKey: KEY_OPENED)
        }
    }
    
    // Remember status
    var isRemembered : Bool{
        get{
            return UserDefaults(suiteName: "group.com.mr.clubafib.share")!.bool(forKey: KEY_REMEMBERED)
        }
        set{
            UserDefaults(suiteName: "group.com.mr.clubafib.share")!.set(newValue, forKey: KEY_REMEMBERED)
        }
    }
    
    var userAuth : UserAuth? {
        get{
            let userDefaults = UserDefaults(suiteName: "group.com.mr.clubafib.share")!
            do{
                if let data = userDefaults.data(forKey: KEY_USER_AUTH) {
                    let userAuth = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as! UserAuth
                    return userAuth
                }
                return nil
            }catch (let error){
                #if DEBUG
                print("Failed to unarchive Data : \(error.localizedDescription)")
                #endif
                return nil
            }
        }
        set{
            do {
                let userDefaults = UserDefaults(suiteName: "group.com.mr.clubafib.share")!
                if let newValue = newValue {
                    let data = try NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: false)
                    userDefaults.set(data, forKey: KEY_USER_AUTH)
                    userDefaults.synchronize()
                }
            } catch (let error){
                #if DEBUG
                print("Failed to archive Data : \(error.localizedDescription)")
                #endif
            }
        }
    }
    
    // Device Token
    func getDeviceToken() -> String{
        let userDefaults = UserDefaults(suiteName: "group.com.mr.clubafib.share")!
        if let deviceToken = userDefaults.object(forKey: KEY_DEVICE_TOKEN) as? String {
            return deviceToken
        }
        else{
            return ""
        }
    }
    
    var accessToken: String! = ""
    
    var refreshToken: String{
        get{
            guard let refresh_token = UserDefaults(suiteName: "group.com.mr.clubafib.share")!.string(forKey: KEY_REFRESH_TOKEN) else { return "" }
            return refresh_token
        }
        set{
            UserDefaults(suiteName: "group.com.mr.clubafib.share")!.set(newValue, forKey: KEY_REFRESH_TOKEN)
            UserDefaults(suiteName: "group.com.mr.clubafib.share")!.synchronize()
        }
    }
    
    // user data from login
    var userData : User!
    
    var userPayment: Payment?
    
    func saveUsername() {
        let userDefaults = UserDefaults(suiteName: "group.com.mr.clubafib.share")!
        userDefaults.set(userData.username, forKey: KEY_USERNAME)
        userDefaults.synchronize()
    }
    
    func saveUserDataToLocal() {
        do {
            let userDefaults = UserDefaults(suiteName: "group.com.mr.clubafib.share")!
            let data = try NSKeyedArchiver.archivedData(withRootObject: userData!, requiringSecureCoding: false)
            userDefaults.set(data, forKey: KEY_USER_DATA)
            userDefaults.set(userData.username, forKey: KEY_USERNAME)
            userDefaults.synchronize()
        } catch (let error){
            #if DEBUG
            print("Failed to archive Data : \(error.localizedDescription)")
            #endif
        }
    }
    
    func loadUserDataFromLocal() {
        isLoggedIn = false
        
        if isRemembered
        {
            isLoggedIn = true
            
            let userDefaults = UserDefaults(suiteName: "group.com.mr.clubafib.share")!
            do{
                if let data = userDefaults.data(forKey: KEY_USER_DATA) {
                    userData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? User
                }
            }catch (let error){
                #if DEBUG
                print("Failed to unarchive Data : \(error.localizedDescription)")
                #endif
                isLoggedIn = false
            }
        }
    }
    
    func clearDataFromLocal() {
        isRemembered = false
        isLoggedIn = false
        UserDefaults(suiteName: "group.com.mr.clubafib.share")!.removeObject(forKey: KEY_USER_DATA)
//        UserDefaults(suiteName: "group.com.mr.clubafib.share")!.removeObject(forKey: KEY_USER_AUTH)
    }
    
    var currentLocation : CLLocation?
    var doctorList: [Doctor] = []
}
