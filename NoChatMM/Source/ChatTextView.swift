//
//  ChatTextView.swift
//  NoChat
//
//  Created by little2s on 16/3/29.
//  Copyright © 2016年 Ninty. All rights reserved.
//

import UIKit

/// UITextView with hacks to avoid selection, loupe, define...
open class ChatTextView: UITextView {
    
    open override var canBecomeFirstResponder : Bool {
        return false
    }
    
    open override func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        if let longPressGestureRecognizer = gestureRecognizer as? UILongPressGestureRecognizer {
            if longPressGestureRecognizer.minimumPressDuration == 0.5 {
                return
            }
        }
        
        super.addGestureRecognizer(gestureRecognizer)
    }
    
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    
}
