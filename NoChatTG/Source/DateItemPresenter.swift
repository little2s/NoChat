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
    
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd"
        return dateFormatter
    }()
    
    let dateItem: DateItem
    
    public var dateString: String {
        return DateItemPresenter.dateFormatter.string(from: dateItem.date as Date)
    }
    
    public init(dateItem: DateItem) {
        self.dateItem = dateItem
    }
    
    public static func registerCells(_ collectionView: UICollectionView) {
        collectionView.register(DateItemCollectionViewCell.self, forCellWithReuseIdentifier: "DateItemCollectionViewCell")
    }
    
    public func dequeueCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateItemCollectionViewCell", for: indexPath as IndexPath)
        UIView.performWithoutAnimation {
            cell.contentView.transform = collectionView.transform
        }
        return cell
    }
    
    public func configureCell(_ cell: UICollectionViewCell, decorationAttributes: ChatItemDecorationAttributesProtocol?) {
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
