//
//  TextBubbleView.swift
//  NoChat
//
//  Created by little2s on 16/3/19.
//  Copyright © 2016年 Ninty. All rights reserved.
//

import UIKit

// MARK: TextBubbleViewStyle
public protocol TextBubbleViewStyleProtocol {
    func bubbleImage(viewModel viewModel: TextMessageViewModelProtocol, isSelected: Bool) -> UIImage
    func textFont(viewModel viewModel: TextMessageViewModelProtocol, isSelected: Bool) -> UIFont
    func textColor(viewModel viewModel: TextMessageViewModelProtocol, isSelected: Bool) -> UIColor
    func textInsets(viewModel viewModel: TextMessageViewModelProtocol, isSelected: Bool) -> UIEdgeInsets
    func linkAttributes(viewModel viewModel: TextMessageViewModelProtocol, isSelected: Bool) -> [String: AnyObject]
}

public class TextBubbleViewStyle: TextBubbleViewStyleProtocol {
    public init() {}
    
    lazy var baseStyle = MessageCollectionViewCellStyle()
    
    // TODO: solve unknown select with text link
    let blendBubbleColor = UIColor.blackColor().colorWithAlphaComponent(0.15)
    lazy var selectedIncomingBubble: UIImage = {
        return self.baseStyle.incomingBubble
    }()
    lazy var selectedOugoingBubble: UIImage = {
        return self.baseStyle.outgoingBubble
    }()
    
    lazy var incomingLinkAttributes:[String : AnyObject] = {
        return [
            NSForegroundColorAttributeName: UIColor.blueColor(),
            NSUnderlineStyleAttributeName : NSUnderlineStyle.StyleSingle.rawValue
        ]
    }()
    lazy var outgoingLinkAttributes:[String : AnyObject] = {
        return [
            NSForegroundColorAttributeName: UIColor.blueColor(),
            NSUnderlineStyleAttributeName : NSUnderlineStyle.StyleSingle.rawValue
        ]
    }()
    
    let incomingTextInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 12)
    let outgoingTextInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 20)
    
    let font = UIFont.systemFontOfSize(16)
    public func textFont(viewModel viewModel: TextMessageViewModelProtocol, isSelected: Bool) -> UIFont {
        return font
    }
    
    public func textColor(isIncoming: Bool) -> UIColor {
        return UIColor.blackColor()
    }
    
    public func textColor(viewModel viewModel: TextMessageViewModelProtocol, isSelected: Bool) -> UIColor {
        return UIColor.blackColor()
    }
    
    public func textInsets(viewModel viewModel: TextMessageViewModelProtocol, isSelected: Bool) -> UIEdgeInsets {
        return viewModel.isIncoming ? incomingTextInsets : outgoingTextInsets
    }
    
    public func bubbleImage(viewModel viewModel: TextMessageViewModelProtocol, isSelected: Bool) -> UIImage {
        var image: UIImage
        
        if isSelected {
            image = viewModel.isIncoming ? selectedIncomingBubble : selectedOugoingBubble
        } else {
            image = viewModel.isIncoming ? baseStyle.incomingBubble : baseStyle.outgoingBubble
        }
        
        return image
    }
    
    public func linkAttributes(viewModel viewModel: TextMessageViewModelProtocol, isSelected: Bool) -> [String : AnyObject] {
        if viewModel.isIncoming {
            return incomingLinkAttributes
        } else {
            return outgoingLinkAttributes
        }
    }
    
    lazy var deliveredIcon: UIImage = {
        return imageFactory.createImage("MessageCheckmark1")!
    }()
    
    private lazy var dateFont = {
        return UIFont.italicSystemFontOfSize(11)
    }()
    
    private lazy var outgoingDateColor = {
        return UIColor(red: 59/255.0, green: 171/255.0, blue: 61/255.0, alpha: 1)
    }()
    
    private lazy var incommingDateColor = {
        return UIColor.lightGrayColor()
    }()
    
    func attribuedStringForDate(date: String, isIncomming: Bool) -> NSAttributedString {
        let dateColor = isIncomming ? incommingDateColor : outgoingDateColor
        let attributes = [
            NSFontAttributeName: dateFont,
            NSForegroundColorAttributeName: dateColor
        ]
        return NSAttributedString(string: date, attributes: attributes)
    }
}

// MARK: TextBubbleView
public class TextBubbleView: UIView, BubbleViewProtocol, UITextViewDelegate {
    
    public static var bubbleIdentifier: String {
        return "TextBubble"
    }
    
    public var preferredMaxLayoutWidth: CGFloat = 0
    var animationDuration: CFTimeInterval = 0.33
    public var viewContext: ViewContext = .Normal {
        didSet {
            if viewContext == .Sizing {
                textView.dataDetectorTypes = .None
                textView.selectable = false
            } else {
                textView.dataDetectorTypes = [.Link]
                textView.selectable = true
            }
        }
    }
    
    let style = TextBubbleViewStyle()
    
