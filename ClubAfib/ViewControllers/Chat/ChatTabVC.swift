//
//  ChatTabVC.swift
//  ClubAfib
//
//  Created by Rener on 8/9/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class ChatTabVC: ButtonBarPagerTabStripViewController {
    
    @IBOutlet weak var imgMenu: UIImageView!
    @IBOutlet weak var imgLogo: UIImageView!
    
    override func viewDidLoad() {
        self.initTopbar()
        
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        settings.style.buttonBarItemLeftRightMargin = 0
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.selectedBarBackgroundColor = UIColor.init(red: 0.0, green: 0.17, blue: 0.38, alpha: 1.0)
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }

            oldCell?.label.textColor = UIColor.init(red: 0.0, green: 0.17, blue: 0.38, alpha: 0.6)
            newCell?.label.textColor = UIColor.init(red: 0.0, green: 0.17, blue: 0.38, alpha: 1.0)
        }
        
        super.viewDidLoad()
        ApiManager.sharedInstance.getLogo { (url) in
            if let url = url {
                self.imgLogo.sd_setImage(with: URL(string: url)!, completed: nil)
            }
        }
    }
    
    private func initTopbar() {
        self.setProfileMenu()
        
        let menuTap = UITapGestureRecognizer(target: self, action: #selector(self.onMenuClicked(sender:)))
        self.imgMenu.isUserInteractionEnabled = true
        self.imgMenu.addGestureRecognizer(menuTap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.setProfileMenu), name: NSNotification.Name(USER_NOTIFICATION_PROFILE_CHANGED), object: nil)
    }
    
    @objc private func setProfileMenu() {
        let user = UserInfo.sharedInstance.userData
        if let photo = user?.photo {
            imgMenu.sd_setImage(with: URL(string: photo), placeholderImage: UIImage(named: "default_avatar"))
        }
        else {
            imgMenu.image = UIImage(named: "default_avatar")
        }
    }
    
    @objc func onMenuClicked(sender: UIButton!) {
        NotificationCenter.default.post(name: Notification.Name(USER_NOTIFICATION_OPEN_MENU), object: nil)
    }
    
    override public func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let contactsVC = HOME_STORYBOARD.instantiateViewController(withIdentifier: "ContactsVC") as! ContactsVC
        let chatHistoryVC = HOME_STORYBOARD.instantiateViewController(withIdentifier: "ChatHistoryVC") as! ChatHistoryVC
        
      return [contactsVC, chatHistoryVC]
    }

    @IBAction func onShareButtonPressed(_ sender: Any) {
        shareScreenshot()
    }

}
