//
//  SimpleInputPanel.swift
//  NoChatExample
//
//  Created by yinglun on 2020/8/15.
//  Copyright © 2020 little2s. All rights reserved.
//

import UIKit
import NoChat
import HPGrowingTextView

class SimpleInputCoordinator {
    
    enum InputStatus {
        case idle
        case text
    }
    
    private(set) var status: InputStatus = .idle

    private weak var chatViewController: SimpleChatViewController?
    
    private var inputPanel: SimpleInputPanel? {
        chatViewController?.inputPanel as? SimpleInputPanel
    }

    init(chatViewController: SimpleChatViewController) {
        self.chatViewController = chatViewController
        self.inputPanel?.inputCoordinator = self
    }
    
    func transitionToInputStatus(_ newStatus: InputStatus) {
        let oldStatus = self.status
        self.status = newStatus
        
        switch (oldStatus, newStatus) {
        case (.idle, .text):
            if inputPanel?.inputField.internalTextView.isFirstResponder == false {
                inputPanel?.inputField.internalTextView.becomeFirstResponder()
            }
            
        case (.text, .idle):
            if inputPanel?.inputField.internalTextView.isFirstResponder == true {
                inputPanel?.inputField.internalTextView.resignFirstResponder()
            }
        default:
            break
        }
    }
}

protocol SimpleInputPanelDelegate: InputPanelDelegate {
    func didInputTextPanelStartInputting(_ inputTextPanel: SimpleInputPanel)
    func inputTextPanel(_ inputTextPanel: SimpleInputPanel, requestSendText text: String)
}

class SimpleInputPanel: InputPanel, HPGrowingTextViewDelegate {
    
