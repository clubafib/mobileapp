//
//  BasePopViewController.swift
//  ClubAfib
//
//  Created by Rener on 7/20/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit

class BasePopViewController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate, UITextViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closePopup))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        
        hideShadow()
    }
    
    @objc func closePopup() {
        hideShadow()
        dismiss(animated: true, completion: nil)
    }
    
    func hideShadow()
    {
        self.view.backgroundColor = UIColor.clear
    }
    
    func showShadow()
    {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if !(touch.view?.isKind(of: UITextField.self))! && !(touch.view?.isKind(of: UITextView.self))!
        {
            self.view.endEditing(true)
        }
        
        return touch.view == gestureRecognizer.view
    }
    
    // textfield delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            self.view.endEditing(true)
            return false
        }
        return true
    }
}


extension UIViewController{
    
    func presentPopController(vc: BasePopViewController) {
        vc.modalPresentationStyle = .overCurrentContext
        self.providesPresentationContextTransitionStyle = true
        self.definesPresentationContext = true
        
        present(vc, animated: true) {
            vc.showShadow()
        }
    }

}
