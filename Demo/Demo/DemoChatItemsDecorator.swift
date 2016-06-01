//
//  ChatItemsDecorator.swift
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

// MARK: Telegram style

typealias TGDateItem = NoChatTG.DateItem
typealias TGChatItemDecorationAttributes = NoChatTG.ChatItemDecorationAttributes

class TGChatItemsDecorator: ChatItemsDecoratorProtocol {
    lazy var dateItem: TGDateItem = {
        let dateUid = NSUUID().UUIDString
        return TGDateItem(uid: dateUid, date: NSDate())
    }()
    
    func decorateItems(chatItems: [ChatItemProtocol], inverted: Bool) -> [DecoratedChatItem] {
        let bottomMargin: CGFloat = 2
        
        var decoratedChatItems = [DecoratedChatItem]()
        
        for chatItem in chatItems {
            decoratedChatItems.append(
                DecoratedChatItem(
                    chatItem: chatItem,
                    decorationAttributes: TGChatItemDecorationAttributes(bottomMargin: bottomMargin, showsTail: true)
                )
            )
        }
        
        if chatItems.isEmpty == false {
            let decoratedDateItem = DecoratedChatItem(
                chatItem: dateItem,
                decorationAttributes: TGChatItemDecorationAttributes(bottomMargin: bottomMargin, showsTail: false)
            )
            decoratedChatItems.append(decoratedDateItem)
        }
        
        return decoratedChatItems
    }
}

// MARK: WeChat style

typealias MMDateItem = NoChatMM.DateItem
typealias MMChatItemDecorationAttributes = NoChatMM.ChatItemDecorationAttributes

class MMChatItemsDecorator: ChatItemsDecoratorProtocol {
    lazy var dateItem: MMDateItem = {
        let dateUid = NSUUID().UUIDString
        return MMDateItem(uid: dateUid, date: NSDate())
    }()
    
    func decorateItems(chatItems: [ChatItemProtocol], inverted: Bool) -> [DecoratedChatItem] {
        let bottomMargin: CGFloat = 8
        
        var decoratedChatItems = [DecoratedChatItem]()
        
        if chatItems.isEmpty == false {
            let decoratedDateItem = DecoratedChatItem(
                chatItem: dateItem,
                decorationAttributes: MMChatItemDecorationAttributes(bottomMargin: bottomMargin)
            )
            decoratedChatItems.append(decoratedDateItem)
        }
        
        for chatItem in chatItems {
            decoratedChatItems.append(
                DecoratedChatItem(
                    chatItem: chatItem,
                    decorationAttributes: MMChatItemDecorationAttributes(bottomMargin: bottomMargin)
                )
            )
        }
        
        return decoratedChatItems
    }
}

// MARK: Slack style

typealias SLKChatItemDecorationAttributes = NoChatSLK.ChatItemDecorationAttributes

class SLKChatItemsDecorator: ChatItemsDecoratorProtocol {
    
    func decorateItems(chatItems: [ChatItemProtocol], inverted: Bool) -> [DecoratedChatItem] {
        let bottomMargin: CGFloat = 8
        
        var decoratedChatItems = [DecoratedChatItem]()
        
        for chatItem in chatItems {
            decoratedChatItems.append(
                DecoratedChatItem(
                    chatItem: chatItem,
                    decorationAttributes: SLKChatItemDecorationAttributes(bottomMargin: bottomMargin)
                )
            )
        }
        
        return decoratedChatItems
    }
}

