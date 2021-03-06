//
//  AppDelegate.swift
//  ClubAfib
//
//  Created by Rener on 7/17/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
//import FirebaseMessaging
import FirebaseFirestore
import GoogleSignIn
import FBSDKLoginKit
import FBSDKCoreKit
import GoogleMobileAds
import Stripe
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        // Config Firebase
        FirebaseApp.configure()
//        Messaging.messaging().delegate = self
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        Stripe.setDefaultPublishableKey("pk_live_51HBRLBDXfzAe8AxYUQzxdlhmgQfmUwgICSXNaSlnYVK343tkvvbCZUdZwrNwpPJ708R9TCumbXQAGuUqmPilQjUI000HqY6LWS")
        
        // it requires to load saved user data
        UserInfo.sharedInstance.loadUserDataFromLocal()
        
        // Initialize Facebook sdk
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Google SignIn
        GIDSignIn.sharedInstance().clientID = "469629177922-j83v466r4noajnd2uljmjom5eli4981e.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        
        if UserInfo.sharedInstance.isOpened {
            let navigationController = UIApplication.shared.windows.first!.rootViewController as! UINavigationController
            
            if UserInfo.sharedInstance.isLoggedIn {
                let homeTabVC = HOME_STORYBOARD.instantiateViewController(withIdentifier: "HomeTabVC") as! HomeTabVC
                homeTabVC.requireAutoLogin = true
                navigationController.pushViewController(homeTabVC, animated: false)
            }
        }
        else {
            UserInfo.sharedInstance.isOpened = true
        }
        
        return true
    }
}

extension AppDelegate{
//    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
//        print("Firebase registration token: \(fcmToken)")
//        UserDefaults(suiteName: "group.com.mr.clubafib.share")!.set(fcmToken, forKey: KEY_DEVICE_TOKEN)
//    }
//
//    // Called when APNs has assigned the device a unique token
//    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//
//        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
//        print("APNs Device Token : " + deviceTokenString)
//
//        Messaging.messaging().apnsToken = deviceToken
//    }
//
//    // called when APNs failed to register the device for push notification
//    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
//        print("Notification Register error = \(error.localizedDescription)")
//    }
//
//    // [START receive_message]
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
//        // If you are receiving a notification message while your app is in the background,
//        // this callback will not be fired till the user taps on the notification launching the application.
//
//        // Print full message.
//        print("Received Push notification\n")
//        print(userInfo)
//    }
//
//    // Push notification received
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        // If you are receiving a notification message while your app is in the background,
//        // this callback will not be fired till the user taps on the notification launching the application.
//        // TODO: Handle data of notification
//
//        print("Received push notification \n")
//        print(userInfo)
//
//        completionHandler(UIBackgroundFetchResult.newData)
//    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
        -> Bool {
                       
            return ApplicationDelegate.shared.application(application, open: url, options: options) || GIDSignIn.sharedInstance()!.handle(url)
    }
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        return ApplicationDelegate.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation) || GIDSignIn.sharedInstance()!.handle(url)
        
    }
    
    // MARK :- GIDSignInDelegate
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if error != nil {
            // ...
            return
        }

        guard let authentication = user.authentication else { return }
        // ...
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
}

