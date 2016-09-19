//
//  ChatInputViewController.swift
//  NoChatTG
//
//  Created by little2s on 16/5/17.
//  Copyright © 2016年 little2s. All rights reserved.
//

import UIKit
import NoChat

public class ChatInputViewController: UIViewController, ChatInputControllerProtocol {
    
    public struct Constant {
        static let animationDuration: TimeInterval = 0.25
    }
    
    public var sendButtonTitle: String?
    public var textPlaceholder: String?
    
    public var inputBar: UIView!
    public var backgroundView: UIToolbar!
    public var growTextView: GrowTextView!
    public var sendButton: UIButton!
    public var micButton: UIButton!
    public var attachButton: UIButton!
    
    public var growTextViewHeightConstraint: NSLayoutConstraint!
    public var growTextViewTopConstraint: NSLayoutConstraint!
    public var growTextViewBottomConstraint: NSLayoutConstraint!
    public var growTextViewLeadingConstraint: NSLayoutConstraint!
    public var growTextViewTrailingConstraint: NSLayoutConstraint!
    
    public var textViewHeight: CGFloat = GrowTextView.Constant.minHeight
    public var inputViewHeight: CGFloat = 45
    public var inputBarHeight: CGFloat {
        return textViewHeight + growTextViewTopConstraint.constant + growTextViewBottomConstraint.constant
    }
    
    public var onHeightChange: ((HeightChange) -> Void)?
    public var onSendText: ((String) -> Void)?
    public var onChooseAttach: (() -> Void)?
    
    public override func loadView() {
        view = UIView()
        addInputBar()
        addInputViews()
        addConstraints()
    }
    
    private let keyboardMan = KeyboardMan()
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardAnimation()
        
