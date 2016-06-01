//
//  MessageCollectionViewCell.swift
//  NoChat
//
//  Created by little2s on 16/3/17.
//  Copyright © 2016年 Ninty. All rights reserved.
//

import UIKit
import NoChat

public struct MessageCelloctionViewCellLayoutConstants {
    let horizontalMargin: CGFloat = 16
    let horizontalInterspacing: CGFloat = 16
    let verticalMargin: CGFloat = 2
    let verticalInterspacing: CGFloat = 4
    let avatarSize = CGSize(width: 38, height: 38)
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
        didSet {
            updateViews()
            bubbleView.messageViewModel = messageViewModel
            
            guard let viewModel = messageViewModel else { return }
            nameLabel.text = viewModel.message.senderId
            dateLabel.text = viewModel.date
        }
    }
    
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
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        
        let font: UIFont
        if #available(iOS 8.2, *) {
            font = UIFont.systemFontOfSize(16, weight: UIFontWeightMedium)
        } else {
            font = UIFont(name: "HelveticaNeue-Medium", size: 16)!
        }
        
        label.font = font
        label.textColor = UIColor.blackColor()
        
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(13)
        label.textColor = UIColor.lightGrayColor()
        return label
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
        
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(bubbleView)
        contentView.exclusiveTouch = true // avoid multi events response
        exclusiveTouch = true
    }
    
    // MARK: View model binding
    final private func updateViews() {
        if viewContext == .Sizing { return }
        if isUpdating { return }
        guard let viewModel = messageViewModel else { return }
        
        avatarImageView.image = nil
        viewModel.getAvatar { [weak self] (result) -> Void in
            guard let sSelf = self else { return }
            
            if let avatar = result where avatar != sSelf.avatarImageView.image {
                sSelf.avatarImageView.image = avatar
            }
        }
        
        setNeedsLayout()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutModel = calculateLayout(availableWidth: contentView.bounds.width)
        
        UIView.performWithoutAnimation {
            self.avatarImageView.frame = layoutModel.avatarViewFrame
            self.nameLabel.frame = layoutModel.nameLabelFrame
            self.dateLabel.frame = layoutModel.dateLabelFrame
            self.bubbleView.frame = layoutModel.bubbleViewFrame
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
        
        if let layoutModel = layoutCache.objectForKey(cacheKey) as? MessageLayoutModel{
            return layoutModel
        }
        
        let parameters = MessageLayoutModelParameters(
            containerWidth: availableWidth,
            horizontalMargin: layoutConstants.horizontalMargin,
            horizontalInterspacing: layoutConstants.horizontalInterspacing,
            verticalMargin: layoutConstants.verticalMargin,
            verticalInterspacing: layoutConstants.verticalInterspacing,
            avatarImageViewSize: layoutConstants.avatarSize,
            bubbleView: bubbleView,
            nameLabel: nameLabel,
            dateLabel: dateLabel
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
    private (set) var avatarViewFrame = CGRect.zero
    private (set) var nameLabelFrame = CGRect.zero
    private (set) var dateLabelFrame = CGRect.zero
    private (set) var bubbleViewFrame = CGRect.zero
    private (set) var preferredMaxWidthForBubble: CGFloat = 0
    
    func calculateLayout(parameters parameters: MessageLayoutModelParameters) {
        let containerWidth = parameters.containerWidth
        let avatarSize = parameters.avatarImageViewSize
        let bubbleView = parameters.bubbleView
        let nameLabel = parameters.nameLabel
        let dateLabel = parameters.dateLabel
        let horizontalMargin = parameters.horizontalMargin
        let horizontalInterspacing = parameters.horizontalInterspacing
        let verticalMargin = parameters.verticalMargin
        let verticalInterspacing = parameters.verticalInterspacing
        
        let preferredWidthForBubble: CGFloat = containerWidth - horizontalMargin * 2 - horizontalInterspacing - avatarSize.width
        
        let bubbleSize = bubbleView.bubbleSizeThatFits(CGSize(width: preferredWidthForBubble, height: CGFloat.max))
        
        let nameSize = nameLabel.sizeThatFits(CGSize(width: preferredWidthForBubble, height: 21))
        
        let dateSize = dateLabel.sizeThatFits(CGSize(width: preferredWidthForBubble, height: 21))
        
        let cellHeight = max(2 * verticalMargin + nameSize.height + verticalInterspacing + bubbleSize.height, avatarSize.height)
        
        let containerRect = CGRect(origin: CGPoint.zero, size: CGSize(width: containerWidth, height: cellHeight))
        
        avatarViewFrame = CGRect(
            x: horizontalMargin,
            y: verticalMargin,
            width: avatarSize.width,
            height: avatarSize.height
        )
        
        nameLabelFrame = CGRect(
            x: avatarViewFrame.maxX + horizontalInterspacing,
            y: verticalMargin,
            width: nameSize.width,
            height: nameSize.height
        )
        
        dateLabelFrame = CGRect(
            x: nameLabelFrame.maxX + horizontalMargin - 6,
            y: verticalMargin + 2,
            width: dateSize.width,
            height: dateSize.height
        )
        
        bubbleViewFrame = CGRect(
            x: nameLabelFrame.minX,
            y: nameLabelFrame.maxY + verticalInterspacing,
            width: avatarSize.width,
            height: avatarSize.height
        )
        
        size = containerRect.size
        preferredMaxWidthForBubble = preferredWidthForBubble
    }
}

struct MessageLayoutModelParameters {
    let containerWidth: CGFloat
    let horizontalMargin: CGFloat
    let horizontalInterspacing: CGFloat
    let verticalMargin: CGFloat
    let verticalInterspacing: CGFloat
    let avatarImageViewSize: CGSize
    let bubbleView: BubbleViewProtocol
    let nameLabel: UILabel
    let dateLabel: UILabel
}