//
//  PostViewCell.swift
//  ClubAfib
//
//  Created by Rener on 8/19/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit

class PostViewCell: UITableViewCell {
    
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    @IBOutlet weak var imgPost: UIImageView!
    @IBOutlet weak var mediaView: UIView!
    //    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    @IBOutlet weak var imgLike: UIImageView!
    @IBOutlet weak var lblLike: UILabel!
    @IBOutlet weak var imgDislike: UIImageView!
    @IBOutlet weak var lblDislike: UILabel!
    
    @IBOutlet weak var lblComment: UILabel!
    
    var post: Post!
    var mediaConstraint: NSLayoutConstraint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let likeTapGesture = UITapGestureRecognizer(target: self, action: #selector(onLikeButtonTapped))
        imgLike.isUserInteractionEnabled = true
        imgLike.addGestureRecognizer(likeTapGesture)
        
        let dislikeTapGesture = UITapGestureRecognizer(target: self, action: #selector(onDislikeButtonTapped))
        imgDislike.isUserInteractionEnabled = true
        imgDislike.addGestureRecognizer(dislikeTapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateCell), name: NSNotification.Name(USER_NOTIFICATION_POST_UPDATED), object: nil)
    }
    
    func setData(_ post: Post) {
        self.post = post
        self.updateCell()
    }
    
    @objc func updateCell() {
        if post.creator.photo != nil && !post.creator.photo!.isEmpty
        {
            imgUser.sd_setImage(with: URL(string: post.creator.photo!))
        }
        else
        {
            imgUser.image = UIImage(named: "default_avatar")
        }
        lblUsername.text = post.nickname

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a, MMM d"
        lblTime.text = dateFormatter.string(from: post.createdAt)
        
        self.mediaView.translatesAutoresizingMaskIntoConstraints = false
        if self.mediaConstraint != nil {
            self.mediaView.removeConstraint(self.mediaConstraint!)
        }
        if post.image != nil && !post.image!.isEmpty
        {
            self.mediaConstraint = NSLayoutConstraint(item: mediaView!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mediaView, attribute: NSLayoutConstraint.Attribute.width, multiplier: 9.0 / 16.0, constant: 0)
            self.imgPost.sd_setImage(with: URL(string: post.image!))
        }
        else
        {
            imgPost.image = nil
            self.mediaConstraint = NSLayoutConstraint(item: mediaView!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mediaView, attribute: NSLayoutConstraint.Attribute.width, multiplier: 0, constant: 0)
        }
        self.mediaView.addConstraint(self.mediaConstraint!)
        
//        lblTitle.text = post.title
        lblDescription.text = post.description
        lblComment.text = "\(post.comments.count)"
        updatReaction()
    }
    
    private func updatReaction() {
        lblLike.text = "\(self.post.likes.count)"
        var isLiked = false
        for like in self.post.likes {
            if like.user_id == UserInfo.sharedInstance.userData.userId {
                isLiked = true
            }
        }
        imgLike.tintColor = isLiked ? .systemOrange : .lightGray
        
        lblDislike.text = "\(self.post.dislikes.count)"
        var isDisliked = false
        for dislike in self.post.dislikes {
            if dislike.user_id == UserInfo.sharedInstance.userData.userId {
                isDisliked = true
            }
        }
        imgDislike.tintColor = isDisliked ? .systemOrange : .lightGray
    }
    
    private func react(_ isLike: Bool) {
        let params:[String: Any] = [
            "relation_id": self.post.id!,
            "type": 0,
            "value": (isLike ? 1 : 2)
        ]
        ApiManager.sharedInstance.reaction(params: params) {likes, dislikes, errorMsg in
            if let likes = likes, let dislikes = dislikes {
                self.post.likes = likes
                self.post.dislikes = dislikes

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
