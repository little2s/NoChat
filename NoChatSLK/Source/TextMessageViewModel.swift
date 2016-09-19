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
    }
    
    open func didTapURL(_ url: URL, bubbleView: TextBubbleView) {
        
    }
    
    open func getAvatar(completionHandler: ((UIImage?) -> Void)?) {
        
    }
}

open class TextMessageViewModelBuilder: MessageViewModelBuilderProtocol {
    public init() {}
    
    fileprivate let messageViewModelBuilder = MessageViewModelBuilder()
    
    open func createMessageViewModel(message: MessageProtocol) -> MessageViewModelProtocol {
        let messageViewModel = messageViewModelBuilder.createMessageViewModel(message: message)
        let textMessageViewModel = TextMessageViewModel(text: message.content, messageViewModel: messageViewModel)
        return textMessageViewModel
    }
}

// MARK: Convenience methods
private func createAttributedText(_ text: String, attributes: [String: NSObject]) -> NSAttributedString {

    let attributedText = NSMutableAttributedString(string: text, attributes: attributes)
    
    return attributedText
}
