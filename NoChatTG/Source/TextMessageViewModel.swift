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

public class TextMessageViewModel: TextMessageViewModelProtocol {
    public let attributedText: NSAttributedString
    public let messageViewModel: MessageViewModelProtocol
    
    private static let style = TextBubbleViewStyle()
    
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
    
    public func didTapURL(url: NSURL, bubbleView: TextBubbleView) {
        
    }
}

public class TextMessageViewModelBuilder: MessageViewModelBuilderProtocol {
    public init() {}
    
    private let messageViewModelBuilder = MessageViewModelBuilder()
    
    public func createMessageViewModel(message message: MessageProtocol) -> MessageViewModelProtocol {
        let messageViewModel = messageViewModelBuilder.createMessageViewModel(message: message)
        let textMessageViewModel = TextMessageViewModel(text: message.content, messageViewModel: messageViewModel)
        return textMessageViewModel
    }
}

// MARK: Convenience methods
private func createAttributedText(text: String, attributes: [String: NSObject]) -> NSAttributedString {

    let attributedText = NSMutableAttributedString(string: text, attributes: attributes)
    
    return attributedText
}
