//
//  ColorLabel.swift
//  NoChatTG
//
//  Created by little2s on 16/5/24.
//  Copyright © 2016年 little2s. All rights reserved.
//

import UIKit

open class ColorLabel: UILabel {
    @IBInspectable
    open var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable
    open var hPadding: CGFloat = 0
    
    @IBInspectable
    open var vPadding: CGFloat = 0
    
    open override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let textInsets = UIEdgeInsets(top: vPadding, left: hPadding, bottom: vPadding, right: hPadding)
        var rect = textInsets.apply(bounds)
        rect = super.textRect(forBounds: rect, limitedToNumberOfLines: numberOfLines)
        return textInsets.inverse.apply(rect)
    }
    
    open override func drawText(in rect: CGRect) {
        let textInsets = UIEdgeInsets(top: vPadding, left: hPadding, bottom: vPadding, right: hPadding)
        super.drawText(in: textInsets.apply(rect))
    }
}

private extension UIEdgeInsets {
    var inverse: UIEdgeInsets {
        return UIEdgeInsets(top: -top, left: -left, bottom: -bottom, right: -right)
    }
    
    func apply(_ rect: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(rect, self)
    }
}
