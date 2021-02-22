//
//  ContactVC.swift
//  ClubAfib
//
//  Created by Rener on 7/25/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit

class ContactViewCell: UITableViewCell {
    
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblSubject: UILabel!
    @IBOutlet weak var btnChat: UIButton!
    
    func setData(_ doctor: Doctor) {
        if doctor.imageUrl != nil && !doctor.imageUrl!.isEmpty
        {
            imgAvatar.sd_setImage(with: URL(string: doctor.imageUrl!))
        }
        else
        {
            imgAvatar.image = UIImage(named: "default_avatar")
        }
        lblName.text = "Dr. \(doctor.firstName!) \(doctor.lastName!)"
        lblSubject.text = doctor.subject
    }
    
}
