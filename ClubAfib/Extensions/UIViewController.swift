//
//  UIViewController.swift
//  Extentions
//
//  Created by Rener on 7/20/20.
//  Copyright © 2020 ExtremeMobile. All rights reserved.
//

import MBProgressHUD
import UIKit

extension UIViewController{

    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    /*!
     @brief It displays UIAlertController.
     @discussion This method displays UIAlertController with one button.
     @param title The title of AlertController
     @param message The content of AlertController
     @param closeButtonTitle The title of close button, default title is "Ok"
     @param complete The callback
     @return
     */
    func showSimpleAlert(title: String?, message: String?, closeButtonTitle: String = NSLocalizedString("ok", comment: ""), complete:(() -> Void)?) -> Void {
        let alertMessage = message != nil ? message! : "Something went wrong, please try again later"
        
        let alertController = UIAlertController(title: title, message: alertMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: closeButtonTitle, style: .cancel, handler: { action in
            if (complete != nil) { complete!() }
        })
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    /*!
     @brief It shows MBProgressHUD.
     @discussion It displays MBProgressHUD to the specific view.
     @param view The view to be displayed MBProgressHUD
     @return
     */
    func showLoadingProgress(view: UIView!, label: String = "Wait a moment") -> Void {
        let loadingHud = MBProgressHUD.showAdded(to: view, animated: true)
        loadingHud.bezelView.backgroundColor = UIColor.black
        loadingHud.contentColor = UIColor.white
        loadingHud.label.text = NSLocalizedString(label, comment: "")
    }
    
    /*!
     @brief It hiddens MBProgressHUD.
     @discussion It hiddens MBProgressHUD from the specific view.
     @param view The view the MBProgressHUD is dismissed
     @return
     */
    func dismissLoadingProgress(view : UIView!) -> Void {
        MBProgressHUD.hide(for: view, animated: true)
    }
    
    func showToast(message : String, isError : Bool = true, complete:(() -> Void)? = nil) {
        let screenWidth = Int(UIScreen.main.bounds.width)
        let screenHeight = Int(UIScreen.main.bounds.height)
        
        let toastHeight = 45
        var bottomSafeArea = 0
        
        if #available(iOS 11.0, *) {
            bottomSafeArea = Int(self.view.safeAreaInsets.bottom)
        } else {
            bottomSafeArea = Int(self.bottomLayoutGuide.length)
        }

        let toastLabel = UILabel(frame: CGRect(x: 0, y: (screenHeight - bottomSafeArea - toastHeight) , width: screenWidth, height: toastHeight))
        toastLabel.backgroundColor = isError ? "C44141".hexStringToUIColor() : "41A317".hexStringToUIColor()
        toastLabel.textColor = UIColor.white
        toastLabel.font = UIFont(name: "Avenir-Medium", size: 14)
        toastLabel.textAlignment = .center
        toastLabel.numberOfLines = 0
        toastLabel.text = message
        toastLabel.alpha = 1.0
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 1, delay: 2, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
            if complete != nil
            {
                complete!()
            }
        })
    }
    
    func showToast(message : String, delay:TimeInterval) {
        let screenWidth = Int(UIScreen.main.bounds.width)
        let screenHeight = Int(UIScreen.main.bounds.height)
        
        let toastHeight = 45
        var bottomSafeArea = 0
        
        if #available(iOS 11.0, *) {
            bottomSafeArea = Int(self.view.safeAreaInsets.bottom)
        } else {
            bottomSafeArea = Int(self.bottomLayoutGuide.length)
        }

        let toastLabel = UILabel(frame: CGRect(x: 0, y: (screenHeight - bottomSafeArea - toastHeight) , width: screenWidth, height: toastHeight))
        toastLabel.backgroundColor = "C44141".hexStringToUIColor()
        toastLabel.textColor = UIColor.white
        toastLabel.font = UIFont(name: "Avenir-Medium", size: 14)
        toastLabel.textAlignment = .center
        toastLabel.numberOfLines = 0
        toastLabel.text = message
        toastLabel.alpha = 1.0
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 1, delay: delay, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()            
        })
    }
    
    // Open the camera
    func openCamera(_ delegate : UIImagePickerControllerDelegate & UINavigationControllerDelegate){
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = delegate
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = false
            imagePicker.modalPresentationStyle = .overCurrentContext // to avoid dismiss problem
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    // Open PhotoLibrary
    func openPhotoLibrary(_ delegate : UIImagePickerControllerDelegate & UINavigationControllerDelegate){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = delegate
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = false
            imagePicker.modalPresentationStyle = .overCurrentContext // to avoid dismiss problem
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
       
    // get album dicrectory
    func getAlbumDirectory () -> URL{
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let albumUrl = documentsDirectory.appendingPathComponent("albums")
        if !FileManager.default.fileExists(atPath: albumUrl.path) {
            do{
                try FileManager.default.createDirectory(at: albumUrl, withIntermediateDirectories: true, attributes: nil)
                return albumUrl
            }catch {
                NSLog("Couldn't create album directory")
            }
        }
        
        NSLog("Album directory path  = \(albumUrl.path)")
        return albumUrl
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
    
    // Save image into local
    func saveImageToDirectory(_ image:UIImage, filename:String, directoryName:String, complete:@escaping(Bool, String?, String?)-> Void) {
        let imageURL = getDirectory(directoryName).appendingPathComponent(filename)
        
        if FileManager.default.fileExists(atPath: imageURL.path) {
            do{
                // delete the existing image
                try FileManager.default.removeItem(atPath: imageURL.path)
            }
            catch {
                print("Failed to delete existing image : \(error.localizedDescription)")
            }
        }
        
        // Write image
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            do{
                // Write the image data into local
                try imageData.write(to: imageURL)
                print("Image saved successfully, path = \(imageURL.path)")
                complete(true, imageURL.absoluteString, nil)
            } catch {
                print("Error saving image : \(error.localizedDescription)")
                complete(false, nil, error.localizedDescription)
            }
        }
        else{
            complete(false, nil, "Failed to save picture, please try again later.")
        }
    }
    
    func shareScreenshot() {
        let bounds = UIScreen.main.bounds
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0.0)
        self.view.drawHierarchy(in: bounds, afterScreenUpdates: false)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let activityViewController = UIActivityViewController(activityItems: [img!], applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }

}
