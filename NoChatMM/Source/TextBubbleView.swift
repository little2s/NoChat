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
    
    let incomingTextInsets = UIEdgeInsets(top: 12, left: 18, bottom: 20, right: 14)
    let outgoingTextInsets = UIEdgeInsets(top: 12, left: 14, bottom: 20, right: 18)
    
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
        didSet {
            updateViews()
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
        
        setNeedsLayout()
    }
    
    public func bubbleSizeThatFits(size: CGSize) -> CGSize {
        return calculateTextBubbleLayout(preferredMaxLayoutWidth: size.width).size
    }
    
    // MARK:  Layout
    public override func layoutSubviews() {
        super.layoutSubviews()
        let layout = calculateTextBubbleLayout(preferredMaxLayoutWidth: preferredMaxLayoutWidth)
        textView.ntg_rect = layout.textFrame
        bubbleImageView.ntg_rect = layout.bubbleFrame
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
        let isIncoming: Bool
        init (attributedText: NSAttributedString, font: UIFont, textInsets: UIEdgeInsets, preferredMaxLayoutWidth: CGFloat, isIncoming: Bool) {
            self.font = font
            self.attributedText = attributedText
            self.textInsets = textInsets
            self.preferredMaxLayoutWidth = preferredMaxLayoutWidth
            self.isIncoming = isIncoming
        }
    }
    
    func calculateLayout() {
        let textHorizontalInset = layoutContext.textInsets.ntg_horziontalInset
        let textVerticalInset = layoutContext.textInsets.ntg_verticalInset
        
        let maxTextWidth = layoutContext.preferredMaxLayoutWidth - textHorizontalInset
        let textSize = textSizeThatFitsWidth(maxTextWidth)
        
        let bubbleSize = textSize.ntg_outsetBy(dx: textHorizontalInset, dy: textVerticalInset)

        bubbleFrame = CGRect(origin: CGPoint.zero, size: bubbleSize)
        textFrame = UIEdgeInsetsInsetRect(bubbleFrame, layoutContext.textInsets)
        
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


