//
//  DateItemPresenter.swift
//  NoChat
//
//  Created by little2s on 16/4/7.
//  Copyright © 2016年 Ninty. All rights reserved.
//

import Foundation
import NoChat

open class DateItemPresenter: ChatItemPresenterProtocol {
    
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter
    }()
    
    let dateItem: DateItem
    
    open var dateString: String {
        return DateItemPresenter.dateFormatter.string(from: dateItem.date as Date)
    }
    
    public init(dateItem: DateItem) {
        self.dateItem = dateItem
    }
    
    open static func registerCells(_ collectionView: UICollectionView) {
        collectionView.register(DateItemCollectionViewCell.self, forCellWithReuseIdentifier: "DateItemCollectionViewCell")
    }
    
    open func dequeueCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateItemCollectionViewCell", for: indexPath)
        UIView.performWithoutAnimation {
            cell.contentView.transform = collectionView.transform
        }
        return cell
    }
    
    open func configureCell(_ cell: UICollectionViewCell, decorationAttributes: ChatItemDecorationAttributesProtocol?) {
        guard let dateCell = cell as? DateItemCollectionViewCell else {
            fatalError("Cell type not match")
        }
        
        dateCell.dateLabel.text = dateString
        dateCell.dateLabel.sizeToFit()
    }
    
    open var canCalculateHeightInBackground: Bool {
        return true
    }
    
    open func heightForCell(maximumWidth width: CGFloat, decorationAttributes: ChatItemDecorationAttributesProtocol?) -> CGFloat {
        return 24
    }
    
}
