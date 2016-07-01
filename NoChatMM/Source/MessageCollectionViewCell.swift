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
        return imageFactory.createImage("BubbleIncoming")!
    }()
    
    lazy var outgoingBubble: UIImage = {
        return imageFactory.createImage("BubbleOutgoing")!
    }()
    
    lazy var failedIcon: UIImage = {
        return imageFactory.createImage("MessageUnsentButton")!
    }()
}

public struct MessageCelloctionViewCellLayoutConstants {
    let horizontalMargin: CGFloat = 8
    let horizontalInterspacing: CGFloat = 4
    let avatarSize = CGSize(width: 40, height: 40)
    let failedButtonSize = CGSize(width: 15, height: 15)
    let maxContainerWidthPercentageForBubbleView: CGFloat = 0.68
}

public class MessageCollectionViewCell<BubbleViewT where
    BubbleViewT: UIView,
    BubbleViewT: BubbleViewProtocol>: UICollectionViewCell, BackgroundSizingQueryable, UIGestureRecognizerDelegate
{
    
    static func sizingCell() -> MessageCollectionViewCell<BubbleViewT> {
        let cell = MessageCollectionViewCell<BubbleViewT>(frame: CGRect.zero)
        cell.viewContext = .Sizing
        return cell
    }
    
    var animationDuration: CFTimeInterval = 0.33
    var viewContext: ViewContext = .Normal {
        didSet {
            bubbleView.viewContext = viewContext
        }
    }
    
    private(set) var isUpdating: Bool = false
    func performBatchUpdates(updateClosure: () -> Void, animated: Bool, completion: (() -> ())?) {
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
            UIView.animateWithDuration(self.animationDuration,
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
            
            // bind status property
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
    
    public override var selected: Bool {
        didSet {
            if oldValue != self.selected {
                self.updateViews()
            }
            bubbleView.selected = selected
        }
    }
    
    var layoutCache: NSCache!
    
    var layoutConstants = MessageCelloctionViewCellLayoutConstants() {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    public var canCalculateSizeInBackground: Bool {
        return self.bubbleView.canCalculateSizeInBackground
    }
    
    private(set) var bubbleView: BubbleViewT!
    func createBubbleView() -> BubbleViewT! {
        return BubbleViewT()
    }
    
    private lazy var avatarImageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    private lazy var failedButton: UIButton = {
        let button = UIButton(type: .Custom)
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
        contentView.addSubview(avatarImageView)
        contentView.addSubview(failedButton)
        contentView.exclusiveTouch = true // avoid multi events response
        exclusiveTouch = true
    }
    
    // MARK: View model binding
    final private func updateViews() {
        if viewContext == .Sizing { return }
        if isUpdating { return }
        guard let viewModel = messageViewModel else { return }
        
        updateStatusViews()
        
        avatarImageView.image = nil
        viewModel.getAvatar { [weak self] (result) -> Void in
            guard let sSelf = self else { return }
            
            if let avatar = result where avatar != sSelf.avatarImageView.image {
                sSelf.avatarImageView.image = avatar
            }
        }
        
        setNeedsLayout()
    }
    
    final private func updateStatusViews() {
        guard let viewModel = messageViewModel else { return }
        if viewModel.isIncoming {
            failedButton.alpha = 0
        } else {
            switch viewModel.status.value {
            case .Sending, .Success:
                failedButton.alpha = 0
            case .Failure:
                failedButton.setImage(cellStyle.failedIcon, forState: .Normal)
                failedButton.alpha = 1
            }
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutModel = calculateLayout(availableWidth: contentView.bounds.width)
        
        UIView.performWithoutAnimation {
            self.avatarImageView.ntg_rect = layoutModel.avatarViewFrame
            self.failedButton.ntg_rect = layoutModel.failedViewFrame
            self.bubbleView.ntg_rect = layoutModel.bubbleViewFrame
            self.bubbleView.preferredMaxLayoutWidth = layoutModel.preferredMaxWidthForBubble
            self.bubbleView.layoutIfNeeded()
        }
    }
    
    public func cellSizeThatFits(size: CGSize) -> CGSize {
        if size.width == 0 { // TODO: find out why
            return size
        }
        
        return calculateLayout(availableWidth: size.width).size
    }
    
    private func calculateLayout(availableWidth availableWidth: CGFloat) -> MessageLayoutModel {
        
        let cacheKey = messageViewModel.message.msgId
        
        if let layoutModel = layoutCache.objectForKey(cacheKey) as? MessageLayoutModel where layoutModel.size.width == availableWidth {
            return layoutModel
        }
        
        let parameters = MessageLayoutModelParameters(
            containerWidth: availableWidth,
            horizontalMargin: layoutConstants.horizontalMargin,
            horizontalInterspacing: layoutConstants.horizontalInterspacing,
            avatarImageViewSize: layoutConstants.avatarSize,
            failedButtonSize: layoutConstants.failedButtonSize,
            maxContainerWidthPercentageForBubbleView: layoutConstants.maxContainerWidthPercentageForBubbleView,
            bubbleView: bubbleView,
            isIncoming: messageViewModel.isIncoming
        )
        
        let layoutModel = MessageLayoutModel()
        layoutModel.calculateLayout(parameters: parameters)
        
        layoutCache.setObject(layoutModel, forKey: cacheKey)
        
        return layoutModel
    }
    
    // http://stackoverflow.com/questions/22451793/setcollectionviewlayoutanimated-causing-debug-error-snapshotting-a-view-that-h
    public override func snapshotViewAfterScreenUpdates(afterUpdates: Bool) -> UIView {
        UIGraphicsBeginImageContext(bounds.size)
        
        drawRect(bounds)
        
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let snapshotImageView = UIImageView(frame: bounds)
        snapshotImageView.image = snapshotImage
        
        return snapshotImageView
    }
}

final class MessageLayoutModel {
    private (set) var size = CGSize.zero
    private (set) var failedViewFrame = CGRect.zero
    private (set) var avatarViewFrame = CGRect.zero
    private (set) var bubbleViewFrame = CGRect.zero
    private (set) var preferredMaxWidthForBubble: CGFloat = 0
    
    func calculateLayout(parameters parameters: MessageLayoutModelParameters) {
        let containerWidth = parameters.containerWidth
        let isIncoming = parameters.isIncoming
        let avatarSize = parameters.avatarImageViewSize
        let failedButtonSize = parameters.failedButtonSize
        let bubbleView = parameters.bubbleView
        let horizontalMargin = parameters.horizontalMargin
        let horizontalInterspacing = parameters.horizontalInterspacing
        
        let preferredWidthForBubble: CGFloat = containerWidth * parameters.maxContainerWidthPercentageForBubbleView
        
        let bubbleSize = bubbleView.bubbleSizeThatFits(CGSize(width: preferredWidthForBubble, height: CGFloat.max))
        
        let bubbleHeight = max(bubbleSize.height, avatarSize.height)
        
        let containerRect = CGRect(origin: CGPoint.zero, size: CGSize(width: containerWidth, height: bubbleHeight))
        
        avatarViewFrame = avatarSize.ntg_rect(inContainer: containerRect, xAlignament: .Center, yAlignment: .Top, dx: 0, dy: 0)
        
        bubbleViewFrame = bubbleSize.ntg_rect(inContainer: containerRect, xAlignament: .Center, yAlignment: .Center, dx: 0, dy: 0)
        failedViewFrame = failedButtonSize.ntg_rect(inContainer: containerRect, xAlignament: .Center, yAlignment: .Center, dx: 0, dy: 0)
        
        // Adjust horizontal positions
        
        var currentX: CGFloat = 0
        if isIncoming {
            
            currentX = horizontalMargin
            avatarViewFrame.origin.x = currentX
            
            currentX += avatarSize.width
            currentX += horizontalInterspacing
            bubbleViewFrame.origin.x = currentX
            
        } else {
            
            currentX = containerRect.maxX - horizontalMargin
            currentX -= avatarSize.width
            avatarViewFrame.origin.x = currentX
            
            currentX -= horizontalInterspacing
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
    let maxContainerWidthPercentageForBubbleView: CGFloat // in [0, 1]
    let bubbleView: BubbleViewProtocol
    let isIncoming: Bool
}