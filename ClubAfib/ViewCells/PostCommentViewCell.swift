//
//  PostCommentViewCell.swift
//  ClubAfib
//
//  Created by Rener on 8/19/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit

class PostCommentViewCell: UITableViewCell {

    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var tvContent: UITextView!
    
    @IBOutlet weak var imgLike: UIImageView!
    @IBOutlet weak var lblLike: UILabel!
    @IBOutlet weak var imgDislike: UIImageView!
    @IBOutlet weak var lblDislike: UILabel!
    
    var comment: PostComment!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setData(_ comment: PostComment) {
        self.comment = comment
        
        if let photoURL = comment.user.photo {
            imgAvatar.sd_setImage(with: URL(string: photoURL))
        }
        else {
            imgAvatar.image = UIImage(named: "default_avatar")
        }
        lblName.text = comment.user.username
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a, MMM d"
        lblTime.text = dateFormatter.string(from: comment.createdAt)
        tvContent.attributedText = comment.content?.interpretAsHTML(font: "Avenir Book", size: 17.0)
        tvContent.delegate = self
        updatReaction()
        
        let likeTapGesture = UITapGestureRecognizer(target: self, action: #selector(onLikeButtonTapped))
        imgLike.isUserInteractionEnabled = true
        imgLike.addGestureRecognizer(likeTapGesture)
        
        let dislikeTapGesture = UITapGestureRecognizer(target: self, action: #selector(onDislikeButtonTapped))
        imgDislike.isUserInteractionEnabled = true
        imgDislike.addGestureRecognizer(dislikeTapGesture)
    }
    
    private func updatReaction() {
        lblLike.text = "\(self.comment.likes.count)"
        var isLiked = false
        for like in self.comment.likes {
            if like.user_id == UserInfo.sharedInstance.userData.userId {
                isLiked = true
            }
        }
        imgLike.tintColor = isLiked ? .systemOrange : .lightGray
        
        lblDislike.text = "\(self.comment.dislikes.count)"
        var isDisliked = false
        for dislike in self.comment.dislikes {
            if dislike.user_id == UserInfo.sharedInstance.userData.userId {
                isDisliked = true
            }
        }
        imgDislike.tintColor = isDisliked ? .systemOrange : .lightGray
    }
    
    private func react(_ isLike: Bool) {
        let params:[String: Any] = [
            "relation_id": self.comment.id!,
            "type": 3,
            "value": (isLike ? 1 : 2)
        ]
        ApiManager.sharedInstance.reaction(params: params) {likes, dislikes, errorMsg in
            if let likes = likes, let dislikes = dislikes {
                self.comment.likes = likes
                self.comment.dislikes = dislikes

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

extension PostCommentViewCell: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        textView.selectedRange = NSMakeRange(0, 0)
    }
}
