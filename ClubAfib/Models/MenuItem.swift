//
//  MenuItem.swift
//  Models
//
//  Created by Rener on 7/20/20.
//  Copyright © 2020 ExtremeMobile. All rights reserved.
//

import Foundation

class MenuItem: NSObject
{
    var menuIcon:String!
    var menuTitle:String!
    var isDividerLine:Bool!
    var type:MenuType!
    
    override init()
    {
        menuIcon = ""
        menuTitle = ""
        isDividerLine = false
    }
}
