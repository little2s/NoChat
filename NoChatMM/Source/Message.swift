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
    case Image = "Image"
}

public class Message: NSObject, MessageProtocol {
    public var msgId: String
    public var msgType: String
    public var senderId: String
    public var isIncoming: Bool
    public var date: NSDate
    public dynamic var deliveryStatus: MessageDeliveryStatus
    public var attachments: [MessageAttachmentProtocol]
    public var content: String
    
    public init(
        msgId: String,
        msgType: String,
        senderId: String,
        isIncoming: Bool,
        date: NSDate,
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

