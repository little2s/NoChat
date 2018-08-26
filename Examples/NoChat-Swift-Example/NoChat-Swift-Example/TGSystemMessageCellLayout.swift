//
//  TGSystemMessageCellLayout.swift
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

class TGSystemMessageCellLayout: NSObject, NOCChatItemCellLayout {
    
    var reuseIdentifier: String = "TGSystemMessageCell"
    var chatItem: NOCChatItem
    var width: CGFloat
    var height: CGFloat = 0
    
    var message: Message {
        return chatItem as! Message
    }
    
    var backgroundImageViewFrame = CGRect.zero
    var backgroundImage: UIImage?
    var textLabelFrame = CGRect.zero
    var attributedText: NSAttributedString?
    
    required init(chatItem: NOCChatItem, cellWidth width: CGFloat) {
        self.chatItem = chatItem
        self.width = width
        super.init()
        setupBackgroundImage()
        setupAttributedText()
        calculate()
    }
    
    func calculate() {
        height = 0
        backgroundImageViewFrame = CGRect.zero
        textLabelFrame = CGRect.zero
        
        guard let at = attributedText, at.length > 0 else {
            return
        }
        
        let limitSize = CGSize(width: ceil(width * 0.75), height: CGFloat.greatestFiniteMagnitude)
        let textLabelSize = at.noc_sizeThatFits(size: limitSize)
        
        let vPadding = CGFloat(4)
        
        let textLabelInsets = Style.textInsets
        
        textLabelFrame = CGRect(x: width/2 - textLabelSize.width/2, y: vPadding, width: textLabelSize.width, height: textLabelSize.height)
        
        backgroundImageViewFrame = CGRect(x: textLabelFrame.origin.x - textLabelInsets.left, y: textLabelFrame.origin.y - textLabelInsets.top, width: textLabelFrame.width + textLabelInsets.left + textLabelInsets.right, height: textLabelFrame.height + textLabelInsets.top + textLabelInsets.bottom)
        
        height = vPadding * 2 + backgroundImageViewFrame.height
    }
    
    private func setupBackgroundImage() {
        backgroundImage = Style.systemMessageBackground
    }
    
    private func setupAttributedText() {
        let text = message.text
        let one = NSAttributedString(string: text, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): Style.textFont, convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): Style.textColor]))
        attributedText = one
    }
    
    struct Style {
        static let textInsets = UIEdgeInsets(top: 2, left: 7, bottom: 2, right: 5)
        static let textFont = UIFont.systemFont(ofSize: 13)
        static let textColor = UIColor.white
        static let textBackgroundColor = UIColor(white: 0.2, alpha: 0.25)
        
        static let systemMessageBackground: UIImage? = {
            if let rawImage = TGGenerateSystemMessageBackground() {
                let image = rawImage.stretchableImage(withLeftCapWidth: Int(rawImage.size.width/2), topCapHeight: Int(rawImage.size.height/2))
                return image
            } else {
                return nil
            }
        }()
    }
    
}

fileprivate func TGGenerateSystemMessageBackground() -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(CGSize(width: 20, height: 20), false, 0)
    
    guard let context = UIGraphicsGetCurrentContext() else {
        return nil
    }

    let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 20, height: 20), cornerRadius: 10)
    
    let color = TGSystemMessageCellLayout.Style.textBackgroundColor
    color.setFill()
    
    context.addPath(path.cgPath)
    context.fillPath()
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    
    UIGraphicsEndImageContext()
    
    return image
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
