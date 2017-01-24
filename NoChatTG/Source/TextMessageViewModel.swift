//
//  TextMessageViewModel.swift
//  NoChat
//
//  Created by little2s on 16/3/19.
//  Copyright © 2016年 Ninty. All rights reserved.
//

import UIKit

public protocol TextMessageViewModelProtocol: DecoratedMessageViewModelProtocol {
    var attributedText: NSAttributedString { get } // To encapsulate links
}

open class TextMessageViewModel: TextMessageViewModelProtocol {
    public var showAvatar: Bool
    open let attributedText: NSAttributedString
    open let messageViewModel: MessageViewModelProtocol
    
    fileprivate static let style = TextBubbleViewStyle()
    
    public init(text: String, messageViewModel: MessageViewModelProtocol) {
        let textFont = TextMessageViewModel.style.font
        let textColor = TextMessageViewModel.style.textColor(messageViewModel.isIncoming)
        let attributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor
        ]
        
        self.attributedText = createAttributedText(text, attributes: attributes)
        self.messageViewModel = messageViewModel
        self.showAvatar = messageViewModel.showAvatar
    }
    
    open func didTapURL(_ url: URL, bubbleView: TextBubbleView) {
        
    }
}

open class TextMessageViewModelBuilder: MessageViewModelBuilderProtocol {
    public init() {}
    
    fileprivate let messageViewModelBuilder = MessageViewModelBuilder()
    
    open func createMessageViewModel(_ message: MessageProtocol) -> MessageViewModelProtocol {
        let messageViewModel = messageViewModelBuilder.createMessageViewModel(message)
        let textMessageViewModel = TextMessageViewModel(text: message.content, messageViewModel: messageViewModel)
        return textMessageViewModel
    }
}

// MARK: Convenience methods
private func createAttributedText(_ text: String, attributes: [String: NSObject]) -> NSAttributedString {
    let attributedText = NSMutableAttributedString(string: text, attributes: attributes)
    return attributedText
}
