//
//  DateItemPresenterBuilder.swift
//  NoChat
//
//  Created by little2s on 16/4/7.
//  Copyright © 2016年 Ninty. All rights reserved.
//

import Foundation
import NoChat

open class DateItemPresenterBuider: ChatItemPresenterBuilderProtocol {
    public init() {}
    
    open var presenterType: ChatItemPresenterProtocol.Type {
        return DateItemPresenter.self
    }
    
    open func canHandleChatItem(_ chatItem: ChatItemProtocol) -> Bool {
        return chatItem is DateItem ? true : false
    }
    
    open func createPresenterWithChatItem(_ chatItem: ChatItemProtocol) -> ChatItemPresenterProtocol {
        guard let dateItem = chatItem as? DateItem else {
            fatalError("Chat item not match")
        }
        return DateItemPresenter(dateItem: dateItem)
    }
    
}
