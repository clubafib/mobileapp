//
//  MenuVC.swift
//  Home
//
//  Created by Rener on 7/22/20.
//  Copyright © 2020 ExtremeMobile. All rights reserved.
//

import UIKit
import SDWebImage

class MenuVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var tblMenu: UITableView!
    @IBOutlet weak var logoutLabel: UILabel!
    
    var mainNavigationController : UINavigationController!
    
    var menuItems:[MenuItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        initMenu()
    }
    
    func initMenu()
    {
        let userInfo = UserInfo.sharedInstance
        
        // update avatar and name
        if userInfo.isLoggedIn
        {
            if let user = userInfo.userData {
                imgAvatar.sd_setImage(with: URL(string: user.photo ?? ""), placeholderImage: UIImage(named: "default_avatar"))
                lblName.text = "\(user.firstName!) \(user.lastName!)"
            }
        }
        else
        {
            imgAvatar.image = UIImage(named: "default_avatar")
            lblName.text = "Guest".localized()
        }
        
        // update menu
        menuItems.removeAll()
        
//        if userInfo.isLoggedIn
//        {
//            let profileItem = MenuItem()
//            profileItem.menuIcon = "ic_profile"
//            profileItem.menuTitle = "Profile".localized()
//            profileItem.type = MenuType.Profile
//            menuItems.append(profileItem)
//        }
        
        let profileItem = MenuItem()
//        aboutItem.menuIcon = "ic_about"
        profileItem.menuTitle = "Profile".localized()
        profileItem.type = MenuType.Profile
        menuItems.append(profileItem)
        
        let termsItem = MenuItem()
//        termsItem.menuIcon = "ic_contact"
        termsItem.menuTitle = "Terms of Service".localized()
        termsItem.type = MenuType.Terms
        menuItems.append(termsItem)
        
        let privacyItem = MenuItem()
//        privacyItem.menuIcon = "ic_share"
        privacyItem.menuTitle = "Privacy Policy".localized()
        privacyItem.type = MenuType.Privacy
        menuItems.append(privacyItem)
        
        let aboutItem = MenuItem()
//        aboutItem.menuIcon = "ic_share"
        aboutItem.menuTitle = "About Us".localized()
        aboutItem.type = MenuType.AboutUs
        menuItems.append(aboutItem)
        
        tblMenu.reloadData()
        
        let logoutTap = UITapGestureRecognizer(target: self, action: #selector(self.logoutTapped(_:)))
        logoutLabel.isUserInteractionEnabled = true
        logoutLabel.addGestureRecognizer(logoutTap)
        logoutLabel.text = "Logout".localized()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCell", for: indexPath) as! MenuItemCell
        cell.setMenuItem(menuItems[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let menuItem = menuItems[indexPath.row]
        switch menuItem.type! {
        case MenuType.Home:
            dismiss(animated: true, completion: nil)
            break;
        case MenuType.Profile:
            let profileVC = HOME_STORYBOARD.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            self.navigationController?.pushViewController(profileVC, animated: true)
            break;
        case MenuType.Terms:
            let termsVC = HOME_STORYBOARD.instantiateViewController(withIdentifier: "TermsVC") as! TermsVC
            self.navigationController?.pushViewController(termsVC, animated: true)
            dismiss(animated: true, completion: nil)
            break
        case MenuType.Privacy:
            let privacyVC = HOME_STORYBOARD.instantiateViewController(withIdentifier: "PrivacyVC") as! PrivacyVC
            self.navigationController?.pushViewController(privacyVC, animated: true)
            dismiss(animated: true, completion: nil)
            break
        case MenuType.AboutUs:
            let aboutVC = HOME_STORYBOARD.instantiateViewController(withIdentifier: "AboutVC") as! AboutVC
            self.navigationController?.pushViewController(aboutVC, animated: true)
            break;
        case MenuType.Contact:
            dismiss(animated: true, completion: nil)
            break;
        case MenuType.Share:
            let text = "This is the text....."
            let textShare = [ text ]
            let activityViewController = UIActivityViewController(activityItems: textShare , applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.navigationController?.present(activityViewController, animated: true, completion: nil)
            break;
        case MenuType.Setting:
//            let settingVC = HOME_STORYBOARD.instantiateViewController(withIdentifier: "SettingVC") as! SettingVC
//            self.navigationController?.pushViewController(settingVC, animated: true)
            break;
        default:
            break;
        }
    }
    
    @objc private func logoutTapped(_ sender: UITapGestureRecognizer) {
        UserInfo.sharedInstance.clearDataFromLocal()
        NotificationCenter.default.post(name: Notification.Name("UserLoggedOut"), object: nil)
        dismiss(animated: true, completion: nil)

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
