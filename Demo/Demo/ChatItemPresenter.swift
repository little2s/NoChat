//
//  ChatItemPresenter.swift
//  Demo
//
//  Created by little2s on 16/5/10.
//  Copyright © 2016年 little2s. All rights reserved.
//

import Foundation
import NoChat

class ChatItemPresenter: ChatItemPresenterProtocol {
    let chatItem: ChatItem
    
    init(chatItem: ChatItem) {
        self.chatItem = chatItem
    }
    
    static func registerCells(collectionView: UICollectionView) {
        let nib = UINib(nibName: "ChatItemCollectionViewCell", bundle: nil)
        collectionView.registerNib(nib, forCellWithReuseIdentifier: "ChatItemCollectionViewCell")
    }
    
    func dequeueCell(collectionView collectionView: UICollectionView, indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ChatItemCollectionViewCell", forIndexPath: indexPath)
        UIView.performWithoutAnimation {
            cell.contentView.transform = collectionView.transform
        }
        return cell
    }
    
    func configureCell(cell: UICollectionViewCell, decorationAttributes: ChatItemDecorationAttributesProtocol?) {
        guard let dateCell = cell as? ChatItemCollectionViewCell else {
            fatalError("Cell type not match")
        }
        
        dateCell.textLabel.text = chatItem.content
    }
    
    var canCalculateHeightInBackground: Bool {
        return true
    }
    
    func heightForCell(maximumWidth width: CGFloat, decorationAttributes: ChatItemDecorationAttributesProtocol?) -> CGFloat {
        return 50
    }
}
