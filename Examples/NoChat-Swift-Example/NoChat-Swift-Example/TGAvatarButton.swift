//
//  TGAvatarButton.swift
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

class TGAvatarButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setImage(UIImage(named: "TGUserInfo")!, for: .normal)
        regularLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.verticalSizeClass == .compact {
            compactLayout()
        } else {
            regularLayout()
        }
    }
    
    private func regularLayout() {
        frame = CGRect(x: 0, y: 0, width: 37, height: 37)
        let widthConstraint = self.widthAnchor.constraint(equalToConstant: 37)
        let heightConstraint = self.heightAnchor.constraint(equalToConstant: 37)
        heightConstraint.isActive = true
        widthConstraint.isActive = true
    }
    
    private func compactLayout() {
        frame = CGRect(x: 0, y: 0, width: 28, height: 28)
        let widthConstraint = self.widthAnchor.constraint(equalToConstant: 28)
        let heightConstraint = self.heightAnchor.constraint(equalToConstant: 28)
        heightConstraint.isActive = true
        widthConstraint.isActive = true
    }
    
}

