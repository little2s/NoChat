//
//  MMChatInputTextPanel.swift
//  NoChat-Swift-Example
//
//  Copyright (c) 2016-present, little2s.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import NoChat
import HPGrowingTextView

protocol MMChatInputTextPanelDelegate: NOCChatInputPanelDelegate {
    func didInputTextPanelStartInputting(_ inputTextPanel: MMChatInputTextPanel)
    func inputTextPanel(_ inputTextPanel: MMChatInputTextPanel, requestSendText text: String)
}

private let MMRetinaPixel = CGFloat(0.5)
private let MM_EPSILON = CGFloat(0.0001)

class MMChatInputTextPanel: NOCChatInputPanel, HPGrowingTextViewDelegate {
    
    var backgroundView: UIToolbar!
    
    var inputField: HPGrowingTextView!
    var inputFiledClippingContainer: UIView!
    var fieldBackground: UIView!
    
    var micButton: UIButton!
    var faceButton: UIButton!
    var attachButton: UIButton!
    
    private let inputFiledInsets = UIEdgeInsets(top: 7.5, left: 40, bottom: 7.5, right: 80)
    private let inputFiledInternalEdgeInsets = UIEdgeInsets(top: -3 - MMRetinaPixel, left: 0, bottom: 0, right: 0)
    private let baseHeight = CGFloat(50)
    
    private var parentSize = CGSize.zero
    
    private var messageAreaSize = CGSize.zero
    private var keyboardHeight = CGFloat(0)
    
