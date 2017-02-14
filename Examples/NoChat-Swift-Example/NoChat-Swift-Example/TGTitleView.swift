//
//  TGTitleView.swift
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

class TGTitleView: UIView {
    
    var title: String? {
        set {
            if titleLabel.text != newValue {
                titleLabel.text = newValue
                updateLayouts()
            }
        }
        get {
            return titleLabel.text
        }
    }
    var detail: String? {
        set {
            if detailLabel.text != newValue {
                detailLabel.text = newValue
                updateLayouts()
            }
        }
        get {
            return detailLabel.text
        }
    }
    
    private var titleLabel = UILabel()
    private var detailLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel.text = "Title"
        titleLabel.font = UIFont.noc_mediumSystemFont(ofSize: 17)
        titleLabel.textColor = UIColor.black
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        
        detailLabel.text = "detail"
        detailLabel.font = UIFont.systemFont(ofSize: 12)
        detailLabel.textColor = UIColor.gray
        detailLabel.textAlignment = .center
        addSubview(detailLabel)
        
        updateLayouts()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateLayouts()
    }
    
    private func updateLayouts() {
        if self.traitCollection.verticalSizeClass == .compact {
            setupCompactLayouts()
        } else {
            setupRegularLayouts()
        }
    }
    
    private let unlimitSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
    
    private func setupRegularLayouts() {
        let titleLabelSize = titleLabel.sizeThatFits(unlimitSize)
        let detailLabelSize = detailLabel.sizeThatFits(unlimitSize)
        
        let titleViewWidth = min(200, max(titleLabelSize.width, detailLabelSize.width))
        let titleViewHeight = CGFloat(44)
        frame = CGRect(x: 0, y: 0, width: titleViewWidth, height: titleViewHeight)
        
        let titleLabelY = CGFloat(4)
        titleLabel.frame = CGRect(x: 0, y: titleLabelY, width: titleViewWidth, height: titleLabelSize.height)
        
        let detailLabelY = titleViewHeight - 4 - detailLabelSize.height
        detailLabel.frame = CGRect(x: 0, y: detailLabelY, width: titleViewWidth, height: detailLabelSize.height)
    }
    
    private func setupCompactLayouts() {
        let titleLabelSize = titleLabel.sizeThatFits(unlimitSize)
        let detailLabelSize = detailLabel.sizeThatFits(unlimitSize)
        
        let titleViewWidth = min(350, titleLabelSize.width + 8 + detailLabelSize.width)
        let titleViewHeight = CGFloat(40)
        frame = CGRect(x: 0, y: 0, width: titleViewWidth, height: titleViewHeight)
        
        let titleLabelX = CGFloat(0)
        let titleLabelY = titleViewHeight/2 - titleLabelSize.height/2
        titleLabel.frame = CGRect(x: CGFloat(titleLabelX), y: titleLabelY, width: titleLabelSize.width, height: titleLabelSize.height)
        
        let detailLabelX = titleViewWidth - detailLabelSize.width
        let detailLabelY = titleViewHeight/2 - detailLabelSize.height/2
        detailLabel.frame = CGRect(x: detailLabelX, y: detailLabelY, width: detailLabelSize.width, height: detailLabelSize.height)
    }
}
