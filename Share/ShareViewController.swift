//
//  ShareViewController.swift
//  Share
//
//  Created by Rener on 9/3/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices
import MBProgressHUD

//@objc(ShareExtensionViewController)
class ShareViewController: UIViewController {
    
    let KEY_REFRESH_TOKEN               = "refresh_token"
    let KEY_USERNAME                    = "username"
    
    @IBOutlet weak var btnPost: UIButton!
    @IBOutlet weak var attachImageView: UIImageView!
    @IBOutlet weak var tfNickname: UITextField!
    @IBOutlet weak var tvDescription: UITextView!
    
    var imageURL: URL?
    var readyToPost = false
    
    // refresh token is long time live
    var token: String{
        get{
            guard let refresh_token = UserDefaults(suiteName: "group.com.mr.clubafib.share")!.string(forKey: KEY_REFRESH_TOKEN) else { return "" }
            return refresh_token
        }
    }
    var username: String{
        get{
            guard let username = UserDefaults(suiteName: "group.com.mr.clubafib.share")!.string(forKey: KEY_USERNAME) else { return "" }
            return username
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tfNickname.placeholder = "Nickname"
        self.tfNickname.text = username
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.handleSharedFile()
    }
    
    private func handleSharedFile() {
        // extracting the path to the URL that is being shared
        let attachments = (self.extensionContext?.inputItems.first as? NSExtensionItem)?.attachments ?? []
        
        let contentTypeURL = kUTTypeURL as String
        let contentTypeText = kUTTypeText as String
        let contentTypeImage = kUTTypeImage as String
        
        var text = "", url = ""

        let group = DispatchGroup()
        for attachment in attachments {
            if attachment.hasItemConformingToTypeIdentifier(contentTypeText) {
                group.enter()
                attachment.loadItem(forTypeIdentifier: contentTypeText, options: nil, completionHandler: { (results, error) in
                    text = results as! String
                    group.leave()
                })
            }
            if attachment.hasItemConformingToTypeIdentifier(contentTypeURL) {
                group.enter()
                attachment.loadItem(forTypeIdentifier: contentTypeURL, options: nil, completionHandler: { (results, error) in
                    if let resultUrl = results as? URL {
                        // check if image url
                        if let imageData = try? Data(contentsOf: resultUrl), let image = UIImage(data: imageData) {
                            self.save(imageData, key: "imageData", value: imageData)
                            DispatchQueue.main.async {
                                self.attachImageView.image = image
                            }
                        }
                        else {
                            url = resultUrl.absoluteString
                        }
                    }
                    group.leave()
                })
            }
            if attachment.hasItemConformingToTypeIdentifier(contentTypeImage) {
                group.enter()
                attachment.loadItem(forTypeIdentifier: contentTypeImage, options: nil) { [unowned self] (data, error) in
                    // Handle the error here if you want
                    guard error == nil else { return }

                    if let url = data as? URL, let imageData = try? Data(contentsOf: url) {
                        self.save(imageData, key: "imageData", value: imageData)
                        DispatchQueue.main.async {
                            self.attachImageView.image = UIImage(data: imageData)
                        }
                    }
                    else if let image = data as? UIImage {
                        self.save(image.jpegData(compressionQuality: 0.5)!, key: "imageData", value: image)
                        DispatchQueue.main.async {
                            self.attachImageView.image = image
                        }
                    }
                    group.leave()
                }
            }
        }
        group.notify(queue: .main) {
            self.tvDescription.text = (url.isEmpty ? "" : url + "\n") + text
            self.tvDescription.becomeFirstResponder()
        }
    }
    
    func showLoadingProgress(view: UIView!, label: String = "Wait a moment") -> Void {
        let loadingHud = MBProgressHUD.showAdded(to: view, animated: true)
        loadingHud.bezelView.backgroundColor = UIColor.black
        loadingHud.contentColor = UIColor.white
        loadingHud.label.text = NSLocalizedString(label, comment: "")
    }
    
    func dismissLoadingProgress(view : UIView!) -> Void {
        MBProgressHUD.hide(for: view, animated: true)
    }
    
    // get event directory
    func getDirectory (_ dirName : String) -> URL{
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dirUrl = documentsDirectory.appendingPathComponent(dirName)
        if !FileManager.default.fileExists(atPath: dirUrl.path) {
            do{
                try FileManager.default.createDirectory(at: dirUrl, withIntermediateDirectories: true, attributes: nil)
                return dirUrl
            }catch {
                NSLog("Couldn't create directory")
            }
        }
        
        NSLog("Created directory path  = \(dirUrl.path)")
        return dirUrl
    }

    private func save(_ imageData: Data, key: String, value: Any) {
        imageURL = getDirectory("clubafib_media").appendingPathComponent(UUID().uuidString)
        
        if imageURL != nil {
            if FileManager.default.fileExists(atPath: imageURL!.path) {
                do{
                    // delete the existing image
                    try FileManager.default.removeItem(atPath: imageURL!.path)
                }
                catch {
                    print("Failed to delete existing image : \(error.localizedDescription)")
                }
            }
            
            do{
                // Write the image data into local
                try imageData.write(to: imageURL!)
                print("Image saved successfully, path = \(imageURL!.path)")
                self.readyToPost = true
            } catch {
                print("Error saving image : \(error.localizedDescription)")
            }
        }
    }
    
    private func post(_ params: [String: Any]) {
        ApiManager.sharedInstance.addPost(0, params: params, token: self.token){
            success, error in
            self.dismissLoadingProgress(view: self.view)

            DispatchQueue.main.async {
                if success {
                    self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                }
                else {
                    print("Error on share: \(error ?? "")")
                    self.extensionContext?.cancelRequest(withError: NSError(domain: Bundle.main.bundleIdentifier!, code: 0, userInfo: nil))
                }
            }
        }
    }

    @IBAction func onCloseButtonTapped(_ sender: Any) {
        self.extensionContext?.cancelRequest(withError: NSError(domain: Bundle.main.bundleIdentifier!, code: 0, userInfo: nil))
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
            if let imageURL = imageURL {
                ApiManager.sharedInstance.uploadImage(urls: [URL(string: imageURL.absoluteString)!], name: "file", token: token) { (url, errorMsg) in
                    DispatchQueue.main.async {
                        if let url = url {
                            params["image"] = url
                            self.post(params)
                        }
                        else{
                            self.dismissLoadingProgress(view: self.view)
                            // Show the error message
                            print("\(errorMsg ?? "")")
                            self.extensionContext!.cancelRequest(withError: NSError())
                        }
                    }
                }
            }
            else {
                self.post(params)
            }
        }
    }

}
