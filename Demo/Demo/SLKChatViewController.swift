//
//  SLKChatViewController.swift
//  Demo
//
//  Created by little2s on 16/6/1.
//  Copyright © 2016年 little2s. All rights reserved.
//

import UIKit
import NoChat
import NoChatSLK

class SLKChatViewController: ChatViewController {
    
    let messageLayoutCache = NSCache()
    
    override func viewDidLoad() {
        inverted = true
        super.viewDidLoad()
        
        
        let icon = UIBarButtonItem(image: UIImage(named: "SLKIcon")!, style: .Plain, target: self, action: #selector(didTapIcon))
        
        let titleFont: UIFont
        if #available(iOS 8.2, *) {
            titleFont = UIFont.systemFontOfSize(15, weight: UIFontWeightMedium)
        } else {
            titleFont = UIFont(name: "HelveticaNeue-Medium", size: 15)!
        }
        
        let title = UIBarButtonItem(title: self.title, style: .Plain, target: nil, action: nil)
        title.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.blackColor(), NSFontAttributeName: titleFont], forState: .Normal)
        title.tintColor = UIColor.blackColor()
        
        let search = UIBarButtonItem(image: UIImage(named: "SLKSearch")!, style: .Plain, target: nil, action: nil)
        search.tintColor = UIColor.darkGrayColor()
        
        let more = UIBarButtonItem(image: UIImage(named: "SLKMore")!, style: .Plain, target: nil, action: nil)
        more.tintColor = UIColor.darkGrayColor()
        
        navigationItem.leftBarButtonItems = [icon, title]
        navigationItem.rightBarButtonItems = [more, search]
        navigationItem.titleView = UIView()
    }

    @objc
    func didTapIcon() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    // Setup chat items
    override func createPresenterBuilders() -> [ChatItemType: [ChatItemPresenterBuilderProtocol]] {
        return [
            MessageType.Text.rawValue : [
                MessagePresenterBuilder<TextBubbleView, SLKTextMessageViewModelBuilder>(
                    viewModelBuilder: SLKTextMessageViewModelBuilder(),
                    layoutCache: messageLayoutCache
                )
            ]
        ]
    }
    
    // Setup chat input views
    override func createChatInputViewController() -> UIViewController {
        let inputController = NoChatSLK.ChatInputViewController()
        
        inputController.onSendText = { [weak self] text in
            self?.sendText(text)
        }
        
        return inputController
    }
    
}

extension SLKChatViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension SLKChatViewController {
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        messageLayoutCache.removeAllObjects()
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
}

extension SLKChatViewController {
    func sendText(text: String) {
        let message = SLKMessageFactory.createTextMessage(text: text, senderId: "outgoing", isIncoming: false)
        (self.chatDataSource as! SLKChatDataSource).addMessages([message])
    }
}

class SLKTextMessageViewModel: TextMessageViewModel {
    override func getAvatar(completionHandler completionHandler: (UIImage? -> Void)?) {
        if message.senderId == "incoming" {
            let image = UIImage(named: "SLKAvatarIncoming")
            completionHandler?(image)
        } else {
            let image = UIImage(named: "SLKAvatarOutgoing")
            completionHandler?(image)
        }
    }
}

class SLKTextMessageViewModelBuilder: MessageViewModelBuilderProtocol {
    
    private let messageViewModelBuilder = MessageViewModelBuilder()
    
    func createMessageViewModel(message message: MessageProtocol) -> MessageViewModelProtocol {
        let messageViewModel = messageViewModelBuilder.createMessageViewModel(message: message)
        let textMessageViewModel = SLKTextMessageViewModel(text: message.content, messageViewModel: messageViewModel)
        return textMessageViewModel
    }
}
