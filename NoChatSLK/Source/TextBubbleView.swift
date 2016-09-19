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
    func textFont(viewModel: TextMessageViewModelProtocol, isSelected: Bool) -> UIFont
    func textColor(viewModel: TextMessageViewModelProtocol, isSelected: Bool) -> UIColor
    func textInsets(viewModel: TextMessageViewModelProtocol, isSelected: Bool) -> UIEdgeInsets
    func linkAttributes(viewModel: TextMessageViewModelProtocol, isSelected: Bool) -> [String: Any]
}

open class TextBubbleViewStyle: TextBubbleViewStyleProtocol {
    public init() {}
    
    // TODO: solve unknown select with text link
    let blendBubbleColor = UIColor.black.withAlphaComponent(0.15)
    
    lazy var incomingLinkAttributes:[String : Any] = {
        return [
            NSForegroundColorAttributeName: UIColor.blue,
            NSUnderlineStyleAttributeName : NSUnderlineStyle.styleSingle.rawValue
        ]
    }()
    lazy var outgoingLinkAttributes:[String : Any] = {
        return [
            NSForegroundColorAttributeName: UIColor.blue,
            NSUnderlineStyleAttributeName : NSUnderlineStyle.styleSingle.rawValue
        ]
    }()
    
    let incomingTextInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    let outgoingTextInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    let font = UIFont.systemFont(ofSize: 16)
    open func textFont(viewModel: TextMessageViewModelProtocol, isSelected: Bool) -> UIFont {
        return font
    }
    
    open func textColor(_ isIncoming: Bool) -> UIColor {
        return UIColor.black
    }
    
    open func textColor(viewModel: TextMessageViewModelProtocol, isSelected: Bool) -> UIColor {
        return UIColor.black
    }
    
    open func textInsets(viewModel: TextMessageViewModelProtocol, isSelected: Bool) -> UIEdgeInsets {
        return viewModel.isIncoming ? incomingTextInsets : outgoingTextInsets
    }
    
    open func linkAttributes(viewModel: TextMessageViewModelProtocol, isSelected: Bool) -> [String : Any] {
        if viewModel.isIncoming {
            return incomingLinkAttributes
        } else {
            return outgoingLinkAttributes
        }
    }
    
}

// MARK: TextBubbleView
open class TextBubbleView: UIView, BubbleViewProtocol, UITextViewDelegate {
    
    open static var bubbleIdentifier: String {
        return "TextBubble"
    }
    
    open var preferredMaxLayoutWidth: CGFloat = 0
    var animationDuration: CFTimeInterval = 0.33
    open var viewContext: ViewContext = .normal {
        didSet {
            if viewContext == .sizing {
                textView.dataDetectorTypes = UIDataDetectorTypes()
                textView.isSelectable = false
            } else {
                textView.dataDetectorTypes = [.link]
                textView.isSelectable = true
            }
        }
    }
    
    let style = TextBubbleViewStyle()
    
    open var messageViewModel: MessageViewModelProtocol! {
        didSet {
            updateViews()
        }
    }
    
    open var selected: Bool = false {
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
    
    fileprivate func commonInit() {
        self.addSubview(textView)
        textView.delegate = self
    }
    
    fileprivate var textView: UITextView = {
        let textView = ChatTextView()
        textView.backgroundColor = UIColor.clear
        textView.isEditable = false
        textView.isSelectable = true
        textView.dataDetectorTypes = [.link]
        textView.scrollsToTop = false
        textView.isScrollEnabled = false
        textView.bounces = false
        textView.bouncesZoom = false
        textView.showsHorizontalScrollIndicator = false
        textView.showsVerticalScrollIndicator = false
        textView.layoutManager.allowsNonContiguousLayout = true
        textView.isExclusiveTouch = true
        textView.textContainerInset = UIEdgeInsets.zero
        textView.textContainer.lineFragmentPadding = 0
        return textView
    }()
    
    fileprivate(set) var isUpdating: Bool = false
    open func performBatchUpdates(_ updateClosure: @escaping () -> Void, animated: Bool, completion: (() -> Void)?) {
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
            UIView.animate(withDuration: animationDuration, animations: updateAndRefreshViews, completion: { (finished) -> Void in
                completion?()
            })
        } else {
            updateAndRefreshViews()
        }
    }
    
