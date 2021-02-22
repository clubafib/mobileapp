//
//  PostVC.swift
//  ClubAfib
//
//  Created by Rener on 8/19/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit

class PostVC: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var imgMenu: UIImageView!
    @IBOutlet weak var tblPosts: UITableView!
    @IBOutlet weak var btnAddPost: UIView!
    
    @IBOutlet weak var composerPopup: UIView!
    @IBOutlet weak var btnPost: UIButton!
    @IBOutlet weak var attachImageView: UIImageView!
    @IBOutlet weak var tfNickname: UITextField!
    @IBOutlet weak var tvDescription: UITextView!
    @IBOutlet weak var btnAttach: UIImageView!
    
    var refreshControl = UIRefreshControl()
    
    var posts = [Post]()
    
    var image : UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initTopbar()
        self.tblPosts.register(UINib(nibName: "PostViewCell", bundle: nil), forCellReuseIdentifier: "post_viewcell")
        
        let postTapGesture = UITapGestureRecognizer(target: self, action: #selector(openComposer))
        btnAddPost.addGestureRecognizer(postTapGesture)
        
        let attachTapGesture = UITapGestureRecognizer(target: self, action: #selector(openAttach))
        btnAttach.addGestureRecognizer(attachTapGesture)
        
        let cancelAttachTapGesture = UITapGestureRecognizer(target: self, action: #selector(cancelAttachment))
        attachImageView.addGestureRecognizer(cancelAttachTapGesture)
        
        self.composerPopup.isHidden = true
        self.tfNickname.placeholder = "Nickname"
        
        self.refreshControl.addTarget(self, action: #selector(self.gePosts), for: .valueChanged)
        self.tblPosts.addSubview(refreshControl)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onPostDeleted(_:)), name: NSNotification.Name(USER_NOTIFICATION_POST_DELETED), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.gePosts()
        ApiManager.sharedInstance.getLogo { (url) in
            if let url = url {
                self.imgLogo.sd_setImage(with: URL(string: url)!, completed: nil)
            }
        }
        super.viewWillAppear(animated)
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
    
    @objc func onPostDeleted(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            if let post = dict["post"] as? Post{
                self.posts = self.posts.filter {$0.id != post.id}
                self.tblPosts.reloadData()
            }
        }
    }
    
    @objc func gePosts(){
        if self.posts.count == 0 {
            showLoadingProgress(view: self.view)
        }
        
        ApiManager.sharedInstance.getPosts(params: nil){
            posts, errorMsg in
            self.dismissLoadingProgress(view: self.view)
            self.refreshControl.endRefreshing()
            
            if posts != nil {
                self.posts.removeAll()
                self.posts.append(contentsOf: posts!.sorted(by: { $0.createdAt.compare($1.createdAt) == .orderedDescending }))
                self.tblPosts.reloadData()
            }
            else{
                // Show the error message
                let errorMessage = errorMsg ?? "Something went wrong, try again later"
                self.showToast(message: errorMessage)
            }
        }
    }
    
    @objc func openComposer() {
        self.tfNickname.text = UserInfo.sharedInstance.userData.username
        self.tvDescription.text = nil
        self.composerPopup.isHidden = false
    }
    
    @objc func openAttach() {
        let optionMenu = UIAlertController(title: "Take Photo", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        let cameraAction = UIAlertAction(title: "Take a picture", style: .default, handler:{ (UIAlertAction)in
            self.openCamera(self)
        })
        
        let galleryAction = UIAlertAction(title: "Select photo from library", style: .default, handler:{ (UIAlertAction)in
            self.openPhotoLibrary(self)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler:{ (UIAlertAction)in
            // dismiss
        })
        
        optionMenu.addAction(cameraAction)
        optionMenu.addAction(galleryAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    @objc func cancelAttachment() {
        if self.image != nil {
            let alert = UIAlertController(title: "Attachment", message: "Choose action.", preferredStyle: UIAlertController.Style.actionSheet)
            
            let libButton = UIAlertAction(title: "Remove Attachment", style: UIAlertAction.Style.destructive) { (alert) -> Void in
                self.image = nil;
                self.attachImageView?.image = nil;
                self.view.layoutIfNeeded()
            }
            alert.addAction(libButton)
            
            let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { (alert) -> Void in}
            
            alert.addAction(cancelButton)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func gotoPostDetail(_ post: Post) {
        let postDetailVC = HOME_STORYBOARD.instantiateViewController(withIdentifier: "PostDetailVC") as! PostDetailVC
        postDetailVC.post = post
        self.navigationController?.pushViewController(postDetailVC, animated: true)
    }
    
    private func addPost(_ params: [String: Any]) {
        ApiManager.sharedInstance.addPost(0, params: params){
            post, error in
            self.dismissLoadingProgress(view: self.view)
            // Hide the loading progress
            self.dismissLoadingProgress(view: self.navigationController?.view)
            
            if let post = post {
                post.creator = UserInfo.sharedInstance.userData
                self.posts.append(post)
                self.posts = self.posts.sorted(by: { $0.createdAt.compare($1.createdAt) == .orderedDescending })
                self.tvDescription.text = nil
                self.tblPosts.reloadData()
            }
            
            self.clearComposer()
        }
    }
    
    private func clearComposer() {
        self.image = nil
        self.attachImageView.image = nil
        self.composerPopup.isHidden = true
        self.view.endEditing(true)
    }

    @IBAction func onPostButtonTapped(_ sender: Any) {
        if let description = self.tvDescription.text, !description.isEmpty,
            let nickname = self.tfNickname.text, !nickname.isEmpty {
            showLoadingProgress(view: self.view)
            var params: [String : Any] = [
                "title": "",
                "nickname": nickname,
                "content": description
                ]
            if self.image != nil {
                self.saveImageToDirectory(image!, filename: UUID().uuidString, directoryName: "clubafib_media", complete: { (success, filepath, error) in
                    if success {
                        ApiManager.sharedInstance.uploadImage(urls: [URL(string: filepath!)!], name: "file") { (url, errorMsg) in
                            DispatchQueue.main.async {
                                if let url = url {
                                    params["image"] = url
                                    self.addPost(params)
                                }
                                else{
                                    self.dismissLoadingProgress(view: self.view)
                                    // Show the error message
                                    let errorMessage = errorMsg ?? "Something went wrong, try again later"
                                    self.showToast(message: errorMessage)
                                }
                            }
                        }
                    }
                    else {
                        self.dismissLoadingProgress(view: self.view)
                    }
                })
            }
            else {
                self.addPost(params)
            }
        }
    }
    
    @IBAction func onCloseButtonTapped(_ sender: Any) {
        self.clearComposer()
    }

    @IBAction func onShareButtonPressed(_ sender: Any) {
        shareScreenshot()
    }
    
}

extension PostVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "post_viewcell", for: indexPath) as! PostViewCell
        cell.setData(posts[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let post = posts[indexPath.row]
        gotoPostDetail(post)
    }

}

extension PostVC : UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            return dismiss(animated: true, completion: nil)
        }
        
        // compress original image
        let QUALITY : CGFloat = 0.5
        let compressedData = image.jpegData(compressionQuality: QUALITY)
        
        guard let compressedImage = UIImage(data: compressedData!) else {
            return
        }
        
        self.image = compressedImage;
        attachImageView?.image = image;
        self.view.layoutIfNeeded()
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}
