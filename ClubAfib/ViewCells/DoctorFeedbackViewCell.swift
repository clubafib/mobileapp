//
//  DoctorFeedbackViewCell.swift
//  ClubAfib
//
//  Created by Rener on 8/14/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit
import Cosmos

class DoctorFeedbackViewCell: UITableViewCell {

    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var cvRanting: CosmosView!
    @IBOutlet weak var lblContent: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setData(_ feedback: Feedback)
    {
        if let photoURL = feedback.patient.photo {
            imgAvatar.sd_setImage(with: URL(string: photoURL))
        }
        else
        {
            imgAvatar.image = UIImage(named: "default_avatar")
        }
        lblName.text = feedback.patient.username
        lblTime.text = feedback.create_date?.timeAgoDisplay()
        cvRanting.rating = feedback.rating
        lblContent.text = feedback.detail
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
