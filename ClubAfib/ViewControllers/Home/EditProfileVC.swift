//
//  EditProfileVC.swift
//  ClubAfib
//
//  Created by Rener on 8/25/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit

class EditProfileVC: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var tfFirstName: UITextField!
    @IBOutlet weak var tfLastName: UITextField!
    @IBOutlet weak var tfUsername: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfMobile: UITextField!
    @IBOutlet weak var tfAddress: UITextField!
    
    var user: User!
    var image : UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = UserInfo.sharedInstance.userData
        
        if user.photo != nil && !user.photo!.isEmpty
        {
            imgAvatar.sd_setImage(with: URL(string: user.photo!))
        }
        else
        {
            imgAvatar.image = UIImage(named: "default_avatar")
        }
        tfFirstName.text = user.firstName
        tfLastName.text = user.lastName
        tfUsername.text = user.username
        tfEmail.text = user.email
        tfAddress.text = user.address
        tfMobile.text = user.phonenumber
        tfAddress.text = user.address
    }
    
    private func updateProfile() {
        let firstName = tfFirstName.text!
        let lastName = tfLastName.text!
        let username = tfUsername.text!
        let email = tfEmail.text!
        let mobile = tfMobile.text!
        let address = tfAddress.text!
        
        if firstName.isEmpty
        {
            showToast(message: "Enter First Name".localized())
            return
        }
        
        if lastName.isEmpty
        {
            showToast(message: "Enter Last Name".localized())
            return
        }
        
        if username.isEmpty
        {
            showToast(message: "Enter Username".localized())
            return
        }
        else if !Validator.isValidUsername(username)
        {
            showToast(message: "Invalid Username".localized())
            return
        }
        
        if email.isEmpty
        {
            showToast(message: "Enter Email Address".localized())
            return
        }
        else if !Validator.isValidEmail(email)
        {
            showToast(message: "Invalid Email Address".localized())
            return
        }
        
        if mobile.isEmpty
        {
            showToast(message: "Enter Phone Number".localized())
            return
        }
        else if !Validator.isValidPhonenumber(mobile)
        {
            showToast(message: "Invalid Phone Number".localized())
            return
        }
        
        var params : [String : Any] = [
            "first_name" : firstName,
            "last_name" : lastName,
            "username" : username,
            "phonenumber" : mobile,
            "email" : email,
            "address" : address,
        ]
        
        showLoadingProgress(view: self.view)
        
        if let image = self.image {
            self.saveImageToDirectory(image, filename: UUID().uuidString, directoryName: "clubafib_media", complete: { (success, filepath, error) in
                if success {
                    ApiManager.sharedInstance.uploadImage(urls: [URL(string: filepath!)!], name: "file") { (url, errorMsg) in
                        if let url = url {
                            params["photo"] = url
                            self.updateProfile(params)
                        }
                        else{
                            DispatchQueue.main.async {
                                self.dismissLoadingProgress(view: self.view)
                                // Show the error message
                                let errorMessage = errorMsg ?? "Something went wrong, try again later"
                                self.showSimpleAlert(title: "", message: errorMessage, complete: nil)
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
            params["photo"] = self.user.photo
            self.updateProfile(params)
        }
    }
    
    private func updateProfile(_ params: [String: Any]) {
        ApiManager.sharedInstance.updateProfile(params: params) { (success, errorMsg) in
            DispatchQueue.main.async {
                // Hide the loading progress
                self.dismissLoadingProgress(view: self.view)
                
                if success {
                    // save user auth info for facial login
                    UserInfo.sharedInstance.userData.photo = params["photo"] as? String
                    UserInfo.sharedInstance.userData.firstName = params["first_name"] as? String
                    UserInfo.sharedInstance.userData.lastName = params["last_name"] as? String
                    UserInfo.sharedInstance.userData.username = params["username"] as? String
                    UserInfo.sharedInstance.userData.phonenumber = params["phonenumber"] as? String
                    UserInfo.sharedInstance.userData.email = params["email"] as? String
                    UserInfo.sharedInstance.userData.address = params["address"] as? String

                    UserInfo.sharedInstance.saveUserDataToLocal()
                    NotificationCenter.default.post(name: Notification.Name(USER_NOTIFICATION_PROFILE_CHANGED), object: nil)
                    self.showSimpleAlert(title: "Success", message: "Your profile saved successfully", complete: nil)
                }
                else{
                    // Show the error message
                    let errorMessage = errorMsg ?? "Something went wrong, try again later"
                    self.showSimpleAlert(title: "", message: errorMessage, complete: nil)
                }
            }
        }
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onEditPhotoButtonTapped(_ sender: Any) {
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
    
    @IBAction func onSaveButtonTapped(_ sender: Any) {
        self.view.endEditing(true)
        self.updateProfile()
    }
    
}

extension EditProfileVC : UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            return dismiss(animated: true, completion: nil)
        }
        self.image = image;
        self.imgAvatar?.image = image;
        self.view.layoutIfNeeded()
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}
