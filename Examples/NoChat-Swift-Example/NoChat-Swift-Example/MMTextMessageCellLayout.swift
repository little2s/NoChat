//
//  MMTextMessageCellLayout.swift
//  NoChat-Swift-Example
//
//  Copyright (c) 2016-present, little2s.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import NoChat
import YYText

class MMTextMessageCellLayout: MMBaseMessageCellLayout {
    
    var bubbleImage: UIImage?
    var highlightBubbleImage: UIImage?
    
    var bubbleImageViewFrame = CGRect.zero
    var textLableFrame = CGRect.zero
    var textLayout: YYTextLayout?
    
    private var attributedText: NSMutableAttributedString?
    
    required init(chatItem: NOCChatItem, cellWidth width: CGFloat) {
        super.init(chatItem: chatItem, cellWidth: width)
        reuseIdentifier = "MMTextMessageCell"
        setupAttributedText()
        setupBubbleImage()
        calculate()
    }
    
    private func setupAttributedText() {
        let text = message.text
        let attributedText = NSMutableAttributedString(string: text, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): Style.textFont, convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): Style.textColor]))
        
        if text == "/start" {
            attributedText.yy_setColor(Style.linkColor, range: attributedText.yy_rangeOfAll())
            
            let highlightBorder = YYTextBorder()
            highlightBorder.insets = UIEdgeInsets(top: -2, left: 0, bottom: -2, right: 0)
            highlightBorder.cornerRadius = 2
            highlightBorder.fillColor = Style.linkBackgroundColor
            
            let highlight = YYTextHighlight()
            highlight.setBackgroundBorder(highlightBorder)
            highlight.userInfo = ["command": text]
            
            attributedText.yy_setTextHighlight(highlight, range: attributedText.yy_rangeOfAll())
        }
        
        self.attributedText = attributedText
    }
    
    private func setupBubbleImage() {
        bubbleImage = isOutgoing ? Style.outgoingBubbleImage : Style.incomingBubbleImage
        
        highlightBubbleImage = isOutgoing ? Style.highlightOutgoingBubbleImage : Style.highlightIncomingBubbleImage
    }
    
    override func calculate() {
        super.calculate()
        
        height = 0
        bubbleViewFrame = CGRect.zero
        bubbleImageViewFrame = CGRect.zero
        textLableFrame = CGRect.zero
        textLayout = nil
        
        guard let text = attributedText, text.length > 0 else {
            return
        }
        
        // dynamic font support
        let dynamicFont = Style.textFont
        text.yy_setAttribute(convertFromNSAttributedStringKey(NSAttributedString.Key.font), value: dynamicFont)
        
        let preferredMaxBubbleWidth = ceil(width * 0.68)
        var bubbleViewWidth = preferredMaxBubbleWidth
        
        let textMargin = isOutgoing ? UIEdgeInsets(top: 12, left: 20, bottom: 20, right: 22) : UIEdgeInsets(top: 12, left: 22, bottom: 20, right: 20)
        var textLabelWidth = bubbleViewWidth - textMargin.left - textMargin.right
        
        let modifier = MMTextLinePositionModifier()
        modifier.font = dynamicFont
        modifier.paddingTop = 2
        modifier.paddingBottom = 2
        
        let container = YYTextContainer()
        container.size = CGSize(width: textLabelWidth, height: CGFloat.greatestFiniteMagnitude)
        container.linePositionModifier = modifier
        
        guard let textLayout = YYTextLayout(container: container, text: text) else {
            return
        }
        self.textLayout = textLayout
        
        textLabelWidth = ceil(textLayout.textBoundingSize.width)
        let textLabelHeight = ceil(modifier.height(forLineCount: textLayout.rowCount))
        textLableFrame = CGRect(x: textMargin.left, y: textMargin.top, width: textLabelWidth, height: textLabelHeight)
        
        bubbleViewWidth = textLabelWidth + textMargin.left + textMargin.right
        let bubbleViewHeight = textLabelHeight + textMargin.top + textMargin.bottom
        bubbleViewFrame = isOutgoing ? CGRect(x: width - bubbleViewMargin.right - bubbleViewWidth, y: bubbleViewMargin.top, width: bubbleViewWidth, height: bubbleViewHeight) : CGRect(x: bubbleViewMargin.left, y: bubbleViewMargin.top, width: bubbleViewWidth, height: bubbleViewHeight)
        bubbleImageViewFrame = CGRect(x: 0, y: 0, width: bubbleViewWidth, height: bubbleViewHeight)
        
        height = bubbleViewHeight
    }
    
    struct Style {
        static let outgoingBubbleImage = UIImage(named: "MMBubbleOutgoing")!
        static let highlightOutgoingBubbleImage = UIImage(named: "MMBubbleOutgoingHL")!
        static let incomingBubbleImage = UIImage(named: "MMBubbleIncoming")!
        static let highlightIncomingBubbleImage = UIImage(named: "MMBubbleIncomingHL")!
        
        static var textFont: UIFont {
            return UIFont.preferredFont(forTextStyle: .body)
        }
        static let textColor = UIColor.black
        
        static let linkColor = UIColor(red: 31/255.0, green: 121/255.0, blue: 253/255.0, alpha: 1)
        static let linkBackgroundColor = UIColor(red: 212/255.0, green: 209/255.0, blue: 209/255.0, alpha: 1)
    }
    
}


fileprivate
class MMTextLinePositionModifier: NSObject, YYTextLinePositionModifier {
    
    var font = UIFont.systemFont(ofSize: 16)
    var paddingTop = CGFloat(0)
    var paddingBottom = CGFloat(0)
    var lineHeightMultiple = CGFloat(0)
    
    override init() {
        super.init()
        
        if #available(iOS 9.0, *) {
            lineHeightMultiple = 1.34 // for PingFang SC
        } else {
            lineHeightMultiple = 1.3125 // for Heiti SC
        }
    }
    
    fileprivate func modifyLines(_ lines: [YYTextLine], fromText text: NSAttributedString, in container: YYTextContainer) {
        let ascent = font.pointSize * 0.86
        
        let lineHeight = font.pointSize * lineHeightMultiple
        for line in lines {
            var position = line.position
            position.y = paddingTop + ascent + CGFloat(line.row) * lineHeight
            line.position = position
        }
    }
    
    fileprivate func copy(with zone: NSZone? = nil) -> Any {
        let one = MMTextLinePositionModifier()
        one.font = font
        one.paddingTop = paddingTop
        one.paddingBottom = paddingBottom
        one.lineHeightMultiple = lineHeightMultiple
        return one
    }
    
    fileprivate func height(forLineCount lineCount: UInt) -> CGFloat {
        if lineCount == 0 {
            return 0
        }
        let ascent = font.pointSize * 0.86
        let descent = font.pointSize * 0.14
        let lineHeight = font.pointSize * lineHeightMultiple
        return paddingTop + paddingBottom + ascent + descent + CGFloat(lineCount - 1) * lineHeight
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
