//
//  ConversationDataSource.swift
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

class TGChatDataSource: ChatDataSourceProtocol {
    var hasMoreNext: Bool = false
    var hasMorePrevious: Bool = false
    var chatItems: [ChatItemProtocol] = []
    weak var delegate: ChatDataSourceDelegateProtocol?
    
    func loadNext(_ completion: () -> Void) {
        completion()
    }
    
    func loadPrevious(_ completion: () -> Void) {
        completion()
    }
    
    func adjustNumberOfMessages(preferredMaxCount: Int?, focusPosition: Double, completion:(_ didAdjust: Bool) -> Void) {
        completion(false)
    }
    
    
    func addMessages(messages: [TGMessage]) {
        chatItems.insert(contentsOf: messages.reversed().map { $0 as ChatItemProtocol }, at: 0)
        delegate?.chatDataSourceDidUpdate(self)
    }
    
}


// MARK: WeChat

class MMChatDataSource: ChatDataSourceProtocol {
    var hasMoreNext: Bool = false
    var hasMorePrevious: Bool = false
    var chatItems: [ChatItemProtocol] = []
    weak var delegate: ChatDataSourceDelegateProtocol?
    
    func loadNext(_ completion: () -> Void) {
        completion()
    }
    
    func loadPrevious(_ completion: () -> Void) {
        completion()
    }
    
    func adjustNumberOfMessages(preferredMaxCount: Int?, focusPosition: Double, completion:(_ didAdjust: Bool) -> Void) {
        completion(false)
    }
    
    
    func addMessages(messages: [MMMessage]) {
        chatItems.append(contentsOf: messages.map { $0 as ChatItemProtocol })
        delegate?.chatDataSourceDidUpdate(self)
    }
    
}

// MARK: Slack

class SLKChatDataSource: ChatDataSourceProtocol {
    var hasMoreNext: Bool = false
    var hasMorePrevious: Bool = false
    var chatItems: [ChatItemProtocol] = []
    weak var delegate: ChatDataSourceDelegateProtocol?
    
    func loadNext(_ completion: () -> Void) {
        completion()
    }
    
    func loadPrevious(_ completion: () -> Void) {
        completion()
    }
    
    func adjustNumberOfMessages(preferredMaxCount: Int?, focusPosition: Double, completion:(_ didAdjust: Bool) -> Void) {
        completion(false)
    }
    
    
    func addMessages(messages: [SLKMessage]) {
        chatItems.insert(contentsOf: messages.reversed().map { $0 as ChatItemProtocol }, at: 0)
        delegate?.chatDataSourceDidUpdate(self)
    }
    
}