    func updateViews() {
        if viewContext == .sizing { return }
        if isUpdating { return }
        guard let viewModel = messageViewModel as? TextMessageViewModel else { return }
        let textColor = style.textColor(viewModel: viewModel, isSelected: selected)
        let linkAttributes = style.linkAttributes(viewModel: viewModel, isSelected: selected)
        
        if !textView.attributedText.isEqual(to: viewModel.attributedText)  {
            textView.attributedText = viewModel.attributedText
        }
        
        let linkTextColor = textView.linkTextAttributes[NSForegroundColorAttributeName] as! UIColor
        if linkTextColor != textColor {
            textView.linkTextAttributes = linkAttributes
        }
        
        setNeedsLayout()
    }
    
    open func bubbleSizeThatFits(_ size: CGSize) -> CGSize {
        return calculateTextBubbleLayout(preferredMaxLayoutWidth: size.width).size
    }
    
    // MARK:  Layout
    open override func layoutSubviews() {
        super.layoutSubviews()
        let layout = calculateTextBubbleLayout(preferredMaxLayoutWidth: preferredMaxLayoutWidth)
        textView.ntg_rect = layout.textFrame
    }
    
    fileprivate func calculateTextBubbleLayout(preferredMaxLayoutWidth: CGFloat) -> TextBubbleLayoutModel {
        guard let viewModel = messageViewModel as? TextMessageViewModel else {
            fatalError("View model not match!")
        }
        
        let layoutContext = TextBubbleLayoutModel.LayoutContext(
            attributedText: viewModel.attributedText,
            font: style.textFont(viewModel: viewModel, isSelected: selected),
            textInsets: style.textInsets(viewModel: viewModel, isSelected: selected),
            preferredMaxLayoutWidth: preferredMaxLayoutWidth
        )
        
        let layoutModel = TextBubbleLayoutModel(layoutContext: layoutContext)
        layoutModel.calculateLayout()
        
        return layoutModel
    }
    
    open var canCalculateSizeInBackground: Bool {
        return true
    }
    
    // MARK: UITextViewDelegate
    open func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        guard let viewModel = messageViewModel as? TextMessageViewModel else {
            fatalError("View model not match!")
        }
        
        viewModel.didTapURL(URL, bubbleView: self)
        
        return false
    }
}

// MARK: Layout model
final class TextBubbleLayoutModel {
    let layoutContext: LayoutContext
    var textFrame: CGRect = CGRect.zero
    var size: CGSize = CGSize.zero
    
    init(layoutContext: LayoutContext) {
        self.layoutContext = layoutContext
    }
    
    class LayoutContext {
        let attributedText: NSAttributedString
        let font: UIFont
        let textInsets: UIEdgeInsets
        let preferredMaxLayoutWidth: CGFloat
        init (attributedText: NSAttributedString, font: UIFont, textInsets: UIEdgeInsets, preferredMaxLayoutWidth: CGFloat) {
            self.font = font
            self.attributedText = attributedText
            self.textInsets = textInsets
            self.preferredMaxLayoutWidth = preferredMaxLayoutWidth
        }
    }
    
    func calculateLayout() {
        let textHorizontalInset = layoutContext.textInsets.ntg_horziontalInset
        let textVerticalInset = layoutContext.textInsets.ntg_verticalInset
        
        let maxTextWidth = layoutContext.preferredMaxLayoutWidth - textHorizontalInset
        let textSize = textSizeThatFitsWidth(maxTextWidth)
        
        let bubbleSize = textSize.ntg_outsetBy(dx: textHorizontalInset, dy: textVerticalInset)
        let bubbleFrame = CGRect(origin: CGPoint.zero, size: bubbleSize)
        
        textFrame = UIEdgeInsetsInsetRect(bubbleFrame, layoutContext.textInsets)
        
        size = bubbleSize
    }
    
    fileprivate func textSizeThatFitsWidth(_ width: CGFloat) -> CGSize {
        return layoutContext.attributedText.boundingRect(
            with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
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

func == (lhs: TextBubbleLayoutModel.LayoutContext, rhs: TextBubbleLayoutModel.LayoutContext) -> Bool {
    return lhs.attributedText.string == rhs.attributedText.string &&
        lhs.textInsets == rhs.textInsets &&
        lhs.font == rhs.font &&
        lhs.preferredMaxLayoutWidth == rhs.preferredMaxLayoutWidth
}


