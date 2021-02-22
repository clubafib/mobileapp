//
//  ArticleViewCell.swift
//  ClubAfib
//
//  Created by Rener on 7/25/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit

class ArticleViewCell: UITableViewCell {
    
    @IBOutlet weak var imgBanner: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    @IBOutlet weak var imgLike: UIImageView!
    @IBOutlet weak var lblLike: UILabel!
    @IBOutlet weak var imgDislike: UIImageView!
    @IBOutlet weak var lblDislike: UILabel!
    
    var article: Article!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let likeTapGesture = UITapGestureRecognizer(target: self, action: #selector(onLikeButtonTapped))
        imgLike.isUserInteractionEnabled = true
        imgLike.addGestureRecognizer(likeTapGesture)
        
        let dislikeTapGesture = UITapGestureRecognizer(target: self, action: #selector(onDislikeButtonTapped))
        imgDislike.isUserInteractionEnabled = true
        imgDislike.addGestureRecognizer(dislikeTapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateCell), name: NSNotification.Name(USER_NOTIFICATION_ARTICLE_UPDATED), object: nil)
    }
    
    
    func setData(_ article: Article) {
        self.article = article
        self.updateCell()
    }
     
    @objc func updateCell() {
        if article.banner != nil && !article.banner!.isEmpty
        {
            imgBanner.sd_setImage(with: URL(string: article.banner!))
        }
        else
        {
            imgBanner.image = UIImage(named: "article1")
        }
        lblTitle.text = article.title
        lblDescription.attributedText = article.description?.interpretAsHTML(font: "Avenir Book", size: 17.0)
        updatReaction()
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
    
    @objc func onLikeButtonTapped() {
        self.react(true)
    }
    
    @objc func onDislikeButtonTapped() {
        self.react(false)
    }
    
}

