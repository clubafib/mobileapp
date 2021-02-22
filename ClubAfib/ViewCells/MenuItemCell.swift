//
//  MenuItemCell.swift
//  BZZHUB
//
//  Created by Rener on 7/22/20.
//  Copyright © 2020 ExtremeMobile. All rights reserved.
//

import UIKit

class MenuItemCell: UITableViewCell {

    @IBOutlet weak var vwMenu: UIView!
    @IBOutlet weak var vwLine: UIView!
    @IBOutlet weak var imgMenuIcon: UIImageView!
    @IBOutlet weak var lblMenuTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setMenuItem(_ data:MenuItem)
    {
        if data.isDividerLine
        {
            vwMenu.isHidden = true
            vwLine.isHidden = false
        }
        else
        {
            vwMenu.isHidden = false
            vwLine.isHidden = true
            
            imgMenuIcon.image = UIImage(named: data.menuIcon)
            lblMenuTitle.text = data.menuTitle
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
