//
//  ChatInputViewController.swift
//  NoChatTG
//
//  Created by little2s on 16/5/17.
//  Copyright © 2016年 little2s. All rights reserved.
//

import UIKit
import NoChat

open class ChatInputViewController: UIViewController, ChatInputControllerProtocol {
    
    public struct Constant {
        static let animationDuration: TimeInterval = 0.25
    }
    
    open var sendButtonTitle: String?
    open var textPlaceholder: String?
    
    open var inputBar: UIView!
    open var backgroundView: UIToolbar!
    open var growTextView: GrowTextView!
    open var micButton: UIButton!
    open var faceButton: UIButton!
    open var attachButton: UIButton!
    
    open var growTextViewHeightConstraint: NSLayoutConstraint!
    open var growTextViewTopConstraint: NSLayoutConstraint!
    open var growTextViewBottomConstraint: NSLayoutConstraint!
    open var growTextViewLeadingConstraint: NSLayoutConstraint!
    open var growTextViewTrailingConstraint: NSLayoutConstraint!
    
    open var textViewHeight: CGFloat = GrowTextView.Constant.minHeight
    open var inputViewHeight: CGFloat = 50
    open var inputBarHeight: CGFloat {
        return textViewHeight + growTextViewTopConstraint.constant + growTextViewBottomConstraint.constant
    }
    
    open var onHeightChange: ((HeightChange) -> Void)?
    open var onSendText: ((String) -> Void)?
    open var onChooseAttach: (() -> Void)?
    
    open override func loadView() {
        view = UIView()
        addInputBar()
        addInputViews()
        addConstraints()
    }
    
    fileprivate let keyboardMan = KeyboardMan()
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardAnimation()
        
