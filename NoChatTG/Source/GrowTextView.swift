//
//  GrowTextView.swift
//  NoChat
//
//  Created by little2s on 15/8/27.
//  Copyright © 2015年 Ninty. All rights reserved.
//

import UIKit

public protocol GrowTextViewDelegate: class {
    func growTextViewDidBeginEditing(textView: GrowTextView)
    func growTextViewDidChange(textView: GrowTextView, height: CGFloat)
}

public class GrowTextView: UITextView {
    public struct Constant {
        static let maxHeight: CGFloat = 100
        static let minHeight: CGFloat = 28
        static let textInsets = UIEdgeInsets(top: 4.5, left: 4.0, bottom: 3.5, right: 4.0)
    }
    
    public weak var growTextViewDelegate: GrowTextViewDelegate?
    
    private let placeholder: UITextView = UITextView()
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }
    
    public convenience init(frame: CGRect) {
        self.init(frame: CGRect.zero, textContainer: nil)
    }
    
    private func commonInit() {
        self.textContainerInset = Constant.textInsets
        self.textContainer.lineFragmentPadding = 0
        self.layoutManager.allowsNonContiguousLayout = false
        self.scrollsToTop = false
        self.delegate = self
        configurePlaceholder()
        updatePlaceholderVisibility()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        placeholder.frame = self.bounds
    }
    
    public override func scrollRectToVisible(rect: CGRect, animated: Bool) {
    }
    
    private func scrollRectToVisible(rect: CGRect) {
        if contentSize.height < Constant.maxHeight {
            return
        }
        super.scrollRectToVisible(rect, animated: true)
    }
    
    public func setTextPlaceholder(textPlaceholder: String) {
        placeholder.text = textPlaceholder
    }
    
    public func setTextPlaceholderColor(color: UIColor) {
        placeholder.textColor = color
    }
    
    public func setTextPlaceholderFont(font: UIFont) {
        placeholder.font = font
    }
    
    private func updatePlaceholderVisibility() {
        if !hasText() {
            showPlaceholder()
        } else {
            hidePlaceholder()
        }
    }
    
    private func showPlaceholder() {
        addSubview(placeholder)
    }
    
    private func hidePlaceholder() {
        placeholder.removeFromSuperview()
    }
    
    private func configurePlaceholder() {
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        placeholder.editable = false
        placeholder.selectable = false
        placeholder.userInteractionEnabled = false
        placeholder.textContainerInset = self.textContainerInset
        placeholder.textContainer.lineFragmentPadding = 0
        placeholder.layoutManager.allowsNonContiguousLayout = false
        placeholder.scrollsToTop = false
        placeholder.backgroundColor = UIColor.clearColor()
    }
}

// MARK: UITextViewDelegate

extension GrowTextView: UITextViewDelegate {
    
    public func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        return true
    }
    
    public func textViewDidChange(textView: UITextView) {
        resetContentSizeAndOffset()
    }
    
    public func textViewDidBeginEditing(textView: UITextView) {
        hidePlaceholder()
        growTextViewDelegate?.growTextViewDidBeginEditing(self)
    }
    
    public func textViewDidEndEditing(textView: UITextView) {
        updatePlaceholderVisibility()
    }
    
}

// MARK: Convenience

extension GrowTextView {
    
    public func resetContentSizeAndOffset() {
        layoutIfNeeded()
        let textViewHeight = max(min(contentSize.height, Constant.maxHeight), Constant.minHeight)
        growTextViewDelegate?.growTextViewDidChange(self, height: textViewHeight)
        if let selectedTextRange = self.selectedTextRange {
            let caretRect = self.caretRectForPosition(selectedTextRange.end);
            let height = textContainerInset.bottom + caretRect.size.height
            self.scrollRectToVisible(CGRectMake(caretRect.origin.x, caretRect.origin.y, caretRect.size.width, height))
        }
    }
    
    public func clear() {
        text = nil
        resetContentSizeAndOffset()
    }
    
}