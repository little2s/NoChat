/*
 The MIT License (MIT)
 
 Copyright (c) 2015-present Badoo Trading Limited.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

import UIKit

extension UIImage {
    
    public func ntg_tintWithColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(origin: CGPoint.zero, size: self.size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()
        color.setFill()
        context!.fill(rect)
        self.draw(in: rect, blendMode: .destinationIn, alpha: 1)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!.resizableImage(withCapInsets: self.capInsets)
    }
    
    public func ntg_blendWithColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(origin: CGPoint.zero, size: self.size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        context!.translateBy(x: 0, y: rect.height)
        context!.scaleBy(x: 1.0, y: -1.0)
        context!.setBlendMode(.normal)
        context!.draw(self.cgImage!, in: rect)
        context!.clip(to: rect, mask: self.cgImage!)
        color.setFill()
        context!.addRect(rect)
        context!.drawPath(using: .fill)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!.resizableImage(withCapInsets: self.capInsets)
    }
    
    public static func ntg_imageWithColor(_ color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(origin: CGPoint.zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}

extension UIColor {
    public func ntg_blendWithColor(_ color: UIColor) -> UIColor {
        var r1: CGFloat = 0, r2: CGFloat = 0
        var g1: CGFloat = 0, g2: CGFloat = 0
        var b1: CGFloat = 0, b2: CGFloat = 0
        var a1: CGFloat = 0, a2: CGFloat = 0
        self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        let alpha = a2, beta = 1 - alpha
        let r = r1 * beta + r2 * alpha
        let g = g1 * beta + g2 * alpha
        let b = b1 * beta + b2 * alpha
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }
}
