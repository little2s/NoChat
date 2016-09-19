//
//  GrowTextView.swift
//  NoChat
//
//  Created by little2s on 15/8/27.
//  Copyright © 2015年 Ninty. All rights reserved.
//

import UIKit

public protocol GrowTextViewDelegate: class {
    func growTextViewDidBeginEditing(_ textView: GrowTextView)
    func growTextViewDidChange(_ textView: GrowTextView, height: CGFloat)
    func growTextViewDidSend(_ textView: GrowTextView, text: String)
}

open class GrowTextView: UITextView {
    public struct Constant {
        static let maxHeight: CGFloat = 100
        static let minHeight: CGFloat = 35
        static let textInsets = UIEdgeInsets(top: 8.0, left: 6.0, bottom: 5.0, right: 6.0)
    }
    
    open weak var growTextViewDelegate: GrowTextViewDelegate?
    
    fileprivate let placeholder: UITextView = UITextView()
    
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
    
    fileprivate func commonInit() {
        self.textContainerInset = Constant.textInsets
        self.textContainer.lineFragmentPadding = 0
        self.layoutManager.allowsNonContiguousLayout = false
        self.scrollsToTop = false
        self.delegate = self
        configurePlaceholder()
        updatePlaceholderVisibility()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        placeholder.frame = self.bounds
    }
    
    open override func scrollRectToVisible(_ rect: CGRect, animated: Bool) {
    }
    
    fileprivate func scrollRectToVisible(_ rect: CGRect) {
        if contentSize.height < Constant.maxHeight {
            return
        }
        super.scrollRectToVisible(rect, animated: true)
    }
    
    open func setTextPlaceholder(_ textPlaceholder: String) {
        placeholder.text = textPlaceholder
    }
    
    open func setTextPlaceholderColor(_ color: UIColor) {
        placeholder.textColor = color
    }
    
    open func setTextPlaceholderFont(_ font: UIFont) {
        placeholder.font = font
    }
    
    fileprivate func updatePlaceholderVisibility() {
        if !hasText {
            showPlaceholder()
        } else {
            hidePlaceholder()
        }
    }
    
    fileprivate func showPlaceholder() {
        addSubview(placeholder)
    }
    
    fileprivate func hidePlaceholder() {
        placeholder.removeFromSuperview()
    }
    
    fileprivate func configurePlaceholder() {
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        placeholder.isEditable = false
        placeholder.isSelectable = false
        placeholder.isUserInteractionEnabled = false
        placeholder.textContainerInset = self.textContainerInset
        placeholder.textContainer.lineFragmentPadding = 0
        placeholder.layoutManager.allowsNonContiguousLayout = false
        placeholder.scrollsToTop = false
        placeholder.backgroundColor = UIColor.clear
    }
}

// MARK: UITextViewDelegate

extension GrowTextView: UITextViewDelegate {
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            
            guard let txt = textView.text else { return false }
            
            let str = txt.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if str.characters.count > 0 {
                growTextViewDelegate?.growTextViewDidSend(self, text: str)
                clear()
            }
            
            return false
        }
        
        return true
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        resetContentSizeAndOffset()
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        hidePlaceholder()
        growTextViewDelegate?.growTextViewDidBeginEditing(self)
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
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
            let caretRect = self.caretRect(for: selectedTextRange.end);
            let height = textContainerInset.bottom + caretRect.size.height
            self.scrollRectToVisible(CGRect(x: caretRect.origin.x, y: caretRect.origin.y, width: caretRect.size.width, height: height))
        }
    }
    
    public func clear() {
        text = nil
        resetContentSizeAndOffset()
    }
    
}
