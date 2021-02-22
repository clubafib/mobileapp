//
//  HealthCategoryViewCell.swift
//  ClubAfib
//
//  Created by Rener on 7/29/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit

class HealthCategory: NSObject
{
    var icon: String!
    var title: String!
    var type: HealthCategoryType!
    
    override init()
    {
        icon = ""
        title = ""
        type = .Activity
    }
}


class HealthCategoryViewCell: UITableViewCell {

    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setData(_ data:HealthCategory)
    {
        imgIcon.image = UIImage(named: data.icon)
        lblTitle.text = data.title
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
