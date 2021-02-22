//
//  ChatHistoryCell.swift
//  ClubAfib
//
//  Created by Fresh on 8/13/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit

class ChatHistoryCell: UITableViewCell {

    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblSubject: UILabel!
    @IBOutlet weak var btnChat: UIButton!
    
    func setData(_ roomInfo: ChatRoom) {
        if roomInfo.doctorImageURL != nil && !roomInfo.doctorImageURL!.isEmpty
        {
            imgAvatar.sd_setImage(with: URL(string: roomInfo.doctorImageURL!))
        }
        else
        {
            imgAvatar.image = UIImage(named: "default_avatar")
        }
        lblName.text = "Dr. \(roomInfo.doctorFirstName ?? "") \(roomInfo.doctorLastName ?? "")"
        lblSubject.text = roomInfo.lastMessage
    }

}
