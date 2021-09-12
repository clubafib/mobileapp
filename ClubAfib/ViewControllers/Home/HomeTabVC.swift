//
//  HomeTabVC.swift
//  Home
//
//  Created by Rener on 7/20/20.
//  Copyright © 2020 ExtremeMobile. All rights reserved.
//

import UIKit
import SideMenu

class HomeTabVC: UITabBarController {
    
    var sideMenu:UISideMenuNavigationController!
    var requireAutoLogin = false
    
    var btnMenu: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authorizeHealthKit()
//        addTopBar()
        initSideMenu()
        
//        NotificationCenter.default.addObserver(self, selector: #selector(self.onProfileUpdated), name: NSNotification.Name(USER_NOTIFICATION_PROFILE_CHANGED), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onMenuClicked(sender:)), name: NSNotification.Name(USER_NOTIFICATION_OPEN_MENU), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.onDataFeteched), name: NSNotification.Name(USER_NOTIFICATION_FECTED_DATA), object: nil)
//        showLoadingProgress(view: self.navigationController?.view, label: "Please Stay Patient")
    }
    
    @objc func onDataFeteched(){
        dismissLoadingProgress(view: self.navigationController?.view)
    }
    
    @objc func onProfileUpdated() {
        if let user = UserInfo.sharedInstance.userData {
            btnMenu.sd_setImage(with: URL(string: user.photo ?? ""), placeholderImage: UIImage(named: "default_avatar"))
        }
        else {
            btnMenu.image = UIImage(named: "default_avatar")
        }
    }


    private func authorizeHealthKit() {
        HealthKitHelper.default.authorizeHealthKit { (authorized, error) in
            guard authorized else {
                let baseMessage = "HealthKit Authorization Failed"

                if let error = error {
                    print("\(baseMessage). Reason: \(error.localizedDescription)")
                } else {
                    print(baseMessage)
                }

                return
            }

            print("HealthKit Successfully Authorized.")
                        
            DispatchQueue.main.async {
                if self.requireAutoLogin {
                    self.autoLogin()
                } else {
//                    HealthDataManager.default.fetchData()
                }
            }    
        }
      
    }
    
    func addTopBar()
    {
        let vwTopBar = UIView(frame: CGRect(x: 0, y: STATUS_BAR_HEIGHT, width: SCREEN_WIDTH, height: TOP_BAR_HEIGHT))
        vwTopBar.backgroundColor = .white
        self.view.addSubview(vwTopBar)
        
        // menu button in top bar
        btnMenu = UIImageView()
        btnMenu.contentMode = .scaleAspectFill
        btnMenu.frame = CGRect(x: 15, y: 0, width: TOP_BAR_HEIGHT - 5, height: TOP_BAR_HEIGHT - 5)
        
        if let user = UserInfo.sharedInstance.userData {
            btnMenu.sd_setImage(with: URL(string: user.photo ?? ""), placeholderImage: UIImage(named: "default_avatar"))
        }
        else {
            btnMenu.image = UIImage(named: "default_avatar")
        }
        btnMenu.cornerRadius = CGFloat(Double(TOP_BAR_HEIGHT - 5) / 2.0)
        btnMenu.layer.masksToBounds = true
        
        let menuTap = UITapGestureRecognizer(target: self, action: #selector(self.onMenuClicked(sender:)))
        btnMenu.isUserInteractionEnabled = true
        btnMenu.addGestureRecognizer(menuTap)
        vwTopBar.addSubview(btnMenu)
        
        // menu button in top right
        let btnNotifications = UIButton()
        btnNotifications.frame = CGRect(x: SCREEN_WIDTH - 32 - 20, y: 9, width: 32, height: 32)
        btnNotifications.setImage(UIImage(named: "ic_share"), for: .normal)
        btnNotifications.tintColor = UIColor(red: 0, green: 35/255.0, blue: 99/255.0, alpha: 1.0)
        btnNotifications.addTarget(self, action: #selector(self.onShareButtonTapped(sender:)), for: .touchUpInside)
        vwTopBar.addSubview(btnNotifications)
        
        vwTopBar.shadowColor = UIColor.black
        vwTopBar.shadowRadius = 1
        vwTopBar.shadowOpacity = 0.2
        vwTopBar.shadowOffset = CGSize(width: 0, height: 2)
    }
    
    func initSideMenu()
    {
        let menuVC = HOME_STORYBOARD.instantiateViewController(withIdentifier: "MenuVC") as! MenuVC
        menuVC.mainNavigationController = self.navigationController
        menuVC.modalPresentationStyle = .fullScreen
        sideMenu = UISideMenuNavigationController(rootViewController: menuVC)
        sideMenu.navigationBar.isHidden = true
        sideMenu.leftSide = true
        SideMenuManager.default.menuLeftNavigationController = sideMenu
        SideMenuManager.default.menuPresentMode = .viewSlideInOut
        SideMenuManager.default.menuPushStyle = .popWhenPossible
        SideMenuManager.default.menuFadeStatusBar = false
        SideMenuManager.default.menuWidth = 280
    }
    
    @objc func onMenuClicked(sender: UIButton!) {
        present(sideMenu, animated: true, completion: nil)
    }
    
    @objc func onShareButtonTapped(sender: UIButton!) {
        self.shareScreenshot()
    }
    
    func autoLogin(){
        let params : [String : Any] = [
            "email" : UserInfo.sharedInstance.userAuth!.email!,
            "password" : UserInfo.sharedInstance.userAuth!.password!
        ]
        
        // Call login api
        ApiManager.sharedInstance.login(params: params) { (success, errorMsg) in
            DispatchQueue.main.async {
                // Hide the loading progress
                
                if success {
                    self.getDoctorList()
//                    HealthDataManager.default.fetchData()
                }
                else{
                    let signinVC = AUTHENTICATION_STORYBOARD.instantiateViewController(withIdentifier: "SigninVC") as! SigninVC
                    self.navigationController?.pushViewController(signinVC, animated: true)
                }
            }
        }
    }
    
    func getDoctorList(){
        ApiManager.sharedInstance.getDoctorList(){
            data, errorMsg, status in
        }
    }
}
