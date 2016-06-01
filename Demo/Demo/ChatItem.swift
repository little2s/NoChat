//
//  ChatItem.swift
//  Demo
//
//  Created by little2s on 16/5/10.
//  Copyright © 2016年 little2s. All rights reserved.
//

import Foundation
import NoChat

class ChatItem: ChatItemProtocol {
    static let itemType: ChatItemType = "ChatItem"
    
    let uid: String
    let content: String
    var type: String {
        return ChatItem.itemType
    }
    
    init(uid: String, content: String) {
        self.uid = uid
        self.content = content
    }
    
}