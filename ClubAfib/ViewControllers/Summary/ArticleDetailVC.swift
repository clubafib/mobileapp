//
//  ArticleDetailVC.swift
//  ClubAfib
//
//  Created by Rener on 7/25/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit

class ArticleDetailVC: UIViewController {
    
    @IBOutlet weak var imgBanner: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tvDescription: UITextView!
    @IBOutlet weak var lblCaption: UILabel!
    @IBOutlet weak var vwActions: UIView!
    @IBOutlet weak var vwContent: UIView!
    @IBOutlet weak var vwScroll: UIScrollView!
    
    @IBOutlet weak var imgLike: UIImageView!
    @IBOutlet weak var lblLike: UILabel!
    @IBOutlet weak var imgDislike: UIImageView!
    @IBOutlet weak var lblDislike: UILabel!
    
    var article: Article!
    var fullscreenImageView: MediaZoom!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if article.banner != nil && !article.banner!.isEmpty
        {
            imgBanner.sd_setImage(with: URL(string: article.banner!))
            let bannerTapGesture = UITapGestureRecognizer(target: self, action: #selector(onBannerTapped))
            imgBanner.isUserInteractionEnabled = true
            imgBanner.addGestureRecognizer(bannerTapGesture)
        }
        else
        {
            imgBanner.image = UIImage(named: "article1")
        }
        lblTitle.text = article.title
        lblCaption.text = article.caption
        tvDescription.attributedText = article.description?.interpretAsHTML(font: "Avenir Book", size: 17.0)
        tvDescription.delegate = self
        updatReaction()
        
        let likeTapGesture = UITapGestureRecognizer(target: self, action: #selector(onLikeButtonTapped))
        imgLike.isUserInteractionEnabled = true
        imgLike.addGestureRecognizer(likeTapGesture)
        
        let dislikeTapGesture = UITapGestureRecognizer(target: self, action: #selector(onDislikeButtonTapped))
        imgDislike.isUserInteractionEnabled = true
        imgDislike.addGestureRecognizer(dislikeTapGesture)
        
        fullscreenImageView = MediaZoom(with: imgBanner, animationTime: 0.5, useBlur: true)
        
        lblCaption.sizeToFit()
        lblTitle.sizeToFit()
//        lblCaption.backgroundColor = UIColor.gray
        vwActions.frame.origin = CGPoint(x:vwActions.frame.origin.x, y:lblCaption.frame.origin.y + lblCaption.frame.size.height + 5)
        lblTitle.frame.origin = CGPoint(x:lblTitle.frame.origin.x, y:vwActions.frame.origin.y + vwActions.frame.size.height + 5)
        tvDescription.frame.origin = CGPoint(x:tvDescription.frame.origin.x, y:lblTitle.frame.origin.y + lblTitle.frame.size.height + 5)
        tvDescription.sizeToFit()
        
        vwContent.frame.size.height = tvDescription.frame.origin.y + tvDescription.frame.size.height + 20
        vwScroll.contentSize = vwContent.frame.size
    }
    
    private func updatReaction() {
        lblLike.text = "\(self.article.likes.count)"
        var isLiked = false
        for like in self.article.likes {
            if like.user_id == UserInfo.sharedInstance.userData.userId {
                isLiked = true
            }
        }
        imgLike.tintColor = isLiked ? .systemOrange : .lightGray
        
        lblDislike.text = "\(self.article.dislikes.count)"
        var isDisliked = false
        for dislike in self.article.dislikes {
            if dislike.user_id == UserInfo.sharedInstance.userData.userId {
                isDisliked = true
            }
        }
        imgDislike.tintColor = isDisliked ? .systemOrange : .lightGray
        NotificationCenter.default.post(name: Notification.Name(USER_NOTIFICATION_ARTICLE_UPDATED), object: nil)
    }
    
    private func react(_ isLike: Bool) {
        let params:[String: Any] = [
            "relation_id": self.article.id!,
            "type": 1,
            "value": (isLike ? 1 : 2)
        ]
        ApiManager.sharedInstance.reaction(params: params) {likes, dislikes, errorMsg in
            if let likes = likes, let dislikes = dislikes {
                self.article.likes = likes
                self.article.dislikes = dislikes

                DispatchQueue.main.async {
                    self.updatReaction()
                }
            }
        }
    }
    
    @objc func onBannerTapped() {
        self.view.addSubview(self.fullscreenImageView)
        self.fullscreenImageView.show()
    }
    
    @objc func onLikeButtonTapped() {
        self.react(true)
    }
    
    @objc func onDislikeButtonTapped() {
        self.react(false)
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}

extension ArticleDetailVC: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        textView.selectedRange = NSMakeRange(0, 0)
    }
}