        growTextView.growTextViewDelegate = self
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardMan.keyboardObserveEnabled = true
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        keyboardMan.keyboardObserveEnabled = false
        super.viewWillDisappear(animated)
    }
    
    open func clearInputText() {
        growTextView.clear()
    }
    
    open func endInputting(_ animated: Bool) {
        view.endEditing(animated)
    }
    
    @objc
    open func didTapAttachButton(_ sender: UIButton) {
        onChooseAttach?()
    }
    
    fileprivate func addInputBar() {
        inputBar = UIView()
        view.addSubview(inputBar)
        
        backgroundView = UIToolbar()
        inputBar.addSubview(backgroundView)
    }
    
    fileprivate func addInputViews() {
        let textFont = UIFont.systemFont(ofSize: 16)
        
        growTextView = GrowTextView()
        growTextView.layer.borderColor = UIColor.lightGray.cgColor
        growTextView.layer.borderWidth = 0.5
        growTextView.layer.cornerRadius = 5
        growTextView.layer.masksToBounds = true
        growTextView.font = textFont
        growTextView.returnKeyType = .send
        growTextView.enablesReturnKeyAutomatically = true
        inputBar.addSubview(growTextView)
        
        micButton = UIButton(type: .system)
        micButton.setImage(imageFactory.createImage("Voice"), for: UIControlState())
        micButton.setImage(imageFactory.createImage("VoiceHL"), for: .highlighted)
        inputBar.addSubview(micButton)
        
        faceButton = UIButton(type: .system)
        faceButton.setImage(imageFactory.createImage("Emotion"), for: UIControlState())
        faceButton.setImage(imageFactory.createImage("EmotionHL"), for: .highlighted)
        inputBar.addSubview(faceButton)
        
        attachButton = UIButton(type: .system)
        attachButton.setImage(imageFactory.createImage("Attach"), for: UIControlState())
        attachButton.setImage(imageFactory.createImage("AttachHL"), for: .highlighted)
        attachButton.addTarget(self, action: #selector(didTapAttachButton), for: .touchUpInside)
        inputBar.addSubview(attachButton)
    }
    
    fileprivate func addConstraints() {
        inputBar.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        growTextView.translatesAutoresizingMaskIntoConstraints = false
        micButton.translatesAutoresizingMaskIntoConstraints = false
        faceButton.translatesAutoresizingMaskIntoConstraints = false
        attachButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: inputBar, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: inputBar, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: inputBar, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
        
        
        backgroundView.setContentHuggingPriority(UILayoutPriority(240), for: .vertical)
        backgroundView.setContentCompressionResistancePriority(UILayoutPriority(240), for: .vertical)
        
        inputBar.addConstraint(NSLayoutConstraint(item: inputBar, attribute: .top, relatedBy: .equal, toItem: backgroundView, attribute: .top, multiplier: 1, constant: 0))
        inputBar.addConstraint(NSLayoutConstraint(item: inputBar, attribute: .leading, relatedBy: .equal, toItem: backgroundView, attribute: .leading, multiplier: 1, constant: 0))
        inputBar.addConstraint(NSLayoutConstraint(item: inputBar, attribute: .trailing, relatedBy: .equal, toItem: backgroundView, attribute: .trailing, multiplier: 1, constant: 0))
        inputBar.addConstraint(NSLayoutConstraint(item: inputBar, attribute: .bottom, relatedBy: .equal, toItem: backgroundView, attribute: .bottom, multiplier: 1, constant: 0))
        
        
        growTextViewHeightConstraint = NSLayoutConstraint(item: growTextView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 35)
        
        growTextViewTopConstraint = NSLayoutConstraint(item: growTextView, attribute: .top, relatedBy: .equal, toItem: inputBar, attribute: .top, multiplier: 1, constant: 7.5)
        growTextViewBottomConstraint = NSLayoutConstraint(item: inputBar, attribute: .bottom, relatedBy: .equal, toItem: growTextView, attribute: .bottom, multiplier: 1, constant: 7.5)
        growTextViewLeadingConstraint = NSLayoutConstraint(item: growTextView, attribute: .leading, relatedBy: .equal, toItem: inputBar, attribute: .leading, multiplier: 1, constant: 40)
        growTextViewTrailingConstraint = NSLayoutConstraint(item: inputBar, attribute: .trailing, relatedBy: .equal, toItem: growTextView, attribute: .trailing, multiplier: 1, constant: 80)
        
        inputBar.addConstraints([growTextViewHeightConstraint, growTextViewTopConstraint, growTextViewBottomConstraint, growTextViewLeadingConstraint, growTextViewTrailingConstraint])
        
        
        
        inputBar.addConstraint(NSLayoutConstraint(item: micButton, attribute: .leading, relatedBy: .equal, toItem: inputBar, attribute: .leading, multiplier: 1, constant: 0))
        inputBar.addConstraint(NSLayoutConstraint(item: micButton, attribute: .bottom, relatedBy: .equal, toItem: inputBar, attribute: .bottom, multiplier: 1, constant: 0))
        inputBar.addConstraint(NSLayoutConstraint(item: micButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40))
        inputBar.addConstraint(NSLayoutConstraint(item: micButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50))
        
        inputBar.addConstraint(NSLayoutConstraint(item: faceButton, attribute: .trailing, relatedBy: .equal, toItem: attachButton, attribute: .leading, multiplier: 1, constant: 4))
        inputBar.addConstraint(NSLayoutConstraint(item: faceButton, attribute: .bottom, relatedBy: .equal, toItem: inputBar, attribute: .bottom, multiplier: 1, constant: 0))
        inputBar.addConstraint(NSLayoutConstraint(item: faceButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40))
        inputBar.addConstraint(NSLayoutConstraint(item: faceButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50))
        
        inputBar.addConstraint(NSLayoutConstraint(item: attachButton, attribute: .trailing, relatedBy: .equal, toItem: inputBar, attribute: .trailing, multiplier: 1, constant: 0))
        inputBar.addConstraint(NSLayoutConstraint(item: attachButton, attribute: .bottom, relatedBy: .equal, toItem: inputBar, attribute: .bottom, multiplier: 1, constant: 0))
        inputBar.addConstraint(NSLayoutConstraint(item: attachButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40))
        inputBar.addConstraint(NSLayoutConstraint(item: attachButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50))
        
    }
    
    fileprivate func setupKeyboardAnimation() {
        keyboardMan.postKeyboardInfo = { [unowned self] _, info in
            let oldH = self.inputViewHeight
            let newH = info.action == .hide ? self.inputBarHeight :  self.inputBarHeight + info.height
            
            self.onHeightChange?(HeightChange(oldHeight: oldH, newHeight: newH))
            
            self.inputViewHeight = newH
        }
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        let oldH = inputViewHeight
        let newH = inputBarHeight
        UIView.performWithoutAnimation {
            self.onHeightChange?(HeightChange(oldHeight: oldH, newHeight: newH))
        }
        
        super.viewWillTransition(to: size, with: coordinator)
    }

}

extension ChatInputViewController: GrowTextViewDelegate {
    public func growTextViewDidChange(_ textView: GrowTextView, height: CGFloat) {
        let oldH = inputViewHeight
        let newH = inputViewHeight + (height - textViewHeight)
        self.textViewHeight = height
        self.inputViewHeight = newH
        
        self.growTextViewHeightConstraint.constant = height
        view.setNeedsLayout()
        UIView.animate(withDuration: Constant.animationDuration, animations: { () -> Void in
            self.onHeightChange?(HeightChange(oldHeight: oldH, newHeight: newH))
        })
    }
    
    public func growTextViewDidBeginEditing(_ textView: GrowTextView) {
        
    }
    
    public func growTextViewDidSend(_ textView: GrowTextView, text: String) {
        onSendText?(text)
    }
}
