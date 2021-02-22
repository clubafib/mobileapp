//
//  ChatMessage.swift
//  ClubAfib
//
//  Created by Fresh on 8/11/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import Foundation
import CoreLocation
import MessageKit
import AVFoundation

struct ChatUser: SenderType, Equatable {
    var senderId: String
    var displayName: String
    var avatarImage: String?
}

internal struct ChatMessage: MessageType {

    var messageId: String
    var sender: SenderType {
        return user
    }
    var sentDate: Date
    var kind: MessageKind
    var user: ChatUser
    
    private init(kind: MessageKind, user: ChatUser, messageId: String, date: Date) {
        self.kind = kind
        self.user = user
        self.messageId = messageId
        self.sentDate = date
    }
    
    init(text: String, user: ChatUser, messageId: String, date: Date) {
        self.init(kind: .text(text), user: user, messageId: messageId, date: date)
    }
}
