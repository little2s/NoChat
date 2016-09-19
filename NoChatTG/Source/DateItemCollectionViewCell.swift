//
//  DateItemCollectionViewCell.swift
//  NoChatTG
//
//  Created by little2s on 16/5/24.
//  Copyright © 2016年 little2s. All rights reserved.
//

import UIKit

open class DateItemCollectionViewCell: UICollectionViewCell {
    
    open lazy var dateLabel: ColorLabel! = {
        let label = ColorLabel()
        label.backgroundColor = UIColor(white: 0.2, alpha: 0.25)
        label.cornerRadius = 8
        label.hPadding = 10
        label.vPadding = 2
        label.font = self.font
        label.textColor = UIColor.white
        return label
    }()
    
    fileprivate lazy var font: UIFont = {
        let dateFont: UIFont
        if #available(iOS 8.2, *) {
            dateFont = UIFont.systemFont(ofSize: 13, weight: UIFontWeightMedium)
        } else {
            dateFont = UIFont(name: "HelveticaNeue-Medium", size: 13)!
        }
        return dateFont
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    fileprivate func commonInit() {
        backgroundColor = UIColor.clear
        contentView.addSubview(dateLabel)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        dateLabel.center = contentView.center
    }
    
    open override func snapshotView(afterScreenUpdates afterUpdates: Bool) -> UIView {
        UIGraphicsBeginImageContext(bounds.size)
        
        draw(bounds)
        
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let snapshotImageView = UIImageView(frame: bounds)
        snapshotImageView.image = snapshotImage
        
        return snapshotImageView
    }
}
