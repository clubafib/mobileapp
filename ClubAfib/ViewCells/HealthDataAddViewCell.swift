//
//  HealthDataAddViewCell.swift
//  ClubAfib
//
//  Created by Rener on 8/6/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit

class HealthDataAddViewCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblValue: UILabel!
    @IBOutlet weak var tfValue: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