    override init(frame: CGRect) {
        backgroundView = UIToolbar()
        
        fieldBackground = UIView()
        fieldBackground.frame = CGRect(x: 40, y: 7.5, width: frame.width - 120, height: 35)
        fieldBackground.backgroundColor = UIColor.white
        fieldBackground.layer.borderColor = UIColor.lightGray.cgColor
        fieldBackground.layer.borderWidth = 0.5
        fieldBackground.layer.cornerRadius = 5
        fieldBackground.layer.masksToBounds = true
        
        let inputFiledClippingFrame = CGRect(x: fieldBackground.frame.origin.x + 4, y: fieldBackground.frame.origin.y + 4, width: fieldBackground.frame.width - 8, height: fieldBackground.frame.height - 8)
        inputFiledClippingContainer = UIView(frame: inputFiledClippingFrame)
        inputFiledClippingContainer.clipsToBounds = true
        
        inputField = HPGrowingTextView(frame: CGRect(x: inputFiledInternalEdgeInsets.left, y: inputFiledInternalEdgeInsets.top, width: inputFiledClippingFrame.width - inputFiledInternalEdgeInsets.left, height: inputFiledClippingFrame.height))
        inputField.animateHeightChange = false
        inputField.animationDuration = 0
        inputField.font = UIFont.systemFont(ofSize: 16)
        inputField.backgroundColor = UIColor.clear
        inputField.isOpaque = false
        inputField.clipsToBounds = true
        inputField.internalTextView.backgroundColor = UIColor.clear
        inputField.internalTextView.isOpaque = false
        inputField.internalTextView.contentMode = .left
        inputField.internalTextView.enablesReturnKeyAutomatically = true
        inputField.internalTextView.returnKeyType = .send
        inputField.internalTextView.scrollIndicatorInsets = UIEdgeInsets(top: -inputFiledInternalEdgeInsets.top, left: 0, bottom: 5 - MMRetinaPixel, right: 0)
    
        micButton = UIButton(type: .system)
        micButton.isExclusiveTouch = true
        micButton.setImage(UIImage(named: "MMVoice"), for: .normal)
        micButton.setImage(UIImage(named: "MMVoiceHL"), for: .highlighted)
        
        faceButton = UIButton(type: .system)
        faceButton.isExclusiveTouch = true
        faceButton.setImage(UIImage(named: "MMEmotion"), for: .normal)
        faceButton.setImage(UIImage(named: "MMEmotionHL"), for: .highlighted)

        
        attachButton = UIButton(type: .system)
        attachButton.isExclusiveTouch = true
        attachButton.setImage(UIImage(named: "MMAttach")!, for: .normal)
        attachButton.setImage(UIImage(named: "MMAttachHL"), for: .highlighted)
        
        super.init(frame: frame)
        
        addSubview(backgroundView)
        addSubview(fieldBackground)
        addSubview(inputFiledClippingContainer)
        
        inputField.maxNumberOfLines = maxNumberOfLines(forSize: parentSize)
        inputField.delegate = self
        inputFiledClippingContainer.addSubview(inputField)
        
        addSubview(micButton)
        addSubview(faceButton)
        addSubview(attachButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundView.frame = bounds
        
        fieldBackground.frame = CGRect(x: 40, y: 7.5, width: bounds.width - 120, height: bounds.height - 15)
        
        inputFiledClippingContainer.frame = CGRect(x: fieldBackground.frame.origin.x + 4, y: fieldBackground.frame.origin.y + 4, width: fieldBackground.frame.width - 8, height: fieldBackground.frame.height - 8)
        
        micButton.frame = CGRect(x: 0, y: bounds.size.height - baseHeight, width: 40, height: baseHeight)
        
        faceButton.frame = CGRect(x: bounds.size.width - 80, y: bounds.size.height - baseHeight, width: 40, height: baseHeight)
        
        attachButton.frame = CGRect(x: bounds.size.width - 40, y: bounds.height - baseHeight, width: 40, height: baseHeight)
        
    }
    
    override func endInputting(_ animated: Bool) {
        if inputField.internalTextView.isFirstResponder {
            inputField.internalTextView.resignFirstResponder()
        }
    }
    
    override func adjust(for size: CGSize, keyboardHeight: CGFloat, duration: TimeInterval, animationCurve: Int32) {
        let previousSize = parentSize
        parentSize = size
        
        if abs(size.width - previousSize.width) > MM_EPSILON {
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
        let newInputContainerFrame = CGRect(x: 0, y: messageAreaSize.height - keyboardHeight - inputContainerHeight, width: messageAreaSize.width, height: inputContainerHeight)
        
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
        let newInputContainerFrame = CGRect(x: 0, y: messageAreaSize.height - keyboardHeight - inputContainerHeight, width: messageAreaSize.width, height: inputContainerHeight)
        
        UIView.animate(withDuration: 0.3) {
            self.frame = newInputContainerFrame
            self.layoutSubviews()
        }
        
        delegate?.inputPanel(self, willChangeHeight: inputContainerHeight, duration: 0.3, animationCurve: 0)
    }
    
    func growingTextViewDidBeginEditing(_ growingTextView: HPGrowingTextView!) {
        if let d = delegate as? MMChatInputTextPanelDelegate {
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
            if str.characters.count > 0 {
                if let d = delegate as? MMChatInputTextPanelDelegate {
                    d.inputTextPanel(self, requestSendText: str)
                }
                clearInputField()
            }
            
            return false
        }
        
        return true
    }
    
    private func adjust(for size: CGSize, keyboardHeight: CGFloat, inputFiledHeight: CGFloat, duration: TimeInterval, animationCurve: Int32) {
        let block = {
            let messageAreaSize = size
            
            self.messageAreaSize = messageAreaSize
            self.keyboardHeight = keyboardHeight
            
            let inputContainerHeight = self.heightForInputFiledHeight(inputFiledHeight)
            self.frame = CGRect(x: 0, y: messageAreaSize.height - keyboardHeight - inputContainerHeight, width: self.messageAreaSize.width, height: inputContainerHeight)
            self.layoutSubviews()
        }
        
        if duration > .ulpOfOne {
            UIView .animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions(rawValue: UInt(animationCurve << 16)), animations: block, completion: nil)
        } else {
            block()
        }
    }
    
    private func heightForInputFiledHeight(_ inputFiledHeight: CGFloat) -> CGFloat {
        return max(baseHeight, inputFiledHeight - 8 + inputFiledInsets.top + inputFiledInsets.bottom + 8)
    }
    
    private func updateInputFiledLayout() {
        let range = inputField.internalTextView.selectedRange
        
        inputField.delegate = nil
        
        let inputFiledInsets = self.inputFiledInsets
        let inputFiledInternalEdgeInsets = self.inputFiledInternalEdgeInsets
        
        let inputFiledClippingFrame = CGRect(x: inputFiledInsets.left + 4, y: inputFiledInsets.top + 4, width: parentSize.width - inputFiledInsets.left - inputFiledInsets.right - 8, height: 0)
        
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
    
}

