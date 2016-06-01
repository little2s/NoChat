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

private let scale = UIScreen.mainScreen().scale

public enum HorizontalAlignment {
    case Left
    case Center
    case Right
}

public enum VerticalAlignment {
    case Top
    case Center
    case Bottom
}

public extension CGSize {
    func ntg_insetBy(dx dx: CGFloat, dy: CGFloat) -> CGSize {
        return CGSize(width: self.width - dx, height: self.height - dy)
    }

    func ntg_outsetBy(dx dx: CGFloat, dy: CGFloat) -> CGSize {
        return self.ntg_insetBy(dx: -dx, dy: -dy)
    }
}

public extension CGSize {
    func ntg_round() -> CGSize {
        return CGSize(width: ceil(self.width * scale) * (1.0 / scale), height: ceil(self.height * scale) * (1.0 / scale) )
    }

    func ntg_rect(inContainer containerRect: CGRect, xAlignament: HorizontalAlignment, yAlignment: VerticalAlignment, dx: CGFloat, dy: CGFloat) -> CGRect {
        var originX, originY: CGFloat

        // Horizontal alignment
        switch xAlignament {
        case .Left:
            originX = 0
        case .Center:
            originX = containerRect.midX - self.width / 2.0
        case .Right:
            originX = containerRect.maxY - self.width
        }

        // Vertical alignment
        switch yAlignment {
        case .Top:
            originY = 0
        case .Center:
            originY = containerRect.midY - self.height / 2.0
        case .Bottom:
            originY = containerRect.maxY - self.height
        }

        return CGRect(origin: CGPoint(x: originX, y: originY).ntg_offsetBy(dx: dx, dy: dy), size: self)
    }
}

public extension CGRect {
    var ntg_bounds: CGRect {
        return CGRect(origin: CGPoint.zero, size: self.size)
    }

    var ntg_center: CGPoint {
        return CGPoint(x: self.midX, y: self.midY)
    }

    var ntg_maxY: CGFloat {
        get {
            return self.maxY
        } set {
            let delta = newValue - self.maxY
            self.origin = self.origin.ntg_offsetBy(dx: 0, dy: delta)
        }
    }

    func ntg_round() -> CGRect {
        let origin = CGPoint(x: ceil(self.origin.x * scale) * (1.0 / scale), y: ceil(self.origin.y * scale) * (1.0 / scale))
        return CGRect(origin: origin, size: self.size.ntg_round())
    }
}


public extension CGPoint {
    func ntg_offsetBy(dx dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + dx, y: self.y + dy)
    }
}

public extension UIView {
    var ntg_rect: CGRect {
        get {
            return CGRect(origin: CGPoint(x: self.center.x - self.bounds.width / 2, y: self.center.y - self.bounds.height), size: self.bounds.size)
        }
        set {
            let roundedRect = newValue.ntg_round()
            self.bounds = roundedRect.ntg_bounds
            self.center = roundedRect.ntg_center
        }
    }
}

public extension UIEdgeInsets {

    public var ntg_horziontalInset: CGFloat {
        return self.left + self.right
    }

    public var ntg_verticalInset: CGFloat {
        return self.top + self.bottom
    }

    public var ntg_hashValue: Int {
        return self.top.hashValue ^ self.left.hashValue ^ self.bottom.hashValue ^ self.right.hashValue
    }

}

