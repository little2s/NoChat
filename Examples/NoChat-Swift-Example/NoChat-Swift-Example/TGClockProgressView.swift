//
//  TGClockProgressView.swift
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

import UIKit

class TGClockProgressView: UIView {
    
    var frameView = UIImageView()
    var minView = UIImageView()
    var hourView = UIImageView()
    
    var isAnimating = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        frameView.frame = bounds
        minView.frame = bounds
        hourView.frame = bounds
    }
    
    func startAnimating() {
        if isAnimating {
            return
        }
        
        hourView.layer.removeAllAnimations()
        minView.layer.removeAllAnimations()
        
        isAnimating = true
        
        animateHourView()
        animateMinView()
    }
    
    func stopAnimating() {
        if isAnimating == false {
            return;
        }
        
        isAnimating = false
        
        hourView.layer.removeAllAnimations()
        minView.layer.removeAllAnimations()
    }
    
    private func commonInit() {
        backgroundColor = UIColor.clear
        
        frameView.image = Constant.progressFrameImage
        addSubview(frameView)
        
        minView.image = Constant.progressMinImage
        addSubview(minView)
        
        hourView.image = Constant.progressHourImage
        addSubview(hourView)
    }
    
    private func animateHourView() {
        UIView.animate(withDuration: Constant.hourDuration, delay: 0.0, options: .curveLinear, animations: { () -> Void in
            self.hourView.transform = self.hourView.transform.rotated(by: CGFloat(M_2_PI))
        }, completion: { finished -> Void in
            if finished {
                self.animateHourView()
            } else {
                self.isAnimating = false
            }
        })
    }
    
    private func animateMinView() {
        UIView.animate(withDuration: Constant.minuteDuration, delay: 0.0, options: .curveLinear, animations: { () -> Void in
            self.minView.transform = self.minView.transform.rotated(by: CGFloat(M_2_PI))
        }, completion: { finished -> Void in
            if finished {
                self.animateMinView()
            } else {
                self.isAnimating = false
            }
        })
    }
    
    struct Constant {
        static let progressFrameImage = UIImage(named: "TGClockGreenFrame")!
        static let progressMinImage = UIImage(named: "TGClockGreenMin")!
        static let progressHourImage = UIImage(named: "TGClockGreenHour")!
        static let minuteDuration = TimeInterval(0.3)
        static let hourDuration = TimeInterval(1.8)
    }
    
}
