//
//  ChatItemFactory.swift
//  Demo
//
//  Created by little2s on 16/5/10.
//  Copyright © 2016年 little2s. All rights reserved.
//

import Foundation
import NoChat
import NoChatTG
import NoChatMM
import NoChatSLK

// MARK: Telegram

typealias TGMessage = NoChatTG.Message
typealias TGMessageType = NoChatTG.MessageType

struct TGMessageFactory {
    static func createMessage(senderId: String, isIncoming: Bool, msgType: String) -> TGMessage {
        let message = TGMessage(
            msgId: NSUUID().UUIDString,
            msgType: msgType,
            senderId: senderId,
            isIncoming: isIncoming,
            date: NSDate(),
            deliveryStatus: .Delivering,
            attachments: [],
            content: ""
        )
        
        return message
    }
    
    static func createTextMessage(text text: String, senderId: String, isIncoming: Bool) -> TGMessage {
        let message = createMessage(senderId, isIncoming: isIncoming, msgType: TGMessageType.Text.rawValue)
        message.content = text
        return message
    }
}

// MARK: WeChat

typealias MMMessage = NoChatMM.Message
typealias MMMessageType = NoChatMM.MessageType

struct MMMessageFactory {
    static func createMessage(senderId: String, isIncoming: Bool, msgType: String) -> MMMessage {
        let message = MMMessage(
            msgId: NSUUID().UUIDString,
            msgType: msgType,
            senderId: senderId,
            isIncoming: isIncoming,
            date: NSDate(),
            deliveryStatus: .Delivering,
            attachments: [],
            content: ""
        )
        
        return message
    }
    
    static func createTextMessage(text text: String, senderId: String, isIncoming: Bool) -> MMMessage {
        let message = createMessage(senderId, isIncoming: isIncoming, msgType: MMMessageType.Text.rawValue)
        message.content = text
        return message
    }
}

// MARK: Slack

typealias SLKMessage = NoChatSLK.Message
typealias SLKMessageType = NoChatSLK.MessageType

struct SLKMessageFactory {
    static func createMessage(senderId: String, isIncoming: Bool, msgType: String) -> SLKMessage {
        let message = SLKMessage(
            msgId: NSUUID().UUIDString,
            msgType: msgType,
            senderId: senderId,
            isIncoming: isIncoming,
            date: NSDate(),
            deliveryStatus: .Delivering,
            attachments: [],
            content: ""
        )
        
        return message
    }
    
    static func createTextMessage(text text: String, senderId: String, isIncoming: Bool) -> SLKMessage {
        let message = createMessage(senderId, isIncoming: isIncoming, msgType: SLKMessageType.Text.rawValue)
        message.content = text
        return message
    }
}

// MARK: Demo Factory

class DemoChatItemFactory {
    private static let items = [
        ("text", "NoChat is a lightweight framework base on Chatto https://github.com/little2s/NoChat"),
        ("text", "Supports custom message bubble and toolbar"),
        ("text", "Invert mode is inside"),
    ]
    
    static func createChatItemsTG() -> [ChatItemProtocol] {
        var result = [ChatItemProtocol]()
        
        for _ in 0..<1 {
        
            for (index, item) in items.enumerate() {
                if item.0 == "text" {
                    let senderId = (index % 2 == 0) ? "incoming" : "outgoing"
                    let isIncomming = (senderId == "incoming")
                    
                    let chatItem = TGMessageFactory.createTextMessage(text: item.1, senderId: senderId, isIncoming: isIncomming)
                    result.insert(chatItem, atIndex: 0)
                }
            }
            
        }
        
        return result
    }
    
    static func createChatItemsMM() -> [ChatItemProtocol] {
        var result = [ChatItemProtocol]()
        
        for _ in 0..<1 {
            
            for (index, item) in items.enumerate() {
                if item.0 == "text" {
                    let senderId = (index % 2 == 0) ? "incoming" : "outgoing"
                    let isIncomming = (senderId == "incoming")
                    
                    let chatItem = MMMessageFactory.createTextMessage(text: item.1, senderId: senderId, isIncoming: isIncomming)
                    result.append(chatItem)
                }
            }
            
        }
        
        return result
    }
    
    static func createChatItemsSLK() -> [ChatItemProtocol] {
        var result = [ChatItemProtocol]()
        
        for _ in 0..<1 {
            
            for (index, item) in items.enumerate() {
                if item.0 == "text" {
                    let senderId = (index % 2 == 0) ? "incoming" : "outgoing"
                    let isIncomming = (senderId == "incoming")
                    
                    let chatItem = SLKMessageFactory.createTextMessage(text: item.1, senderId: senderId, isIncoming: isIncomming)
                    result.append(chatItem)
                }
            }
            
        }
        
        return result
    }
}