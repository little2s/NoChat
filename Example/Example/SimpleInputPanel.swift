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
        static let baseHeight: CGFloat = 45
        static let inputFiledInsets = UIEdgeInsets(top: 5, left: 20, bottom: 4, right: 0)
        static let inputFiledEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)
        static let inputFiledInternalEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    private class BackgroundView: UIView {
        private let effectView = UIVisualEffectView()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = .clear
            effectView.effect = UIBlurEffect(style: .regular)
            addSubview(effectView)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            effectView.frame = bounds
        }
    }
    
    private var sendButtonWidth = CGFloat(80)
        
    var backgroundView: UIView!
    
    var inputField: HPGrowingTextView!
    var inputFiledClippingContainer: UIView!
    var fieldBackground: UIView!
    
    var sendButton: UIButton!
            
    private var parentSize = CGSize.zero
    
    private var messageAreaSize = CGSize.zero
    private var keyboardHeight = CGFloat(0)
    
    weak var inputCoordinator: SimpleInputCoordinator?
    
    override init(frame: CGRect) {
        backgroundView = BackgroundView()
        backgroundView.clipsToBounds = true
        
        fieldBackground = UIView()
        fieldBackground.frame = CGRect(x: Layout.inputFiledInsets.left, y: Layout.inputFiledInsets.top, width: frame.width - Layout.inputFiledInsets.left - Layout.inputFiledInsets.right - sendButtonWidth - 1, height: frame.height - Layout.inputFiledInsets.top - Layout.inputFiledInsets.bottom)
        fieldBackground.layer.borderWidth = 0.5
        if #available(iOS 13.0, *) {
            fieldBackground.layer.borderColor = UIColor.systemGray.cgColor
        } else {
            fieldBackground.layer.borderColor = #colorLiteral(red: 0.7019607843, green: 0.6666666667, blue: 0.6980392157, alpha: 1)
        }
        fieldBackground.layer.masksToBounds = true
        fieldBackground.layer.cornerRadius = 18
        fieldBackground.backgroundColor = UIColor.clear
        
        inputFiledClippingContainer = UIView()
        inputFiledClippingContainer.clipsToBounds = true
        
        let inputFiledClippingFrame = fieldBackground.frame.inset(by: Layout.inputFiledEdgeInsets)
        inputFiledClippingContainer.frame = inputFiledClippingFrame
        
        inputField = HPGrowingTextView()
        inputField.frame = CGRect(x: Layout.inputFiledInternalEdgeInsets.left, y: Layout.inputFiledInternalEdgeInsets.top, width: inputFiledClippingFrame.width - Layout.inputFiledInternalEdgeInsets.left, height: inputFiledClippingFrame.height)
        inputField.animateHeightChange = false
        inputField.animationDuration = 0
        inputField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        inputField.backgroundColor = UIColor.clear
        inputField.isOpaque = false
        inputField.clipsToBounds = true
        inputField.internalTextView.backgroundColor = UIColor.clear
        inputField.internalTextView.isOpaque = false
        inputField.internalTextView.contentMode = .left
        inputField.internalTextView.enablesReturnKeyAutomatically = true
        inputField.internalTextView.scrollIndicatorInsets = UIEdgeInsets(top: -Layout.inputFiledInternalEdgeInsets.top, left: 0, bottom: 5-0.5, right: 0)
        inputField.placeholder = "Message"
        if #available(iOS 13.0, *) {
            inputField.placeholderColor = UIColor.placeholderText
        } else {
            inputField.placeholderColor = #colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1)
        }
        
        sendButton = UIButton(type: .system)
        sendButton.isExclusiveTouch = true
        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(UIColor(red: 0/255.0, green: 126/255.0, blue: 229/255.0, alpha: 1), for: .normal)
        if #available(iOS 13, *) {
            sendButton.setTitleColor(UIColor.placeholderText, for: .disabled)
        } else {
            sendButton.setTitleColor(UIColor(red: 142/255.0, green: 142/255.0, blue: 147/255.0, alpha: 1), for: .disabled)
        }
        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        sendButton.isEnabled = false
        
        super.init(frame: frame)
                
        addSubview(backgroundView)
        addSubview(fieldBackground)
        addSubview(inputFiledClippingContainer)
        addSubview(sendButton)
        
        inputField.maxNumberOfLines = maxNumberOfLines(forSize: parentSize)
        inputField.delegate = self
        inputFiledClippingContainer.addSubview(inputField)
        
        sendButton.addTarget(self, action: #selector(didTapSendButton), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var safeArea = UIEdgeInsets.zero
        if let vc = delegate as? SimpleChatViewController {
            safeArea = vc.safeAreaInsets
        }
        
        fieldBackground.frame = CGRect(x: Layout.inputFiledInsets.left + safeArea.left, y: Layout.inputFiledInsets.top, width: bounds.width - Layout.inputFiledInsets.left - Layout.inputFiledInsets.right - sendButtonWidth - 1 - safeArea.left - safeArea.right, height: bounds.height - Layout.inputFiledInsets.top - Layout.inputFiledInsets.bottom)
        
        inputFiledClippingContainer.frame = fieldBackground.frame.inset(by: Layout.inputFiledEdgeInsets)
                        
        if let window = UIApplication.shared.delegate?.window {
            let backgroundViewHeight = (window?.bounds.height ?? self.frame.minY) - self.frame.minY
            backgroundView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: backgroundViewHeight)
        }
        
        sendButton.frame = CGRect(x: bounds.width - safeArea.right - sendButtonWidth, y: bounds.height - Layout.baseHeight, width: sendButtonWidth, height: Layout.baseHeight)
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
            if let vc = self.delegate as? SimpleChatViewController {
                newInputContainerFrame = CGRect(x: 0, y: messageAreaSize.height - vc.safeAreaInsets.bottom - keyboardHeight - inputContainerHeight, width: messageAreaSize.width, height: inputContainerHeight)

            }
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
            if let vc = self.delegate as? SimpleChatViewController {
                newInputContainerFrame = CGRect(x: 0, y: messageAreaSize.height - vc.safeAreaInsets.bottom - keyboardHeight - inputContainerHeight, width: messageAreaSize.width, height: inputContainerHeight)

            }
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
        return max(Layout.baseHeight, inputFiledHeight + Layout.inputFiledInsets.top + Layout.inputFiledInsets.bottom)
    }
    
    private func updateInputFiledLayout() {
        let range = inputField.internalTextView.selectedRange
        
        inputField.delegate = nil
        
        let inputFiledInsets = Layout.inputFiledInsets
        let inputFiledInternalEdgeInsets = Layout.inputFiledInternalEdgeInsets
        
        let inputFiledClippingFrame = CGRect(x: inputFiledInsets.left, y: inputFiledInsets.top, width: parentSize.width - inputFiledInsets.left - inputFiledInsets.right - sendButtonWidth - 1, height: 0)
        
        let inputFieldFrame = CGRect(x: inputFiledInternalEdgeInsets.left, y: inputFiledInternalEdgeInsets.top, width: inputFiledClippingFrame.width - inputFiledInternalEdgeInsets.left, height: 0)
        
        inputField.frame = inputFieldFrame
        inputField.internalTextView.frame = CGRect(x: 0, y: 0, width: inputFieldFrame.width, height: inputFieldFrame.height)
        
        inputField.maxNumberOfLines = maxNumberOfLines(forSize: parentSize)
        inputField.refreshHeight()
        
        inputField.internalTextView.selectedRange = range
        
        inputField.delegate = self
    }
    
    private func maxNumberOfLines(forSize size: CGSize) -> Int32 {
        if size.height <= 320 {
            return 3
        } else if (size.height <= 480) {
            return 5;
        } else {
            return 7
        }
    }
    
    func growingTextViewDidChange(_ growingTextView: HPGrowingTextView!) {
        toggleSendButtonEnabled()
    }
    
    @objc func didTapSendButton(_ sender: UIButton) {
        guard let text = inputField.internalTextView.text else {
            return
        }
        
        let str = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if str.count > 0 {
            if let d = delegate as? SimpleInputPanelDelegate {
                d.inputTextPanel(self, requestSendText: str)
            }
            clearInputField()
        }
    }
    
    func toggleSendButtonEnabled() {
        let hasText = inputField.internalTextView.hasText
        sendButton.isEnabled = hasText
    }
    
}
