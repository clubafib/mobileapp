//
//  LinkSentVC.swift
//  Authentication
//
//  Created by Rener on 7/20/20.
//  Copyright © 2020 ExtremeMobile. All rights reserved.
//

import UIKit

protocol LinkSentVCDelegate: AnyObject {
    func didContinue(sender: LinkSentVC)
}

class LinkSentVC: BasePopViewController {

    weak var delegate: LinkSentVCDelegate?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hintLabel: UILabel!
    
    @IBOutlet weak var continueButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setlocalizable()
    }
    
    func setlocalizable(){
        titleLabel.text = "Email Link Sent".localized()
        hintLabel.text = "Email Hint".localized()
        continueButton.setTitle("Continue".localized(), for: .normal)
    }
    
    @IBAction func onContinuePressed(_ sender: Any) {
        hideShadow()
        dismiss(animated: true) {
            self.delegate?.didContinue(sender: self)
        }
    }
}
