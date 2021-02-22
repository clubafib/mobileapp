//
//  ShareNavigationController.swift
//  Share
//
//  Created by Rener on 9/3/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit

@objc(ShareNavigationController)
class ShareNavigationController: UINavigationController {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

//        // 2: set the ViewControllers
//        self.setViewControllers([ShareViewController()], animated: false)
        
        let shareVC = UIStoryboard.init(name: "MainInterface", bundle: nil).instantiateViewController(withIdentifier: "ShareViewController") as! ShareViewController
        self.pushViewController(shareVC, animated: true)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
