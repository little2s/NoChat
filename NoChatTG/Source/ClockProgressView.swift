//
//  ClockProgressView.swift
//  NoChat
//
//  Created by little2s on 15/12/4.
//  Copyright © 2015年 Chainsea. All rights reserved.
//

import UIKit

public class ClockProgressView: UIView {
    public struct Constant {
        static let progressFrameImage = imageFactory.createImage(name: "ClockFrame")!
        static let progressMinImage = imageFactory.createImage(name: "ClockMin")!
        static let progressHourImage = imageFactory.createImage(name: "ClockHour")!
        static let minuteDuration: TimeInterval = 0.3
        static let hourDuration: TimeInterval = 1.8
    }

    var frameView = UIImageView()
    var minView = UIImageView()
    var hourView = UIImageView()
    
    public var isAnimating = false
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public func startAnimating() {
        if isAnimating {
            return
        }
        
        hourView.layer.removeAllAnimations()
        minView.layer.removeAllAnimations()
        
        isAnimating = true
        
        animateHourView()
        animateMinView()
    }
    
    public func stopAnimating() {
        if !isAnimating {
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
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        frameView.frame = bounds
        minView.frame = bounds
        hourView.frame = bounds
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
}
