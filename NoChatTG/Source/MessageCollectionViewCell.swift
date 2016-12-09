//
//  MessageCollectionViewCell.swift
//  NoChat
//
//  Created by little2s on 16/3/17.
//  Copyright © 2016年 Ninty. All rights reserved.
//

import UIKit
import NoChat

public struct MessageCollectionViewCellStyle {
    lazy var incomingBubble: UIImage = {
        return imageFactory.createImage("BubbleIncomingFull")!
    }()
    
    lazy var outgoingBubble: UIImage = {
        return imageFactory.createImage("BubbleOutgoingFull")!
    }()
    
    lazy var failedIcon: UIImage = {
        return imageFactory.createImage("MessageUnsentButton")!
    }()
}

public struct MessageCellCollectionViewCellLayoutConstants {
    let horizontalMargin: CGFloat = 2
    let horizontalInterspacing: CGFloat = 4
    let avatarSize = CGSize(width: 34, height: 34)
    let failedButtonSize = CGSize(width: 15, height: 15)
    let maxContainerWidthPercentageForBubbleViewHasAvatar: CGFloat = 0.68
    let maxContainerWidthPercentageForBubbleViewNoAvatar: CGFloat = 0.75
}

open class MessageCollectionViewCell<BubbleViewT>: UICollectionViewCell, BackgroundSizingQueryable, UIGestureRecognizerDelegate where
    BubbleViewT: UIView,
    BubbleViewT: BubbleViewProtocol
{
    
    static func sizingCell() -> MessageCollectionViewCell<BubbleViewT> {
        let cell = MessageCollectionViewCell<BubbleViewT>(frame: CGRect.zero)
        cell.viewContext = .sizing
        return cell
    }
    
    public var showAvatar: Bool = false
    
    var animationDuration: CFTimeInterval = 0.33
    var viewContext: ViewContext = .normal {
        didSet {
            bubbleView.viewContext = viewContext
        }
    }
    
    fileprivate(set) var isUpdating: Bool = false
    func performBatchUpdates(_ updateClosure: @escaping () -> Void, animated: Bool, completion: (() -> ())?) {
        self.isUpdating = true
        let updateAndRefreshViews = {
            updateClosure()
            self.isUpdating = false
            self.updateViews()
            if animated {
                self.layoutIfNeeded()
            }
        }
        if animated {
            UIView.animate(withDuration: self.animationDuration,
                animations: updateAndRefreshViews,
                completion: { (finished) -> Void in
                    completion?()
            })
        } else {
            updateAndRefreshViews()
        }
    }
    
    var messageViewModel: MessageViewModelProtocol! {
        willSet {
            if messageViewModel !== newValue {
                guard let viewModel = messageViewModel as? DecoratedMessageViewModelProtocol else {
                    return
                }
                viewModel.messageViewModel.status.removeObserver(self)
            }
        }
        didSet {
            updateViews()
            bubbleView.messageViewModel = messageViewModel
            guard let viewModel = messageViewModel as? DecoratedMessageViewModelProtocol else {
                return
            }
            viewModel.messageViewModel.status.observe(self) { [weak self] (old, new) in
                guard let sSelf = self else { return }
                if old != new {
                    sSelf.updateStatusViews()
                }
            }
        }
    }
    
    var cellStyle = MessageCollectionViewCellStyle()
    
    open override var isSelected: Bool {
        didSet {
            if oldValue != self.isSelected {
                self.updateViews()
            }
            bubbleView.selected = isSelected
        }
    }
    
    var layoutCache: NSCache<AnyObject, AnyObject>!
    
    var layoutConstants = MessageCellCollectionViewCellLayoutConstants() {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    public var canCalculateSizeInBackground: Bool {
        return self.bubbleView.canCalculateSizeInBackground
    }
    
    fileprivate(set) var bubbleView: BubbleViewT!
    func createBubbleView() -> BubbleViewT! {
        return BubbleViewT()
    }
    
    fileprivate lazy var avatarImageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    fileprivate lazy var failedButton: UIButton = {
        let button = UIButton(type: .custom)
        return button
    }()
    
    // MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        bubbleView = createBubbleView()
        
        contentView.addSubview(bubbleView)
        if showAvatar {
            contentView.addSubview(avatarImageView)
        }
        contentView.addSubview(failedButton)
        contentView.isExclusiveTouch = true // avoid multi events response
        isExclusiveTouch = true
    }
    
    // MARK: View model binding
    final fileprivate func updateViews() {
        if viewContext == .sizing { return }
        if isUpdating { return }
        guard let viewModel = messageViewModel else { return }
        
        updateStatusViews()
        
        if showAvatar {
        
            avatarImageView.image = nil
            viewModel.getAvatar { [weak self] (result) -> Void in
                guard let sSelf = self else { return }
                
                if let avatar = result, avatar != sSelf.avatarImageView.image {
                    sSelf.avatarImageView.image = avatar
                }
            }
            
        }
        
        setNeedsLayout()
    }
    
    final fileprivate func updateStatusViews() {
        guard let viewModel = messageViewModel else { return }
        if viewModel.isIncoming {
            failedButton.alpha = 0
        } else {
            switch viewModel.status.value {
            case .sending, .success:
                failedButton.alpha = 0
            case .failure:
                failedButton.setImage(cellStyle.failedIcon, for: .normal)
                failedButton.alpha = 1
            }
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutModel = calculateLayout(contentView.bounds.width)
        
        UIView.performWithoutAnimation {
            if self.showAvatar {
                self.avatarImageView.ntg_rect = layoutModel.avatarViewFrame
            }
            self.failedButton.ntg_rect = layoutModel.failedViewFrame
            self.bubbleView.ntg_rect = layoutModel.bubbleViewFrame
            self.bubbleView.preferredMaxLayoutWidth = layoutModel.preferredMaxWidthForBubble
            self.bubbleView.layoutIfNeeded()
        }
    }
    
    public func cellSizeThatFits(_ size: CGSize) -> CGSize {
        return calculateLayout(size.width).size
    }
    
    fileprivate func calculateLayout(_ availableWidth: CGFloat) -> MessageLayoutModel {
        
        let cacheKey = messageViewModel.message.msgId
        assert(layoutCache != nil, "layoutcache must not be nil")
        if let layoutModel = layoutCache.object(forKey: cacheKey as AnyObject) as? MessageLayoutModel , layoutModel.size.width == availableWidth {
                return layoutModel
        }
        
        let parameters = MessageLayoutModelParameters(
            containerWidth: availableWidth,
            horizontalMargin: layoutConstants.horizontalMargin,
            horizontalInterspacing: layoutConstants.horizontalInterspacing,
            avatarImageViewSize: layoutConstants.avatarSize,
            failedButtonSize: layoutConstants.failedButtonSize,
            maxContainerWidthPercentageForBubbleViewNoAvatar: layoutConstants.maxContainerWidthPercentageForBubbleViewNoAvatar,
            maxContainerWidthPercentageForBubbleViewHasAvatar: layoutConstants.maxContainerWidthPercentageForBubbleViewHasAvatar,
            bubbleView: bubbleView,
            isIncoming: messageViewModel.isIncoming,
            showAvatar: showAvatar
        )
        
        let layoutModel = MessageLayoutModel()
        layoutModel.calculateLayout(parameters)
        
        layoutCache.setObject(layoutModel, forKey: cacheKey as AnyObject)
        
        return layoutModel
    }
    
    // http://stackoverflow.com/questions/22451793/setcollectionviewlayoutanimated-causing-debug-error-snapshotting-a-view-that-h
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

final class MessageLayoutModel {
    fileprivate (set) var size = CGSize.zero
    fileprivate (set) var failedViewFrame = CGRect.zero
    fileprivate (set) var avatarViewFrame = CGRect.zero
    fileprivate (set) var bubbleViewFrame = CGRect.zero
    fileprivate (set) var preferredMaxWidthForBubble: CGFloat = 0
    
    func calculateLayout(_ parameters: MessageLayoutModelParameters) {
        let hasAvatar = parameters.showAvatar
        let containerWidth = parameters.containerWidth
        let isIncoming = parameters.isIncoming
        let avatarSize = parameters.avatarImageViewSize
        let failedButtonSize = parameters.failedButtonSize
        let bubbleView = parameters.bubbleView
        let horizontalMargin = parameters.horizontalMargin
        let horizontalInterspacing = parameters.horizontalInterspacing
        
        let preferredWidthForBubble: CGFloat
        if hasAvatar {
            preferredWidthForBubble = containerWidth * parameters.maxContainerWidthPercentageForBubbleViewHasAvatar
        } else {
            preferredWidthForBubble = containerWidth * parameters.maxContainerWidthPercentageForBubbleViewNoAvatar
        }
        
        let bubbleSize = bubbleView.bubbleSizeThatFits(CGSize(width: preferredWidthForBubble, height: CGFloat.greatestFiniteMagnitude))
        
        let bubbleHeight = max(bubbleSize.height, avatarSize.height)
        
        let containerRect = CGRect(origin: CGPoint.zero, size: CGSize(width: containerWidth, height: bubbleHeight))
        
        if hasAvatar {
            avatarViewFrame = avatarSize.ntg_rect(inContainer: containerRect, xAlignament: .center, yAlignment: .top, dx: 0, dy: 0)
        }
        
        bubbleViewFrame = bubbleSize.ntg_rect(inContainer: containerRect, xAlignament: .center, yAlignment: .center, dx: 0, dy: 0)
        failedViewFrame = failedButtonSize.ntg_rect(inContainer: containerRect, xAlignament: .center, yAlignment: .center, dx: 0, dy: 0)
        
        // Adjust horizontal positions
        
        var currentX: CGFloat = 0
        if isIncoming {
            currentX = horizontalMargin
            
            if hasAvatar {
                avatarViewFrame.origin.x = currentX
                currentX += avatarSize.width
                currentX += horizontalInterspacing
            }

            bubbleViewFrame.origin.x = currentX
            
            currentX += bubbleSize.width
            currentX += horizontalInterspacing
        } else {
            currentX = containerRect.maxX - horizontalMargin
            currentX -= bubbleSize.width

            bubbleViewFrame.origin.x = currentX
        }
        
        size = containerRect.size
        preferredMaxWidthForBubble = preferredWidthForBubble
    }
}

struct MessageLayoutModelParameters {
    let containerWidth: CGFloat
    let horizontalMargin: CGFloat
    let horizontalInterspacing: CGFloat
    let avatarImageViewSize: CGSize
    let failedButtonSize: CGSize
    let maxContainerWidthPercentageForBubbleViewNoAvatar: CGFloat // in [0, 1]
    let maxContainerWidthPercentageForBubbleViewHasAvatar: CGFloat
    let bubbleView: BubbleViewProtocol
    let isIncoming: Bool
    let showAvatar: Bool
}
