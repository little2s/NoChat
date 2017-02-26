//
//  MMBaseMessageCellLayout.swift
//  NoChat-Swift-Example
//
//  Copyright (c) 2016-present, little2s.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import NoChat

class MMBaseMessageCellLayout: NSObject, NOCChatItemCellLayout {
    
    var reuseIdentifier: String = "MMBaseMessageCell"
    var chatItem: NOCChatItem
    var width: CGFloat
    var height: CGFloat = 0
    
    var message: Message {
        return chatItem as! Message
    }
    var isOutgoing: Bool {
        return message.isOutgoing
    }
    
    let bubbleViewMargin = UIEdgeInsets(top: 8, left: 52, bottom: 8, right: 52)
    var bubbleViewFrame = CGRect.zero
    let avatarSize = CGFloat(40)
    var avatarImageViewFrame = CGRect.zero
    var avatarImage: UIImage?
    
    required init(chatItem: NOCChatItem, cellWidth width: CGFloat) {
        self.chatItem = chatItem
        self.width = width
        super.init()
        self.avatarImage = self.isOutgoing ? Style.outgoingAvatarImage : Style.incomingAvatarImage
    }
    
    func calculate() {
        avatarImageViewFrame = isOutgoing ? CGRect(x: width - 8 - avatarSize, y: 11, width: avatarSize, height: avatarSize) : CGRect(x: 8, y: 11, width: avatarSize, height: avatarSize)
    }
    
    struct Style {
        static let outgoingAvatarImage = UIImage(named: "MMAvatarOutgoing")!
        static let incomingAvatarImage = UIImage(named: "MMAvatarIncoming")!
    }
    
}
