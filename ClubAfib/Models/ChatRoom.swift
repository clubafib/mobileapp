//
//  ChatRoom.swift
//  ClubAfib
//
//  Created by Fresh on 8/13/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit
import SwiftyJSON

class ChatRoom: NSObject {
    
    var roomId: String!
    var userId: Int!
    var doctorId: Int!
    var doctorFirstName: String?
    var doctorLastName: String?
    var doctorSubject: String?
    var doctorImageURL: String?
    var roomStatus: Int! // 0: Open, 1: Close
    var lastMessage: String?
    var lastTime: String?
    
    override init() {
        
    }
}
