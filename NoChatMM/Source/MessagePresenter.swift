//
//  MessagePresenter.swift
//  NoChat
//
//  Created by little2s on 16/3/19.
//  Copyright © 2016年 Ninty. All rights reserved.
//

import UIKit
import NoChat

public class MessagePresenter<BubbleViewT, ViewModelBuilderT where
    BubbleViewT: UIView,
    BubbleViewT: BubbleViewProtocol,
    ViewModelBuilderT: MessageViewModelBuilderProtocol>: BaseChatItemPresenter<MessageCollectionViewCell<BubbleViewT>>
{
    // MARK: Types
    typealias ModelT = MessageProtocol
    typealias CellT = MessageCollectionViewCell<BubbleViewT>
    typealias ViewModelT = MessageViewModelProtocol
    
    // MARK: Properties
    let message: ModelT
    let sizingCell: MessageCollectionViewCell<BubbleViewT>
    let viewModelBuilder: ViewModelBuilderT
    let layoutCache: NSCache
    
    private(set) final lazy var messageViewModel: ViewModelT = {
        return self.createViewModel()
    }()
    
    var decorationAttributes: ChatItemDecorationAttributes!
    
    static var bubbleIdentifier: String {
        return BubbleViewT.bubbleIdentifier
    }
    
    static var incomingCellIdentifier: String {
        return "MessageCollectionCellIncoming-\(bubbleIdentifier)"
    }
    
    static var outgoingCellIdentifier: String {
        return "MessageCollectionCellOutgoing-\(bubbleIdentifier)"
    }
    
    var incomingCellIdentifier: String {
        return MessagePresenter<BubbleViewT, ViewModelBuilderT>.incomingCellIdentifier
    }
    
    var outgoingCellIdentifier: String {
        return MessagePresenter<BubbleViewT, ViewModelBuilderT>.outgoingCellIdentifier
    }
    
    // MARK: Initialization
    init(message: ModelT, sizingCell: CellT, viewModelBuilder: ViewModelBuilderT, layoutCache: NSCache) {
        self.message = message
        self.sizingCell = sizingCell
        self.viewModelBuilder = viewModelBuilder
        self.layoutCache = layoutCache
    }
    
    // MARK: Override
    public override static func registerCells(collectionView: UICollectionView) {
        collectionView.registerClass(CellT.self, forCellWithReuseIdentifier: incomingCellIdentifier)
        collectionView.registerClass(CellT.self, forCellWithReuseIdentifier: outgoingCellIdentifier)
    }
    
    public override func dequeueCell(collectionView collectionView: UICollectionView, indexPath: NSIndexPath) -> UICollectionViewCell {
        let identifier = messageViewModel.isIncoming ? incomingCellIdentifier : outgoingCellIdentifier
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath)
        UIView.performWithoutAnimation {
            cell.contentView.transform = collectionView.transform
        }
        return cell
    }
    
    public final override func configureCell(cell: UICollectionViewCell, decorationAttributes: ChatItemDecorationAttributesProtocol?) {
        guard let cell = cell as? CellT else {
            assert(false, "Invalid cell given to presenter")
            return
        }
        
        guard let decorationAttributes = decorationAttributes as? ChatItemDecorationAttributes else {
            assert(false, "Expecting decoration attributes")
            return
        }
        
        self.decorationAttributes = decorationAttributes
        self.configureCell(cell, decorationAttributes: decorationAttributes, animated: false, additionConfiguration: nil)
    }
    
    public override func heightForCell(maximumWidth width: CGFloat, decorationAttributes: ChatItemDecorationAttributesProtocol?) -> CGFloat {
        guard let attr = decorationAttributes as? ChatItemDecorationAttributes else {
            assert(false, "Expecting decoration attributes")
            return 0
        }
        configureCell(sizingCell, decorationAttributes: attr, animated: false, additionConfiguration: nil)
        return sizingCell.cellSizeThatFits(CGSize(width: width, height: CGFloat.max)).height
    }
    
    public override var canCalculateHeightInBackground: Bool {
        return sizingCell.canCalculateSizeInBackground
    }
    
    public override func shouldShowMenu() -> Bool {
        return false
    }
    
    // MARK: Convenience
    func createViewModel() -> ViewModelT {
        let viewModel = viewModelBuilder.createMessageViewModel(message: message)
        return viewModel
    }
    
    func configureCell(cell: CellT, decorationAttributes: ChatItemDecorationAttributes, animated: Bool, additionConfiguration: (() -> Void)?) {
        cell.performBatchUpdates({ () -> Void in
            cell.layoutCache = self.layoutCache
            cell.messageViewModel = self.messageViewModel
            
            additionConfiguration?()
        }, animated: false, completion: nil)
    }

}