    struct Layout {
        static var rootWindowSafeAreaInsets: UIEdgeInsets {
            guard let window = UIApplication.shared.delegate?.window.flatMap({ $0 }) else {
                return .zero
            }
            return window.safeAreaInsets
        }
        static let safeAreaBottomHeight: CGFloat = rootWindowSafeAreaInsets.bottom
        static let baseHeight: CGFloat = 70
        static let inputFiledInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 6)
        static let inputFiledEdgeInsets = UIEdgeInsets(top: 9, left: 16, bottom: 9, right: 16)
        static let inputFiledInternalEdgeInsets = UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 0)
    }
    
    var textPanelHeight: CGFloat = Layout.baseHeight
        
    var backgroundView: UIView!
    
    var inputField: HPGrowingTextView!
    var inputFiledClippingContainer: UIView!
    var fieldBackground: UIView!
            
    private var parentSize = CGSize.zero
    
    private var messageAreaSize = CGSize.zero
    private var keyboardHeight = CGFloat(0)
    
    weak var inputCoordinator: SimpleInputCoordinator?
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.white
        backgroundView.clipsToBounds = true
        
        fieldBackground = UIView()
        fieldBackground.frame = CGRect(x: Layout.inputFiledInsets.left, y: Layout.inputFiledInsets.top, width: bounds.width - Layout.inputFiledInsets.left - Layout.inputFiledInsets.right, height: bounds.height - Layout.inputFiledInsets.top - Layout.inputFiledInsets.bottom)
        fieldBackground.layer.masksToBounds = true
        fieldBackground.backgroundColor = UIColor.clear
        
        inputFiledClippingContainer = UIView()
        inputFiledClippingContainer.clipsToBounds = true
        
        let inputFiledClippingFrame = CGRect(x: fieldBackground.frame.origin.x + Layout.inputFiledEdgeInsets.left, y: fieldBackground.frame.origin.y + Layout.inputFiledEdgeInsets.top, width: fieldBackground.frame.width - Layout.inputFiledEdgeInsets.left - Layout.inputFiledEdgeInsets.right, height: fieldBackground.frame.height - Layout.inputFiledEdgeInsets.top - Layout.inputFiledEdgeInsets.bottom)
        inputFiledClippingContainer.frame = inputFiledClippingFrame
        
        inputField = HPGrowingTextView()
        inputField.frame = CGRect(x: Layout.inputFiledInternalEdgeInsets.left, y: Layout.inputFiledInternalEdgeInsets.top, width: inputFiledClippingFrame.width - Layout.inputFiledInternalEdgeInsets.left, height: inputFiledClippingFrame.height)
        inputField.animateHeightChange = false
        inputField.animationDuration = 0
        inputField.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        inputField.backgroundColor = UIColor.clear
        inputField.isOpaque = false
        inputField.clipsToBounds = true
        inputField.internalTextView.backgroundColor = UIColor.clear
        inputField.internalTextView.isOpaque = false
        inputField.internalTextView.contentMode = .left
        inputField.internalTextView.enablesReturnKeyAutomatically = true
        inputField.internalTextView.returnKeyType = .send
        inputField.internalTextView.scrollIndicatorInsets = UIEdgeInsets(top: -Layout.inputFiledInternalEdgeInsets.top, left: 0, bottom: 5-0.5, right: 0)
        inputField.placeholder = "Messages"
        inputField.placeholderColor = #colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1)
                
        addSubview(backgroundView)
        addSubview(fieldBackground)
        addSubview(inputFiledClippingContainer)
        
        inputField.maxNumberOfLines = maxNumberOfLines(forSize: parentSize)
        inputField.delegate = self
        inputFiledClippingContainer.addSubview(inputField)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func layoutSubviews() {
        super.layoutSubviews()
        
        fieldBackground.frame = CGRect(x: Layout.inputFiledInsets.left, y: Layout.inputFiledInsets.top, width: bounds.width - Layout.inputFiledInsets.left - Layout.inputFiledInsets.right, height: bounds.height - Layout.inputFiledInsets.top - Layout.inputFiledInsets.bottom)
        
        inputFiledClippingContainer.frame = CGRect(x: fieldBackground.frame.origin.x + Layout.inputFiledEdgeInsets.left, y: fieldBackground.frame.origin.y + Layout.inputFiledEdgeInsets.top, width: fieldBackground.frame.width - Layout.inputFiledEdgeInsets.left - Layout.inputFiledEdgeInsets.right, height: fieldBackground.frame.height - Layout.inputFiledEdgeInsets.top - Layout.inputFiledEdgeInsets.bottom)
                        
        if let window = UIApplication.shared.delegate?.window {
            let backgroundViewHeight = (window?.bounds.height ?? self.frame.minY) - self.frame.minY
            backgroundView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: backgroundViewHeight)
        }
    }
    
    override func endInputting(animated: Bool) {
        inputCoordinator?.transitionToInputStatus(.idle)
    }
    
    override func adjust(for size: CGSize, keyboardHeight: CGFloat, duration: TimeInterval, animationCurve: Int) {
        let previousSize = parentSize
        parentSize = size
        
        if abs(size.width - previousSize.width) > .ulpOfOne {
            change(to: size, keyboardHeight: keyboardHeight, duration: 0)
        }
        
        adjust(for: size, keyboardHeight: keyboardHeight, inputFiledHeight: inputField.frame.height, duration: duration, animationCurve: animationCurve)
    }
    
    override func change(to size: CGSize, keyboardHeight: CGFloat, duration: TimeInterval) {
        parentSize = size
        
        let messageAreaSize = size
        
        self.messageAreaSize = messageAreaSize
        self.keyboardHeight = keyboardHeight
        
        var inputFieldSnapshotView: UIView?
        if duration > .ulpOfOne {
            inputFieldSnapshotView = inputField.internalTextView.snapshotView(afterScreenUpdates: false)
            if let v = inputFieldSnapshotView {
                v.frame = inputField.frame.offsetBy(dx: inputFiledClippingContainer.frame.origin.x, dy: inputFiledClippingContainer.frame.origin.y)
                addSubview(v)
            }
        }
        
        UIView.performWithoutAnimation {
            self.updateInputFiledLayout()
        }
        
        let inputContainerHeight = heightForInputFiledHeight(inputField.frame.size.height)
        var newInputContainerFrame: CGRect = .zero
        if (abs(keyboardHeight) < .ulpOfOne) {
            newInputContainerFrame = CGRect(x: 0, y: messageAreaSize.height - Layout.safeAreaBottomHeight - keyboardHeight - inputContainerHeight, width: messageAreaSize.width, height: inputContainerHeight)
        } else {
             newInputContainerFrame = CGRect(x: 0, y: messageAreaSize.height - keyboardHeight - inputContainerHeight, width: messageAreaSize.width, height: inputContainerHeight)
        }
        
        if duration > .ulpOfOne {
            if inputFieldSnapshotView != nil {
                inputField.alpha = 0
            }
            
            UIView.animate(withDuration: duration, animations: {
                self.frame = newInputContainerFrame
                self.layoutSubviews()
                
                if let v = inputFieldSnapshotView {
                    self.inputField.alpha = 1
                    v.frame = self.inputField.frame.offsetBy(dx: self.inputFiledClippingContainer.frame.origin.x, dy: self.inputFiledClippingContainer.frame.origin.y)
                    v.alpha = 0
                }
            }, completion: { (_) in
                inputFieldSnapshotView?.removeFromSuperview()
            })
        } else {
            frame = newInputContainerFrame
        }
    }
    
    func clearInputField() {
        inputField.internalTextView.text = nil
        inputField.refreshHeight()
    }
    
    func growingTextView(_ growingTextView: HPGrowingTextView!, willChangeHeight height: Float) {
        let inputContainerHeight = heightForInputFiledHeight(CGFloat(height))
        var newInputContainerFrame: CGRect = .zero
        if (abs(keyboardHeight) < .ulpOfOne) {
            newInputContainerFrame = CGRect(x: 0, y: messageAreaSize.height - Layout.safeAreaBottomHeight - keyboardHeight - inputContainerHeight, width: messageAreaSize.width, height: inputContainerHeight)
        } else {
            newInputContainerFrame = CGRect(x: 0, y: messageAreaSize.height - keyboardHeight - inputContainerHeight, width: messageAreaSize.width, height: inputContainerHeight)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.frame = newInputContainerFrame
            self.layoutSubviews()
        }
        
        delegate?.inputPanel(self, willChange: inputContainerHeight, duration: 0.3, animationCurve: 0)
    }
    
    func growingTextViewShouldBeginEditing(_ growingTextView: HPGrowingTextView!) -> Bool {
        inputCoordinator?.transitionToInputStatus(.text)
        return true
    }
    
    func growingTextViewDidBeginEditing(_ growingTextView: HPGrowingTextView!) {
        if let d = delegate as? SimpleInputPanelDelegate {
            d.didInputTextPanelStartInputting(self)
        }
    }
    
    func growingTextView(_ growingTextView: HPGrowingTextView!, shouldChangeTextIn range: NSRange, replacementText text: String!) -> Bool {
        if growingTextView != self.inputField {
            return true
        }
        
        if text == "\n" {
            guard let txt = inputField.internalTextView.text else {
                return true
            }
            
            let str = txt.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if str.count > 0 {
                if let d = delegate as? SimpleInputPanelDelegate {
                    d.inputTextPanel(self, requestSendText: str)
                }
                clearInputField()
            }
            
            return false
        }
        
        return true
    }
    
    private func adjust(for size: CGSize, keyboardHeight: CGFloat, inputFiledHeight: CGFloat, duration: TimeInterval, animationCurve: Int) {
        let block = {
            let messageAreaSize = size
            
            self.messageAreaSize = messageAreaSize
            self.keyboardHeight = keyboardHeight
            
            let inputContainerHeight = self.heightForInputFiledHeight(inputFiledHeight)
            if (abs(keyboardHeight) < .ulpOfOne) {
                self.frame = CGRect(x: 0, y: messageAreaSize.height - Layout.safeAreaBottomHeight - keyboardHeight - inputContainerHeight, width: self.messageAreaSize.width, height: inputContainerHeight)
            } else {
                self.frame = CGRect(x: 0, y: messageAreaSize.height - keyboardHeight - inputContainerHeight, width: self.messageAreaSize.width, height: inputContainerHeight)
            }
            self.layoutSubviews()
        }
        
        if duration > .ulpOfOne {
            UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: UInt(animationCurve << 16)), animations: block, completion: nil)
        } else {
            block()
        }
    }
    
    private func heightForInputFiledHeight(_ inputFiledHeight: CGFloat) -> CGFloat {
        return max(self.textPanelHeight, inputFiledHeight + Layout.inputFiledInsets.top + Layout.inputFiledInsets.bottom + (inputFiledHeight > 40 ? 10 : 0))
    }
    
    private func updateInputFiledLayout() {
        let range = inputField.internalTextView.selectedRange
        
        inputField.delegate = nil
        
        let inputFiledInsets = Layout.inputFiledInsets
        let inputFiledInternalEdgeInsets = Layout.inputFiledInternalEdgeInsets
        
        let inputFiledClippingFrame = CGRect(x: inputFiledInsets.left + Layout.inputFiledEdgeInsets.left, y: inputFiledInsets.top + Layout.inputFiledEdgeInsets.top, width: parentSize.width - inputFiledInsets.left - inputFiledInsets.right - Layout.inputFiledEdgeInsets.left - Layout.inputFiledEdgeInsets.right, height: 0)
        
        let inputFieldFrame = CGRect(x: inputFiledInternalEdgeInsets.left, y: inputFiledInternalEdgeInsets.top, width: inputFiledClippingFrame.width - inputFiledInternalEdgeInsets.left, height: 0)
        
        inputField.frame = inputFieldFrame
        inputField.internalTextView.frame = CGRect(x: 0, y: 0, width: inputFieldFrame.width, height: inputFieldFrame.height)
        
        inputField.maxNumberOfLines = maxNumberOfLines(forSize: parentSize)
        inputField.refreshHeight()
        
        inputField.internalTextView.selectedRange = range
        
        inputField.delegate = self
    }
    
    private func maxNumberOfLines(forSize size: CGSize) -> Int32 {
        return 3
    }
    
}
