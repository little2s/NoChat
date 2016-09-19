//
//  MessagePresenterBuilder.swift
//  NoChat
//
//  Created by little2s on 16/3/19.
//  Copyright © 2016年 Ninty. All rights reserved.
//

import UIKit
import NoChat

open class MessagePresenterBuilder<BubbleViewT, ViewModelBuilderT>: ChatItemPresenterBuilderProtocol where
    BubbleViewT: UIView,
    BubbleViewT: BubbleViewProtocol,
    ViewModelBuilderT: MessageViewModelBuilderProtocol
{
    typealias ModelT = MessageProtocol
    typealias ViewModelT = MessageViewModelProtocol
    
    let viewModelBuilder: ViewModelBuilderT
    let layoutCache: NSCache<AnyObject, AnyObject>
    
    lazy var sizingCell: MessageCollectionViewCell<BubbleViewT> = {
        var cell: MessageCollectionViewCell<BubbleViewT>? = nil
        
        dispatch_sync_safely_to_main_queue {
            cell = MessageCollectionViewCell<BubbleViewT>.sizingCell()
        }
        
        return cell!
    }()
    
    public init(viewModelBuilder: ViewModelBuilderT, layoutCache: NSCache<AnyObject, AnyObject>) {
        self.viewModelBuilder = viewModelBuilder
        self.layoutCache = layoutCache
    }
    
    // MARK: ChatItemPresenterBuilderProtocol
    public func canHandleChatItem(_ chatItem: ChatItemProtocol) -> Bool {
        return chatItem is MessageProtocol ? true : false
    }
    
    public func createPresenterWithChatItem(_ chatItem: ChatItemProtocol) -> ChatItemPresenterProtocol {
        assert(self.canHandleChatItem(chatItem))
        return MessagePresenter<BubbleViewT, ViewModelBuilderT>(
            message: chatItem as! ModelT,
            sizingCell: sizingCell,
            viewModelBuilder: viewModelBuilder,
            layoutCache: layoutCache
        )
    }
    
    public var presenterType: ChatItemPresenterProtocol.Type {
        return MessagePresenter<BubbleViewT, ViewModelBuilderT>.self
    }
}
