//
//  ChatItemPresenterBuilder.swift
//  Demo
//
//  Created by little2s on 16/5/10.
//  Copyright © 2016年 little2s. All rights reserved.
//

import Foundation
import NoChat

class ChatItemPresenterBuilder: ChatItemPresenterBuilderProtocol {
    
    var presenterType: ChatItemPresenterProtocol.Type {
        return ChatItemPresenter.self
    }
    
    func canHandleChatItem(chatItem: ChatItemProtocol) -> Bool {
        return chatItem is ChatItem ? true : false
    }
    
    func createPresenterWithChatItem(chatItem: ChatItemProtocol) -> ChatItemPresenterProtocol {
        guard let item = chatItem as? ChatItem else {
            fatalError("Chat item not match")
        }
        return ChatItemPresenter(chatItem: item)
    }
    
}