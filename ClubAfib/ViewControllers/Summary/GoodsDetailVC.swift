//
//  GoodsDetailVC.swift
//  ClubAfib
//
//  Created by Rener on 8/21/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit

class GoodsDetailVC: UIViewController {
    
    @IBOutlet weak var imgBanner: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    
    @IBOutlet weak var imgLike: UIImageView!
    @IBOutlet weak var lblLike: UILabel!
    @IBOutlet weak var imgDislike: UIImageView!
    @IBOutlet weak var lblDislike: UILabel!
    
    var goods: Goods!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if goods.image != nil && !goods.image!.isEmpty
        {
            imgBanner.sd_setImage(with: URL(string: goods.image!))
        }
        else
        {
            imgBanner.image = UIImage(named: "article1")
        }
        lblTitle.text = goods.name
        lblDescription.text = goods.description
        lblPrice.text = String(format: "$%d", Int(goods.price))
        updatReaction()
        
        let likeTapGesture = UITapGestureRecognizer(target: self, action: #selector(onLikeButtonTapped))
        imgLike.isUserInteractionEnabled = true
        imgLike.addGestureRecognizer(likeTapGesture)
        
        let dislikeTapGesture = UITapGestureRecognizer(target: self, action: #selector(onDislikeButtonTapped))
        imgDislike.isUserInteractionEnabled = true
        imgDislike.addGestureRecognizer(dislikeTapGesture)
    }
    
    private func updatReaction() {
        lblLike.text = "\(self.goods.likes.count)"
        var isLiked = false
        for like in self.goods.likes {
            if like.user_id == UserInfo.sharedInstance.userData.userId {
                isLiked = true
            }
        }
        imgLike.tintColor = isLiked ? .systemOrange : .lightGray
        
        lblDislike.text = "\(self.goods.dislikes.count)"
        var isDisliked = false
        for dislike in self.goods.dislikes {
            if dislike.user_id == UserInfo.sharedInstance.userData.userId {
                isDisliked = true
            }
        }
        imgDislike.tintColor = isDisliked ? .systemOrange : .lightGray
        NotificationCenter.default.post(name: Notification.Name(USER_NOTIFICATION_GOODS_UPDATED), object: nil)
    }
    
    private func react(_ isLike: Bool) {
        let params:[String: Any] = [
            "relation_id": self.goods.id!,
            "type": 2,
            "value": (isLike ? 1 : 2)
        ]
        ApiManager.sharedInstance.reaction(params: params) {likes, dislikes, errorMsg in
            if let likes = likes, let dislikes = dislikes {
                self.goods.likes = likes
                self.goods.dislikes = dislikes

                DispatchQueue.main.async {
                    self.updatReaction()
                }
            }
        }
    }
    
    @objc func onLikeButtonTapped() {
        self.react(true)
    }
    
    @objc func onDislikeButtonTapped() {
        self.react(false)
    }
    
    @IBAction func onBuyButtonTapped(_ sender: Any) {
        if let link = goods.link,
            let url = URL(string: link) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}
