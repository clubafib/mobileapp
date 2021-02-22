//
//  PostDetailVC.swift
//  ClubAfib
//
//  Created by Rener on 8/19/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit

class PostDetailVC: UIViewController {
    
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var imgEditNickname: UIImageView!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var btnDelete: UIButton!
    
    @IBOutlet weak var imgPost: UIImageView!
//    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tvDescription: UITextView!
    
    @IBOutlet weak var imgLike: UIImageView!
    @IBOutlet weak var lblLike: UILabel!
    @IBOutlet weak var imgDislike: UIImageView!
    @IBOutlet weak var lblDislike: UILabel!
    @IBOutlet weak var lblComment: UILabel!
    
    @IBOutlet weak var tblComments: UITableView!
    @IBOutlet weak var tblCommentsHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tfAddComment: UITextField!
    
    
    var post: Post!
    var fullscreenImageView: MediaZoom!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if post.creator.photo != nil && !post.creator.photo!.isEmpty
        {
            self.imgUser.sd_setImage(with: URL(string: post.creator.photo!))
        }
        else
        {
            self.imgUser.image = UIImage(named: "default_avatar")
        }
        self.lblUsername.text = post.nickname
        let editNicknameTapGesture = UITapGestureRecognizer(target: self, action: #selector(onEditNicknameButtonTapped))
        self.imgEditNickname.isUserInteractionEnabled = post.creator.userId == UserInfo.sharedInstance.userData.userId
        self.imgEditNickname.isHidden = post.creator.userId != UserInfo.sharedInstance.userData.userId
        self.imgEditNickname.addGestureRecognizer(editNicknameTapGesture)
        

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, hh:mm a"
        self.lblTime.text = dateFormatter.string(from: post.createdAt)
        self.btnDelete.isHidden = post.creator.userId != UserInfo.sharedInstance.userData.userId
        
        if post.image != nil && !post.image!.isEmpty
        {
            self.imgPost.sd_setImage(with: URL(string: post.image!))
            let bannerTapGesture = UITapGestureRecognizer(target: self, action: #selector(onBannerTapped))
            self.imgPost.isUserInteractionEnabled = true
            self.imgPost.addGestureRecognizer(bannerTapGesture)
        }
        else
        {
            self.imgPost.image = nil
        }
//        self.lblTitle.text = post.title
        tvDescription.attributedText = post.description?.interpretAsHTML(font: "Avenir Book", size: 17.0)
        tvDescription.delegate = self
        self.updatReaction()
        self.lblComment.text = "\(post.comments.count)"
        self.updatReaction()
        
        let likeTapGesture = UITapGestureRecognizer(target: self, action: #selector(onLikeButtonTapped))
        self.imgLike.isUserInteractionEnabled = true
        self.imgLike.addGestureRecognizer(likeTapGesture)
        
        let dislikeTapGesture = UITapGestureRecognizer(target: self, action: #selector(onDislikeButtonTapped))
        self.imgDislike.isUserInteractionEnabled = true
        self.imgDislike.addGestureRecognizer(dislikeTapGesture)
        
        self.tblCommentsHeightConstraint?.constant = CGFloat.greatestFiniteMagnitude
        self.tblComments.reloadData()
        self.tblComments.layoutIfNeeded()
        self.tblCommentsHeightConstraint?.constant = self.tblComments.contentSize.height
        
        self.fullscreenImageView = MediaZoom(with: imgPost, animationTime: 0.5, useBlur: true)
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
        NotificationCenter.default.post(name: Notification.Name(USER_NOTIFICATION_POST_UPDATED), object: nil)
    }
    
    private func react(_ isLike: Bool) {
        let params: [String: Any] = [
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
    
    private func editPost(_ nickname: String) {
        let params: [String : Any] = [
            "image": self.post.image ?? "",
            "title": self.post.title ?? "",
            "nickname": nickname,
            "content": self.post.description!
        ]
        self.showLoadingProgress(view: self.view)
        ApiManager.sharedInstance.editPost(self.post.id, params: params) {
            post, errorMsg in
            self.dismissLoadingProgress(view: self.view)
            
            if let post = post {
                self.post.nickname = post.nickname
                self.lblUsername.text = post.nickname
            } else {
                let errorMessage = errorMsg ?? "Something went wrong, try again later"
                self.showSimpleAlert(title: "", message: errorMessage, complete: nil)
            }
        }
    }
    
    @objc func onBannerTapped() {
        self.view.addSubview(self.fullscreenImageView)
        self.fullscreenImageView.show()
    }
    
    @objc func onEditNicknameButtonTapped() {
        let alert = UIAlertController(title: "Edit Nickname", message: "Please enter new nickname", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = self.post.nickname
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Change", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields?[0]
            if let newNickname = textField?.text, Validator.isValidUsername(newNickname) {
                self.editPost(newNickname)
            } else {
                self.showToast(message: "Invalid Username".localized())
            }
        }))

        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func onLikeButtonTapped() {
        self.react(true)
    }
    
    @objc func onDislikeButtonTapped() {
        self.react(false)
    }
    
    @IBAction func onAddCommentTapped(_ sender: Any) {
        if let comment = self.tfAddComment.text {
            showLoadingProgress(view: self.view)
            let params: [String : Any] = [
                "post_id": post.id!,
                "text": comment
                ]
            ApiManager.sharedInstance.addComment(0, params: params){
                comment, error in
                // Hide the loading progress
                self.dismissLoadingProgress(view: self.view)
                
                if let comment = comment {
                    comment.user = UserInfo.sharedInstance.userData
                    self.post.comments.append(comment)
                    self.lblComment.text = "\(self.post.comments.count)"
                    self.tfAddComment.text = nil
                    
                    self.tblCommentsHeightConstraint?.constant = CGFloat.greatestFiniteMagnitude
                    self.tblComments.reloadData()
                    self.tblComments.layoutIfNeeded()
                    self.tblCommentsHeightConstraint?.constant = self.tblComments.contentSize.height
                }
            }
        }
    }
    
    @IBAction func onDeleteButtonTapped(_ sender: Any) {
        let alertController = UIAlertController(
            title: "Delete Post",
            message: "Are you sure to delete this post?",
            preferredStyle: .alert
        )
        let cancel = UIAlertAction(title: "No", style: .cancel, handler: nil)
        let delete = UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.showLoadingProgress(view: self.view)
            ApiManager.sharedInstance.deletePost(self.post.id){
                success, error in
                // Hide the loading progress
                self.dismissLoadingProgress(view: self.view)
                
                if success {
                    let userInfo: [String: Post] = ["post": self.post]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_NOTIFICATION_POST_DELETED), object: nil, userInfo: userInfo)
                    self.navigationController?.popViewController(animated: true)
                }
                else {
                    self.showSimpleAlert(title: "Error", message: "There was a problem, please try again later.", complete: nil)
                }
            }
        })
        alertController.addAction(cancel)
        alertController.addAction(delete)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}

extension PostDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.post.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postcomment_viewcell", for: indexPath) as! PostCommentViewCell
        cell.setData(post.comments[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

extension PostDetailVC: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        textView.selectedRange = NSMakeRange(0, 0)
    }
}
