//
//  InputPanel.swift
//  
//
//  Created by yinglun on 2020/8/9.
//

import UIKit

public protocol InputPanelDelegate: class {
    func inputPanel(_ inputPanel: InputPanel, willChange height: CGFloat, duration: TimeInterval, animationCurve: Int)
}

open class InputPanel: UIView {
    
    open weak var delegate: InputPanelDelegate?
    
    open func endInputting(animated: Bool) {
        
    }
    
    open func adjust(for size: CGSize, keyboardHeight: CGFloat, duration: TimeInterval, animationCurve: Int) {
        
    }
    
    open func change(to size: CGSize, keyboardHeight: CGFloat, duration: TimeInterval) {
        
    }
    
}