        growTextView.growTextViewDelegate = self
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardMan.keyboardObserveEnabled = true
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        keyboardMan.keyboardObserveEnabled = false
        super.viewWillDisappear(animated)
    }
    
    public func toggleSendButtonEnabled() {
        let hasText = growTextView.hasText
        sendButton.isEnabled = hasText
        sendButton.isHidden = !hasText
        micButton.isHidden = hasText
    }
    
    public func clearInputText() {
        growTextView.clear()
        toggleSendButtonEnabled()
    }
    
    public func endInputting(_ animated: Bool) {
        view.endEditing(animated)
    }
    
    @objc
    public func didTapSendButton(sender: UIButton) {
        guard let text = growTextView.text else { return }
        
        let str = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if str.characters.count > 0 {
            onSendText?(str)
            growTextView.clear()
            toggleSendButtonEnabled()
        }
    }
    
    @objc
    public func didTapAttachButton(sender: UIButton) {
        endInputting(true)
        onChooseAttach?()
    }
    
    private func addInputBar() {
        inputBar = UIView()
        view.addSubview(inputBar)
        
        backgroundView = UIToolbar()
        inputBar.addSubview(backgroundView)
    }
    
    private func addInputViews() {
        let placeholder = textPlaceholder ?? "Message"
        let textFont = UIFont.systemFont(ofSize: 16)
        
        growTextView = GrowTextView()
        growTextView.layer.borderColor = UIColor.lightGray.cgColor
        growTextView.layer.borderWidth = 0.5
        growTextView.layer.cornerRadius = 5
        growTextView.layer.masksToBounds = true
        growTextView.font = textFont
        growTextView.setTextPlaceholder(textPlaceholder: placeholder)
        growTextView.setTextPlaceholderColor(color: UIColor.lightGray)
        growTextView.setTextPlaceholderFont(font: textFont)
        inputBar.addSubview(growTextView)
        
        
        let sendTitle = sendButtonTitle ?? "Send"
        
        let sendFont: UIFont
        if #available(iOS 8.2, *) {
            sendFont = UIFont.systemFont(ofSize: 17, weight: UIFontWeightMedium)
        } else {
            sendFont = UIFont(name: "HelveticaNeue-Medium", size: 17)!
        }
        
        sendButton = UIButton(type: .system)
        sendButton.setTitle(sendTitle, for: .normal)
        sendButton.addTarget(self, action: #selector(didTapSendButton), for: .touchUpInside)
        sendButton.titleLabel?.font = sendFont
        sendButton.isEnabled = false
        sendButton.isHidden = true
        inputBar.addSubview(sendButton)
        
        micButton = UIButton(type: .system)
        micButton.setImage(imageFactory.createImage(name: "MicButton"), for: .normal)
        inputBar.addSubview(micButton)
        
        attachButton = UIButton(type: .system)
        attachButton.setImage(imageFactory.createImage(name: "AttachButton"), for: .normal)
        attachButton.addTarget(self, action: #selector(didTapAttachButton), for: .touchUpInside)
        inputBar.addSubview(attachButton)
    }
    
    private func addConstraints() {
        inputBar.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        growTextView.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        micButton.translatesAutoresizingMaskIntoConstraints = false
        attachButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: inputBar, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top
            
            
            , multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: inputBar, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: inputBar, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
        
        
        backgroundView.setContentHuggingPriority(UILayoutPriority(240), for: .vertical)
        backgroundView.setContentCompressionResistancePriority(UILayoutPriority(240), for: .vertical)
        
        inputBar.addConstraint(NSLayoutConstraint(item: inputBar, attribute: .top, relatedBy: .equal, toItem: backgroundView, attribute: .top, multiplier: 1, constant: 0))
        inputBar.addConstraint(NSLayoutConstraint(item: inputBar, attribute: .leading, relatedBy: .equal, toItem: backgroundView, attribute: .leading, multiplier: 1, constant: 0))
        inputBar.addConstraint(NSLayoutConstraint(item: inputBar, attribute: .trailing, relatedBy: .equal, toItem: backgroundView, attribute: .trailing, multiplier: 1, constant: 0))
        inputBar.addConstraint(NSLayoutConstraint(item: inputBar, attribute: .bottom, relatedBy: .equal, toItem: backgroundView, attribute: .bottom, multiplier: 1, constant: 0))
        
        
        growTextViewHeightConstraint = NSLayoutConstraint(item: growTextView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 28)
        
        growTextViewTopConstraint = NSLayoutConstraint(item: growTextView, attribute: .top, relatedBy: .equal, toItem: inputBar, attribute: .top, multiplier: 1, constant: 9)
        growTextViewBottomConstraint = NSLayoutConstraint(item: inputBar, attribute: .bottom, relatedBy: .equal, toItem: growTextView, attribute: .bottom, multiplier: 1, constant: 8)
        growTextViewLeadingConstraint = NSLayoutConstraint(item: growTextView, attribute: .leading, relatedBy: .equal, toItem: inputBar, attribute: .leading, multiplier: 1, constant: 40)
        growTextViewTrailingConstraint = NSLayoutConstraint(item: inputBar, attribute: .trailing, relatedBy: .equal, toItem: growTextView, attribute: .trailing, multiplier: 1, constant: 50)
        
        inputBar.addConstraints([growTextViewHeightConstraint, growTextViewTopConstraint, growTextViewBottomConstraint, growTextViewLeadingConstraint, growTextViewTrailingConstraint])
        
        
        inputBar.addConstraint(NSLayoutConstraint(item: sendButton, attribute: .trailing, relatedBy: .equal, toItem: inputBar, attribute: .trailing, multiplier: 1, constant: 0))
        inputBar.addConstraint(NSLayoutConstraint(item: sendButton, attribute: .bottom, relatedBy: .equal, toItem: inputBar, attribute: .bottom, multiplier: 1, constant: 0))
        inputBar.addConstraint(NSLayoutConstraint(item: sendButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50))
        inputBar.addConstraint(NSLayoutConstraint(item: sendButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 45))
        
        inputBar.addConstraint(NSLayoutConstraint(item: micButton, attribute: .trailing, relatedBy: .equal, toItem: inputBar, attribute: .trailing, multiplier: 1, constant: 0))
        inputBar.addConstraint(NSLayoutConstraint(item: micButton, attribute: .bottom, relatedBy: .equal, toItem: inputBar, attribute: .bottom, multiplier: 1, constant: 0))
        inputBar.addConstraint(NSLayoutConstraint(item: micButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50))
        inputBar.addConstraint(NSLayoutConstraint(item: micButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 45))
        
        inputBar.addConstraint(NSLayoutConstraint(item: attachButton, attribute: .leading, relatedBy: .equal, toItem: inputBar, attribute: .leading, multiplier: 1, constant: 0))
        inputBar.addConstraint(NSLayoutConstraint(item: attachButton, attribute: .bottom, relatedBy: .equal, toItem: inputBar, attribute: .bottom, multiplier: 1, constant: 0))
        inputBar.addConstraint(NSLayoutConstraint(item: attachButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40))
        inputBar.addConstraint(NSLayoutConstraint(item: attachButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 45))
        
    }
    
    private func setupKeyboardAnimation() {
        keyboardMan.postKeyboardInfo = { [unowned self] _, info in
            let oldH = self.inputViewHeight
            let newH = info.action == .Hide ? self.inputBarHeight :  self.inputBarHeight + info.height
            
            self.onHeightChange?(HeightChange(oldHeight: oldH, newHeight: newH))
            
            self.inputViewHeight = newH
        }
    }
    
    
    
    public override func viewWillTransition(to: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        let oldH = inputViewHeight
        let newH = inputBarHeight
        UIView.performWithoutAnimation {
            self.onHeightChange?(HeightChange(oldHeight: oldH, newHeight: newH))
        }
        super.viewWillTransition(to: to, with: coordinator)
    }

}

extension ChatInputViewController: GrowTextViewDelegate {
    public func growTextViewDidChange(textView: GrowTextView, height: CGFloat) {
        let oldH = inputViewHeight
        let newH = inputViewHeight + (height - textViewHeight)
        self.textViewHeight = height
        self.inputViewHeight = newH
        
        self.growTextViewHeightConstraint.constant = height
        view.setNeedsLayout()
        UIView.animate(withDuration: Constant.animationDuration, animations: { () -> Void in
            self.onHeightChange?(HeightChange(oldHeight: oldH, newHeight: newH))
        })
        
        toggleSendButtonEnabled()
    }
    
    public func growTextViewDidBeginEditing(textView: GrowTextView) {
        
    }
}
