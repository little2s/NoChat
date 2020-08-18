//
//  TextMessageLayout.swift
//  NoChatExample
//
//  Created by yinglun on 2020/8/15.
//  Copyright © 2020 little2s. All rights reserved.
//

import UIKit
import NoChat

struct TextMessageLayout: ItemLayout {

    typealias Item = Message
        
    let cellReuseIdentifier: String = TextMessageCell.reuseIdentifier
    
    let cellRegister: CellRegister = .class(TextMessageCell.self)
    
    let item: Item
    
    var size: CGSize = .zero
    
    init(item: Item) {
        self.item = item
        switch item.body {
        case .text(let string):
            let textColor: UIColor
            if item.isOutgoing {
                textColor = UIColor.white
            } else {
                if #available(iOS 13.0, *) {
                    textColor = UIColor.label
                } else {
                    textColor = UIColor.black
                }
            }

            self.attributedString = NSAttributedString(string: string, attributes: [.font: Style.font, .foregroundColor: textColor])
        }
    }
    
    var attributedString: NSAttributedString = NSAttributedString()
    
    mutating func calculate(preferredWidth: CGFloat) {
        let bubbleMaxWidth = floor(preferredWidth * 0.65)
        let textRect = attributedString.boundingRect(with: CGSize(width: bubbleMaxWidth - Style.insets.left - Style.insets.right, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        let textWidth = ceil(textRect.width)
        let textHeight = ceil(textRect.height)
        
        let bubbleWidth = textWidth + Style.insets.left + Style.insets.right
        let bubbleHeight = max(textHeight + Style.insets.top + Style.insets.bottom, 36)
        
        let itemHeight = bubbleHeight + Style.margin.top + Style.margin.bottom
        size = CGSize(width: preferredWidth, height: itemHeight)
        
        if item.isOutgoing {
            bubbleViewFrame = CGRect(x: preferredWidth - Style.margin.right - bubbleWidth, y: Style.margin.top, width: bubbleWidth, height: bubbleHeight)
        } else {
            bubbleViewFrame = CGRect(x: Style.margin.left, y: Style.margin.top, width: bubbleWidth, height: bubbleHeight)
        }
        textViewFrame = bubbleViewFrame.inset(by: Style.insets)
    }
    
    var bubbleViewFrame: CGRect = .zero
    var textViewFrame: CGRect = .zero
    
    struct Style {
        static let margin = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20)
        static let insets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        static let font = UIFont.systemFont(ofSize: 16, weight: .regular)
    }
    
}