    public var messageViewModel: MessageViewModelProtocol! {
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
    
    public var selected: Bool = false {
        didSet {
            if oldValue != self.selected {
                updateViews()
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        self.addSubview(bubbleImageView)
        self.addSubview(textView)
        self.addSubview(timeLabel)
        self.addSubview(deliveringView)
        self.addSubview(deliveredView)
        
        textView.delegate = self
    }
    
    private lazy var bubbleImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private var textView: UITextView = {
        let textView = ChatTextView()
        textView.backgroundColor = UIColor.clearColor()
        textView.editable = false
        textView.selectable = true
        textView.dataDetectorTypes = [.Link]
        textView.scrollsToTop = false
        textView.scrollEnabled = false
        textView.bounces = false
        textView.bouncesZoom = false
        textView.showsHorizontalScrollIndicator = false
        textView.showsVerticalScrollIndicator = false
        textView.layoutManager.allowsNonContiguousLayout = true
        textView.exclusiveTouch = true
        textView.textContainerInset = UIEdgeInsetsZero
        textView.textContainer.lineFragmentPadding = 0
        return textView
    }()
    
    private var timeLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private lazy var deliveringView: ClockProgressView = {
        let view = ClockProgressView()
        return view
    }()
    
    private lazy var deliveredView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    private(set) var isUpdating: Bool = false
    public func performBatchUpdates(updateClosure: () -> Void, animated: Bool, completion: (() -> Void)?) {
        isUpdating = true
        let updateAndRefreshViews = {
            updateClosure()
            self.isUpdating = false
            self.updateViews()
            if animated {
                self.layoutIfNeeded()
            }
        }
        if animated {
            UIView.animateWithDuration(animationDuration, animations: updateAndRefreshViews, completion: { (finished) -> Void in
                completion?()
            })
        } else {
            updateAndRefreshViews()
        }
    }
    
    func updateViews() {
        if viewContext == .Sizing { return }
        if isUpdating { return }
        guard let viewModel = messageViewModel as? TextMessageViewModel else { return }
        let textColor = style.textColor(viewModel: viewModel, isSelected: selected)
        let bubbleImage = style.bubbleImage(viewModel: viewModel, isSelected: selected)
        let linkAttributes = style.linkAttributes(viewModel: viewModel, isSelected: selected)
        
        if !textView.attributedText.isEqualToAttributedString(viewModel.attributedText)  {
            textView.attributedText = viewModel.attributedText
        }
        
        let linkTextColor = textView.linkTextAttributes[NSForegroundColorAttributeName] as! UIColor
        if linkTextColor != textColor {
            textView.linkTextAttributes = linkAttributes
        }
        
        if bubbleImageView.image != bubbleImage {
            bubbleImageView.image = bubbleImage
        }
        
        updateStatusViews()
        
        timeLabel.attributedText = style.attribuedStringForDate(viewModel.date, isIncomming: viewModel.isIncoming)
        setNeedsLayout()
    }
    
    final private func updateStatusViews() {
        guard let viewModel = messageViewModel else { return }
        
        
        
        if viewModel.isIncoming {
            deliveringView.alpha = 0
            deliveredView.alpha = 0
        } else {
            switch viewModel.status.value {
            case .Sending:
                deliveringView.startAnimating()
                deliveringView.alpha = 1
                deliveredView.alpha = 0
            case .Success:
                deliveredView.image = style.deliveredIcon
                deliveredView.alpha = 1
                deliveringView.alpha = 0
            case .Failure:
                deliveredView.alpha = 0
                deliveringView.alpha = 0
            }
        }
    }
    
//    public override func sizeThatFits(size: CGSize) -> CGSize {
//        return calculateTextBubbleLayout(preferredMaxLayoutWidth: size.width).size
//    }
    
    public func bubbleSizeThatFits(size: CGSize) -> CGSize {
        return calculateTextBubbleLayout(preferredMaxLayoutWidth: size.width).size
    }
    
    // MARK:  Layout
    public override func layoutSubviews() {
        super.layoutSubviews()
        let layout = calculateTextBubbleLayout(preferredMaxLayoutWidth: preferredMaxLayoutWidth)
        textView.ntg_rect = layout.textFrame
        bubbleImageView.ntg_rect = layout.bubbleFrame
        timeLabel.frame = layout.timeLabelFrame
        deliveringView.frame = layout.deliveringViewFrame
        deliveredView.frame = layout.deliveredViewFrame
    }
    
    private func calculateTextBubbleLayout(preferredMaxLayoutWidth preferredMaxLayoutWidth: CGFloat) -> TextBubbleLayoutModel {
        guard let viewModel = messageViewModel as? TextMessageViewModel else {
            fatalError("View model not match!")
        }
        
        let layoutContext = TextBubbleLayoutModel.LayoutContext(
            attributedText: viewModel.attributedText,
            font: style.textFont(viewModel: viewModel, isSelected: selected),
            textInsets: style.textInsets(viewModel: viewModel, isSelected: selected),
            preferredMaxLayoutWidth: preferredMaxLayoutWidth,
            timeLabelSize: CGSize(width: 32, height: 14),
            deliveringViewSize: CGSize(width: 15, height: 15),
            isIncoming: viewModel.isIncoming
        )
        
        let layoutModel = TextBubbleLayoutModel(layoutContext: layoutContext)
        layoutModel.calculateLayout()
        
        return layoutModel
    }
    
    public var canCalculateSizeInBackground: Bool {
        return true
    }
    
    // MARK: UITextViewDelegate
    public func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        guard let viewModel = messageViewModel as? TextMessageViewModel else {
            fatalError("View model not match!")
        }
        
        viewModel.didTapURL(URL, bubbleView: self)
        
        return false
    }
}

// MARK: Layout model
private final class TextBubbleLayoutModel {
    let layoutContext: LayoutContext
    var textFrame: CGRect = CGRect.zero
    var timeLabelFrame: CGRect = CGRect.zero
    var deliveredViewFrame: CGRect = CGRect.zero
    var deliveringViewFrame: CGRect = CGRect.zero
    var bubbleFrame: CGRect = CGRect.zero
    var size: CGSize = CGSize.zero
    
    init(layoutContext: LayoutContext) {
        self.layoutContext = layoutContext
    }
    
    class LayoutContext {
        let attributedText: NSAttributedString
        let font: UIFont
        let textInsets: UIEdgeInsets
        let preferredMaxLayoutWidth: CGFloat
        let timeLabelSize: CGSize
        let deliveringViewSize: CGSize
        let isIncoming: Bool
        init (attributedText: NSAttributedString, font: UIFont, textInsets: UIEdgeInsets, preferredMaxLayoutWidth: CGFloat, timeLabelSize: CGSize, deliveringViewSize: CGSize, isIncoming: Bool) {
            self.font = font
            self.attributedText = attributedText
            self.textInsets = textInsets
            self.preferredMaxLayoutWidth = preferredMaxLayoutWidth
            self.timeLabelSize = timeLabelSize
            self.deliveringViewSize = deliveringViewSize
            self.isIncoming = isIncoming
        }
    }
    
    func calculateLayout() {
        let timeLabelSize = layoutContext.timeLabelSize
        let deliveringViewSize = layoutContext.isIncoming ? CGSize.zero : layoutContext.deliveringViewSize
        
        
        let textHorizontalInset = layoutContext.textInsets.ntg_horziontalInset
        let textVerticalInset = layoutContext.textInsets.ntg_verticalInset
        let additonWidth = deliveringViewSize.width + timeLabelSize.width
        
        var maxTextWidth = layoutContext.preferredMaxLayoutWidth - textHorizontalInset - additonWidth - 8
        var textSize = textSizeThatFitsWidth(maxTextWidth)
        
        var bubbleSize: CGSize
        
        if textSize.height > 25 { // recalculate
            maxTextWidth = layoutContext.preferredMaxLayoutWidth - textHorizontalInset
            textSize = textSizeThatFitsWidth(maxTextWidth)
            bubbleSize = textSize.ntg_outsetBy(dx: textHorizontalInset, dy: textVerticalInset)
        } else {
            bubbleSize = CGSize(width: textHorizontalInset + textSize.width + 8 + additonWidth, height: textSize.height + textVerticalInset)
        }
        
        
        bubbleFrame = CGRect(origin: CGPoint.zero, size: bubbleSize)
        textFrame = UIEdgeInsetsInsetRect(bubbleFrame, layoutContext.textInsets)
        deliveringViewFrame = CGRect(
            x: bubbleFrame.maxX - layoutContext.textInsets.right - deliveringViewSize.width,
            y: bubbleFrame.maxY - layoutContext.textInsets.bottom - deliveringViewSize.height,
            width: deliveringViewSize.width,
            height: deliveringViewSize.height
        )
        timeLabelFrame = CGRect(
            x: deliveringViewFrame.minX - timeLabelSize.width,
            y: bubbleFrame.maxY - layoutContext.textInsets.bottom - timeLabelSize.height,
            width: timeLabelSize.width,
            height: timeLabelSize.height
        )
        
        deliveredViewFrame = deliveringViewFrame
        
        size = bubbleSize
    }
    
    private func textSizeThatFitsWidth(width: CGFloat) -> CGSize {
        return layoutContext.attributedText.boundingRectWithSize(
            CGSize(width: width, height: CGFloat.max),
            options: [.UsesLineFragmentOrigin, .UsesFontLeading],
            context: nil
            ).size.ntg_round()
    }
}

extension TextBubbleLayoutModel.LayoutContext: Equatable, Hashable {
    var hashValue: Int {
        get {
            return attributedText.string.hashValue ^ textInsets.ntg_hashValue ^ preferredMaxLayoutWidth.hashValue ^ font.hashValue
        }
    }
}

private func == (lhs: TextBubbleLayoutModel.LayoutContext, rhs: TextBubbleLayoutModel.LayoutContext) -> Bool {
    return lhs.attributedText.string == rhs.attributedText.string &&
        lhs.textInsets == rhs.textInsets &&
        lhs.font == rhs.font &&
        lhs.preferredMaxLayoutWidth == rhs.preferredMaxLayoutWidth
}


