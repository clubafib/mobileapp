//
//  SummaryVC.swift
//  ClubAfib
//
//  Created by Rener on 7/25/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit
import GoogleMobileAds

class SummaryVC: UIViewController {
    
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var imgMenu: UIImageView!
    @IBOutlet weak var tblArticles: UITableView!
    @IBOutlet weak var tblGoods: UITableView!
    @IBOutlet weak var bannerContainer: UIView!
    
    @IBOutlet weak var tvArticlesHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tvGoodsHeightConstraint: NSLayoutConstraint!
    
    var bannerView: GADBannerView!
    
    var articles = [Article]()
    var goods = [Goods]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initTopbar()
        self.tblArticles.isScrollEnabled = false
        self.tblGoods.isScrollEnabled = false
        
        self.geArticles()
//        self.getGoods()
        self.tvGoodsHeightConstraint?.constant = 0 // hide goods view
//        self.initAdmob()
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
    
    private func initAdmob() {
        // In this case, we instantiate the banner with desired ad size.
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        addBannerViewToView(bannerView)
        
        bannerView.adUnitID = "ca-app-pub-8501671653071605/1974659335"
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.load(GADRequest())
    }
    
    private func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerContainer.addSubview(bannerView)
        bannerContainer.addConstraints(
        [NSLayoutConstraint(item: bannerView,
                        attribute: .centerY,
                        relatedBy: .equal,
                        toItem: bannerContainer,
                        attribute: .centerY,
                        multiplier: 1,
                        constant: 0),
        NSLayoutConstraint(item: bannerView,
                        attribute: .centerX,
                        relatedBy: .equal,
                        toItem: bannerContainer,
                        attribute: .centerX,
                        multiplier: 1,
                        constant: 0),
        NSLayoutConstraint(item: bannerView,
                        attribute: .width,
                        relatedBy: .equal,
                        toItem: bannerContainer,
                        attribute: .width,
                        multiplier: 1,
                        constant: 0),
        NSLayoutConstraint(item: bannerView,
                        attribute: .height,
                        relatedBy: .equal,
                        toItem: bannerContainer,
                        attribute: .height,
                        multiplier: 1,
                        constant: 0)
        ])
    }
    
    func geArticles(){
        ApiManager.sharedInstance.getArticles(params: nil){
            articles, errorMsg in
            
            if articles != nil {
                self.articles.removeAll()
                self.articles = articles!
                self.tvArticlesHeightConstraint?.constant = CGFloat.greatestFiniteMagnitude
                self.tblArticles.reloadData()
                self.tblArticles.layoutIfNeeded()
                self.tvArticlesHeightConstraint?.constant = self.tblArticles.contentSize.height
            }
        }
    }
    
    func getGoods(){
        ApiManager.sharedInstance.getGoods(params: nil){
            goods, errorMsg in
            if goods != nil {
                self.goods.removeAll()
                self.goods.append(contentsOf: goods!.sorted(by: { $0.createdAt.compare($1.createdAt) == .orderedDescending }))
                self.tvGoodsHeightConstraint?.constant = CGFloat.greatestFiniteMagnitude
                self.tblGoods.reloadData()
                self.tblGoods.layoutIfNeeded()
                self.tvGoodsHeightConstraint?.constant = self.tblGoods.contentSize.height
            }
        }
    }
    
    private func gotoArticleDetail(_ article: Article) {
        let articleDetailVC = HOME_STORYBOARD.instantiateViewController(withIdentifier: "ArticleDetailVC") as! ArticleDetailVC
        articleDetailVC.article = article
        self.navigationController?.pushViewController(articleDetailVC, animated: true)
    }
    
    private func gotoGoodsDetail(_ goods: Goods) {
        let goodsDetailVC = HOME_STORYBOARD.instantiateViewController(withIdentifier: "GoodsDetailVC") as! GoodsDetailVC
        goodsDetailVC.goods = goods
        self.navigationController?.pushViewController(goodsDetailVC, animated: true)
    }

    @IBAction func onShareButtonPressed(_ sender: Any) {
        shareScreenshot()
    }

}

extension SummaryVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblArticles {
            return self.articles.count
        }
        else if tableView == tblGoods {
            return self.goods.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        if tableView == tblArticles {
            cell = tableView.dequeueReusableCell(withIdentifier: "article_viewcell", for: indexPath)
            (cell as! ArticleViewCell).setData(articles[indexPath.row])
        }
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: "goods_viewcell", for: indexPath)
            (cell as! GoodsViewCell).setData(goods[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView == tblArticles {
            let article = self.articles[indexPath.row]
            self.gotoArticleDetail(article)
        }
        else if tableView == tblGoods {
            let goods = self.goods[indexPath.row]
            self.gotoGoodsDetail(goods)
        }
    }

}

extension SummaryVC: GADBannerViewDelegate {
    
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            bannerView.alpha = 1
        })
    }

    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
    }

    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }

    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }

    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }
    
}
