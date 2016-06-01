//
//  ColorLabel.swift
//  NoChatTG
//
//  Created by little2s on 16/5/24.
//  Copyright © 2016年 little2s. All rights reserved.
//

import UIKit

public class ColorLabel: UILabel {
    @IBInspectable
    public var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable
    public var hPadding: CGFloat = 0
    
    @IBInspectable
    public var vPadding: CGFloat = 0
    
    public override func textRectForBounds(bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let textInsets = UIEdgeInsets(top: vPadding, left: hPadding, bottom: vPadding, right: hPadding)
        var rect = textInsets.apply(bounds)
        rect = super.textRectForBounds(rect, limitedToNumberOfLines: numberOfLines)
        return textInsets.inverse.apply(rect)
    }
    
    public override func drawTextInRect(rect: CGRect) {
        let textInsets = UIEdgeInsets(top: vPadding, left: hPadding, bottom: vPadding, right: hPadding)
        super.drawTextInRect(textInsets.apply(rect))
    }
}

private extension UIEdgeInsets {
    var inverse: UIEdgeInsets {
        return UIEdgeInsets(top: -top, left: -left, bottom: -bottom, right: -right)
    }
    
    func apply(rect: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(rect, self)
    }
}
