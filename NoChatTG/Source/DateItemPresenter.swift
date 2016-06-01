//
//  DateItemPresenter.swift
//  NoChat
//
//  Created by little2s on 16/4/7.
//  Copyright © 2016年 Ninty. All rights reserved.
//

import Foundation
import NoChat

public class DateItemPresenter: ChatItemPresenterProtocol {
    
    static let dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMMM dd"
        return dateFormatter
    }()
    
    let dateItem: DateItem
    
    public var dateString: String {
        return DateItemPresenter.dateFormatter.stringFromDate(dateItem.date)
    }
    
    public init(dateItem: DateItem) {
        self.dateItem = dateItem
    }
    
    public static func registerCells(collectionView: UICollectionView) {
        collectionView.registerClass(DateItemCollectionViewCell.self, forCellWithReuseIdentifier: "DateItemCollectionViewCell")
    }
    
    public func dequeueCell(collectionView collectionView: UICollectionView, indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("DateItemCollectionViewCell", forIndexPath: indexPath)
        UIView.performWithoutAnimation {
            cell.contentView.transform = collectionView.transform
        }
        return cell
    }
    
    public func configureCell(cell: UICollectionViewCell, decorationAttributes: ChatItemDecorationAttributesProtocol?) {
        guard let dateCell = cell as? DateItemCollectionViewCell else {
            fatalError("Cell type not match")
        }
        
        dateCell.dateLabel.text = dateString
        dateCell.dateLabel.sizeToFit()
    }
    
    public var canCalculateHeightInBackground: Bool {
        return true
    }
    
    public func heightForCell(maximumWidth width: CGFloat, decorationAttributes: ChatItemDecorationAttributesProtocol?) -> CGFloat {
        return 24
    }
    
}