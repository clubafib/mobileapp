//
//  CategoryVC.swift
//  ClubAfib
//
//  Created by Rener on 7/29/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit

class CategoryVC: UIViewController {
    
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var imgMenu: UIImageView!
    @IBOutlet weak var tblCategories: UITableView!
    
    var categories: [HealthCategory] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initTopbar()
        self.initCategories()
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
    
    func initCategories() {
        categories.removeAll()
        
        var category = HealthCategory()
        category.icon = "ic_run"
        category.title = "Activity".localized()
        category.type = .Activity
        categories.append(category)
        
        category = HealthCategory()
        category.icon = "ic_scale"
        category.title = "Body Weight".localized()
        category.type = .BodyMeasurements
        categories.append(category)
        
        category = HealthCategory()
        category.icon = "ic_walk"
        category.title = "Steps".localized()
        category.type = .Steps
        categories.append(category)
        
        category = HealthCategory()
        category.icon = "ic_bed"
        category.title = "Sleep".localized()
        category.type = .Sleep
        categories.append(category)
        
        category = HealthCategory()
        category.icon = "ic_drink"
        category.title = "Alcohol Use".localized()
        category.type = .AlcoholUse
        categories.append(category)
        
        category = HealthCategory()
        category.icon = "ic_bloodpressure"
        category.title = "Blood Pressure".localized()
        category.type = .BloodPressure
        categories.append(category)
        
        tblCategories.reloadData()
    }

    @IBAction func onShareButtonPressed(_ sender: Any) {
        shareScreenshot()
    }

}

extension CategoryVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "healthcategory_viewcell", for: indexPath) as! HealthCategoryViewCell
        cell.setData(categories[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let category = categories[indexPath.row]
        switch category.type {
        case .Activity:
            let activityVC = HOME_STORYBOARD.instantiateViewController(withIdentifier: "ActivitySummaryVC") as! ActivitySummaryVC
            self.navigationController?.pushViewController(activityVC, animated: true)
            break;
        case .BodyMeasurements:
            let bodyWeightVC = HOME_STORYBOARD.instantiateViewController(withIdentifier: "BodyWeightVC") as! BodyWeightVC
            self.navigationController?.pushViewController(bodyWeightVC, animated: true)
            break;
        case .Steps:
            let stepsVC = HOME_STORYBOARD.instantiateViewController(withIdentifier: "StepsVC") as! StepsVC
            self.navigationController?.pushViewController(stepsVC, animated: true)
            break;
        case .Sleep:
            let sleepVC = HOME_STORYBOARD.instantiateViewController(withIdentifier: "SleepVC") as! SleepVC
            self.navigationController?.pushViewController(sleepVC, animated: true)
            break;
        case .AlcoholUse:
            let alcoholUseVC = HOME_STORYBOARD.instantiateViewController(withIdentifier: "AlcoholUseVC") as! AlcoholUseVC
            self.navigationController?.pushViewController(alcoholUseVC, animated: true)
            break;
        case .BloodPressure:
            let bloodPressureVC = HOME_STORYBOARD.instantiateViewController(withIdentifier: "BloodPressureVC") as! BloodPressureVC
            self.navigationController?.pushViewController(bloodPressureVC, animated: true)
            break;
        default:
            break;
        }
    }

}
