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

import LoremIpsum

// MARK: Telegram

typealias TGMessage = NoChatTG.Message
typealias TGMessageType = NoChatTG.MessageType

struct TGMessageFactory {
    static func createMessage(senderId: String, isIncoming: Bool, msgType: String, showAvatar: Bool) -> TGMessage {
        let message = TGMessage(
            msgId: NSUUID().uuidString,
            msgType: msgType,
            senderId: senderId,
            isIncoming: isIncoming,
            date: Date(),
            deliveryStatus: .delivering,
            attachments: [],
            content: "",
            showAvatar: showAvatar
        )
        return message
    }

    static func createTextMessage(text: String, senderId: String, isIncoming: Bool, showAvatar: Bool) -> TGMessage {
        let message = createMessage(senderId: senderId, isIncoming: isIncoming, msgType: TGMessageType.Text.rawValue, showAvatar: showAvatar)
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
            msgId: NSUUID().uuidString,
            msgType: msgType,
            senderId: senderId,
            isIncoming: isIncoming,
            date: NSDate() as Date,
            deliveryStatus: .delivering,
            attachments: [],
            content: ""
        )

        return message
    }

    static func createTextMessage(text: String, senderId: String, isIncoming: Bool) -> MMMessage {
        let message = createMessage(senderId: senderId, isIncoming: isIncoming, msgType: MMMessageType.Text.rawValue)
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
            msgId: NSUUID().uuidString,
            msgType: msgType,
            senderId: senderId,
            isIncoming: isIncoming,
            date: Date(),
            deliveryStatus: .delivering,
            attachments: [],
            content: ""
        )

        return message
    }

    static func createTextMessage(text: String, senderId: String, isIncoming: Bool) -> SLKMessage {
        let message = createMessage(senderId: senderId, isIncoming: isIncoming, msgType: SLKMessageType.Text.rawValue)
        message.content = text
        return message
    }
}

// MARK: Demo Factory

extension Bool {
    static func random() -> Bool {
        return arc4random_uniform(2) == 0
    }
}

extension Int {
    static func random(lower: Int, upper:Int ) -> Int {
        let difference = upper - lower
        return Int(Float(arc4random())/Float(RAND_MAX) * Float(difference + 1)) + lower
    }
}

class DemoChatItemFactory {

    private struct Item {
        var isIncoming = Bool.random()
        var text = LoremIpsum.words(withNumber: Int.random(lower: 1, upper: 20)) ?? ""
        var type: String = "text"
    }

    private static func bootstrapRandomItems() -> [Item] {
        var items = [Item]()
        for _ in 0...100 {
            items.append(Item())
        }
        return items
    }

    static func createChatItemsTG() -> [ChatItemProtocol] {
        var result = [ChatItemProtocol]()
        for (_, item) in bootstrapRandomItems().enumerated() {
            if item.type == "text" {
                let senderId = item.isIncoming ? "incoming" : "outgoing"
                let chatItem = TGMessageFactory.createTextMessage(text: item.text, senderId: senderId, isIncoming: item.isIncoming, showAvatar: false)
                result.insert(chatItem, at: 0)
            }
        }
        return result
    }

    static func createChatItemsMM() -> [ChatItemProtocol] {
        var result = [ChatItemProtocol]()
        for (_, item) in bootstrapRandomItems().enumerated() {
            if item.type == "text" {
                let senderId = item.isIncoming ? "incoming" : "outgoing"
                let chatItem = MMMessageFactory.createTextMessage(text: item.text, senderId: senderId, isIncoming: item.isIncoming)
                result.append(chatItem)
            }
        }
        return result
    }

    static func createChatItemsSLK() -> [ChatItemProtocol] {
        var result = [ChatItemProtocol]()
        for (_, item) in bootstrapRandomItems().enumerated() {
            if item.type == "text" {
                let senderId = item.isIncoming ? "incoming" : "outgoing"
                let chatItem = SLKMessageFactory.createTextMessage(text: item.text, senderId: senderId, isIncoming: item.isIncoming)
                result.insert(chatItem, at: 0)
            }
        }
        return result
    }
}
