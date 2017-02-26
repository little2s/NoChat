//
//  MMBaseMessageCell.swift
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

class MMBaseMessageCell: NOCChatItemCell {
    
    var bubbleView = UIView()
    var avatarImageView = UIImageView()
    
    var isHighlight = false
    
    override class func reuseIdentifier() -> String {
        return "MMBaseMessageCell"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        itemView?.addSubview(avatarImageView)
        itemView?.addSubview(bubbleView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var layout: NOCChatItemCellLayout? {
        didSet {
            guard let cellLayout = layout as? MMBaseMessageCellLayout else {
                fatalError("invalid layout type")
            }
            
            bubbleView.frame = cellLayout.bubbleViewFrame
            avatarImageView.frame = cellLayout.avatarImageViewFrame
            avatarImageView.image = cellLayout.avatarImage
        }
    }
    
}
