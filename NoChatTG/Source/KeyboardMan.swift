//
//  KeyboardMan.swift
//  Messages
//
//  Created by NIX on 15/7/25.
//  Copyright (c) 2015年 nixWork. All rights reserved.
//

import UIKit

class KeyboardMan: NSObject {

    var keyboardObserver: NotificationCenter? {
        didSet {
            oldValue?.removeObserver(self)
            
            
            keyboardObserver?.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
            
            keyboardObserver?.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: .UIKeyboardWillChangeFrame, object: nil)
            
            keyboardObserver?.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
            
            keyboardObserver?.addObserver(self, selector: #selector(keyboardDidHide(_:)), name: .UIKeyboardDidHide, object: nil)
        }
    }

    var keyboardObserveEnabled = false {
        willSet {
            if newValue != keyboardObserveEnabled {
                keyboardObserver = newValue ? NotificationCenter.default : nil
            }
        }
    }

    deinit {
        // willSet and didSet are not called when deinit, so...
        NotificationCenter.default.removeObserver(self)
    }

    struct KeyboardInfo {

        let animationDuration: TimeInterval
        let animationCurve: UInt

        let frameBegin: CGRect
        let frameEnd: CGRect
        var height: CGFloat {
            return frameEnd.height
        }
        let heightIncrement: CGFloat

        enum Action {
            case Show
            case Hide
        }
        let action: Action
        let isSameAction: Bool
    }

    var appearPostIndex = 0

    var keyboardInfo: KeyboardInfo? {
        willSet {
            guard UIApplication.shared.applicationState != .background else {
                return
            }

            if let info = newValue {
                if !info.isSameAction || info.heightIncrement != 0 {

                    // do convenient animation

                    let duration = info.animationDuration
                    let curve = info.animationCurve
                    let options = UIViewAnimationOptions(rawValue: curve << 16 | UIViewAnimationOptions.beginFromCurrentState.rawValue)

                    UIView.animate(withDuration: duration, delay: 0, options: options, animations: {

                        switch info.action {

                        case .Show:
                            self.animateWhenKeyboardAppear?(self.appearPostIndex, info.height, info.heightIncrement)

                            self.appearPostIndex += 1

                        case .Hide:
                            self.animateWhenKeyboardDisappear?(info.height)

                            self.appearPostIndex = 0
                        }

                    }, completion: nil)

                    // post full info

                    postKeyboardInfo?(self, info)
                }
            }
        }
    }

    var animateWhenKeyboardAppear: ((_ appearPostIndex: Int, _ keyboardHeight: CGFloat, _ keyboardHeightIncrement: CGFloat) -> Void)? {
        didSet {
            keyboardObserveEnabled = true
        }
    }

    var animateWhenKeyboardDisappear: ((_ keyboardHeight: CGFloat) -> Void)? {
        didSet {
            keyboardObserveEnabled = true
        }
    }

    var postKeyboardInfo: ((_ keyboardMan: KeyboardMan, _ keyboardInfo: KeyboardInfo) -> Void)? {
        didSet {
            keyboardObserveEnabled = true
        }
    }

    // MARK: - Actions

     func handleKeyboard(_ notification: Notification, _ action: KeyboardInfo.Action) {

        if let userInfo = (notification as NSNotification).userInfo {

            let animationDuration: TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
            let animationCurve = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).uintValue
            let frameBegin = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
            let frameEnd = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue

            let currentHeight = frameEnd.height
            let previousHeight = keyboardInfo?.height ?? 0
            let heightIncrement = currentHeight - previousHeight

            let isSameAction: Bool
            if let previousAction = keyboardInfo?.action {
                isSameAction = action == previousAction
            } else {
                isSameAction = false
            }

            keyboardInfo = KeyboardInfo(
                animationDuration: animationDuration,
                animationCurve: animationCurve,
                frameBegin: frameBegin,
                frameEnd: frameEnd,
                heightIncrement: heightIncrement,
                action: action,
                isSameAction: isSameAction
            )
        }
    }

    func keyboardWillShow(_ notification: Notification) {

        guard UIApplication.shared.applicationState != .background else {
            return
        }

        handleKeyboard(notification, .Show)
    }
    
    func keyboardWillChangeFrame(_ notification: Notification) {

        guard UIApplication.shared.applicationState != .background else {
            return
        }

        if let keyboardInfo = keyboardInfo {

            if keyboardInfo.action == .Show {
                handleKeyboard(notification, .Show)
            }
        }
    }

    func keyboardWillHide(_ notification: Notification) {

        guard UIApplication.shared.applicationState != .background else {
            return
        }

        handleKeyboard(notification, .Hide)
    }

    func keyboardDidHide(_ notification: Notification) {

        guard UIApplication.shared.applicationState != .background else {
            return
        }

        keyboardInfo = nil
    }
}

