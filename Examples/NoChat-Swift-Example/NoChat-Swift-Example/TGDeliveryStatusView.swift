//
//  TGDeliveryStatusView.swift
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

class TGDeliveryStatusView: UIView {
    
    var clockView = TGClockProgressView()
    var checkmark1ImageView = UIImageView(image: Constant.checkmark1Image)
    var checkmark2ImageView = UIImageView(image: Constant.checkmark2Image)
    
    var deliveryStatus: MessageDeliveryStatus = .Idle {
        didSet {
            updateUI()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(clockView)
        addSubview(checkmark1ImageView)
        addSubview(checkmark2ImageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        clockView.frame = bounds
        checkmark1ImageView.frame = CGRect(x: 0, y: 2, width: 12, height: 11)
        checkmark2ImageView.frame = CGRect(x: 3, y: 2, width: 12, height: 11)
    }
    
    private func updateUI() {
        if deliveryStatus == .Delivering {
            clockView.isHidden = false
            clockView.startAnimating()
            checkmark1ImageView.isHidden = true
            checkmark2ImageView.isHidden = true
        } else if (deliveryStatus == .Delivered) {
            clockView.stopAnimating()
            clockView.isHidden = true
            checkmark1ImageView.isHidden = false
            checkmark2ImageView.isHidden = true
        } else if (deliveryStatus == .Read) {
            clockView.stopAnimating()
            clockView.isHidden = true
            checkmark1ImageView.isHidden = false
            checkmark2ImageView.isHidden = false
        } else {
            clockView.stopAnimating()
            clockView.isHidden = true
            checkmark1ImageView.isHidden = true
            checkmark2ImageView.isHidden = true
        }
    }
    
    struct Constant {
        static let checkmark1Image = UIImage(named: "TGMessageCheckmark1")!
        static let checkmark2Image = UIImage(named: "TGMessageCheckmark2")!
    }
    
}
