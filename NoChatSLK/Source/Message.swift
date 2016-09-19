//
//  Message.swift
//  NoChat
//
//  Created by little2s on 16/3/16.
//  Copyright © 2016年 Ninty. All rights reserved.
//

import Foundation

public enum MessageType: String {
    case Text = "Text"
}

open class Message: NSObject, MessageProtocol {
    open var msgId: String
    open var msgType: String
    open var senderId: String
    open var isIncoming: Bool
    open var date: Date
    open dynamic var deliveryStatus: MessageDeliveryStatus
    open var attachments: [MessageAttachmentProtocol]
    open var content: String
    
    public init(
        msgId: String,
        msgType: String,
        senderId: String,
        isIncoming: Bool,
        date: Date,
        deliveryStatus: MessageDeliveryStatus,
        attachments: [MessageAttachmentProtocol] = [],
        content: String
        )
    {
        self.msgId = msgId
        self.msgType = msgType
        self.senderId = senderId
        self.isIncoming = isIncoming
        self.date = date
        self.deliveryStatus = deliveryStatus
        self.attachments = attachments
        self.content = content
        
        super.init()
    }
}

