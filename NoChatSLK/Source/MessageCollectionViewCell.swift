//
//  MessageCollectionViewCell.swift
//  NoChat
//
//  Created by little2s on 16/3/17.
//  Copyright © 2016年 Ninty. All rights reserved.
//

import UIKit
import NoChat

public struct MessageCellCollectionViewCellLayoutConstants {
    let horizontalMargin: CGFloat = 16
    let horizontalInterspacing: CGFloat = 16
    let verticalMargin: CGFloat = 2
    let verticalInterspacing: CGFloat = 4
    let avatarSize = CGSize(width: 38, height: 38)
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
        didSet {
            updateViews()
            bubbleView.messageViewModel = messageViewModel
            
            guard let viewModel = messageViewModel else { return }
            nameLabel.text = viewModel.message.senderId
            dateLabel.text = viewModel.date
        }
    }
    
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
    
    open var canCalculateSizeInBackground: Bool {
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
    
    fileprivate lazy var nameLabel: UILabel = {
        let label = UILabel()
        
        let font: UIFont
        if #available(iOS 8.2, *) {
            font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium)
        } else {
            font = UIFont(name: "HelveticaNeue-Medium", size: 16)!
        }
        
        label.font = font
        label.textColor = UIColor.black
        
        return label
    }()
    
    fileprivate lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.lightGray
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
        contentView.isExclusiveTouch = true // avoid multi events response
        isExclusiveTouch = true
    }
    
    // MARK: View model binding
    final fileprivate func updateViews() {
        if viewContext == .sizing { return }
        if isUpdating { return }
        guard let viewModel = messageViewModel else { return }
        
        avatarImageView.image = nil
        viewModel.getAvatar { [weak self] (result) -> Void in
            guard let sSelf = self else { return }
            
            if let avatar = result , avatar != sSelf.avatarImageView.image {
                sSelf.avatarImageView.image = avatar
            }
        }
        
        setNeedsLayout()
    }
    
    open override func layoutSubviews() {
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
    
    open func cellSizeThatFits(_ size: CGSize) -> CGSize {
        return calculateLayout(availableWidth: size.width).size
    }
    
    fileprivate func calculateLayout(availableWidth: CGFloat) -> MessageLayoutModel {
        
        let cacheKey = messageViewModel.message.msgId
        
        if let layoutModel = layoutCache.object(forKey: cacheKey as AnyObject) as? MessageLayoutModel , layoutModel.size.width == availableWidth {
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
        
        layoutCache.setObject(layoutModel, forKey: cacheKey as AnyObject)
        
        return layoutModel
    }
    
    // http://stackoverflow.com/questions/22451793/setcollectionviewlayoutanimated-causing-debug-error-snapshotting-a-view-that-h
    open override func snapshotView(afterScreenUpdates afterUpdates: Bool) -> UIView? {
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
    fileprivate (set) var avatarViewFrame = CGRect.zero
    fileprivate (set) var nameLabelFrame = CGRect.zero
    fileprivate (set) var dateLabelFrame = CGRect.zero
    fileprivate (set) var bubbleViewFrame = CGRect.zero
    fileprivate (set) var preferredMaxWidthForBubble: CGFloat = 0
    
    func calculateLayout(parameters: MessageLayoutModelParameters) {
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
        
        let bubbleSize = bubbleView.bubbleSizeThatFits(CGSize(width: preferredWidthForBubble, height: CGFloat.greatestFiniteMagnitude))
        
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
