//
//  ChatTextView.swift
//  NoChat
//
//  Created by little2s on 16/3/29.
//  Copyright © 2016年 Ninty. All rights reserved.
//

import UIKit

/// UITextView with hacks to avoid selection, loupe, define...
public class ChatTextView: UITextView {
    
    public override func canBecomeFirstResponder() -> Bool {
        return false
    }
    
    public override func addGestureRecognizer(gestureRecognizer: UIGestureRecognizer) {
        if let longPressGestureRecognizer = gestureRecognizer as? UILongPressGestureRecognizer {
            if longPressGestureRecognizer.minimumPressDuration == 0.5 {
                return
            }
        }
        
        super.addGestureRecognizer(gestureRecognizer)
    }
    
    public override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        return false
    }
    
}