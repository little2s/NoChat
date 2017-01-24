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
    
    let messageLayoutCache = NSCache<AnyObject, AnyObject>()
    
    override func viewDidLoad() {
        inverted = true
        super.viewDidLoad()
        
        
        let icon = UIBarButtonItem(image: UIImage(named: "SLKIcon")!, style: .plain, target: self, action: #selector(didTapIcon))
        
        let titleFont: UIFont
        if #available(iOS 8.2, *) {
            titleFont = UIFont.systemFont(ofSize: 15, weight: UIFontWeightMedium)
        } else {
            titleFont = UIFont(name: "HelveticaNeue-Medium", size: 15)!
        }
        
        let title = UIBarButtonItem(title: self.title, style: .plain, target: nil, action: nil)
        title.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.black, NSFontAttributeName: titleFont], for: .normal)
        title.tintColor = UIColor.black
        
        let search = UIBarButtonItem(image: UIImage(named: "SLKSearch")!, style: .plain, target: nil, action: nil)
        search.tintColor = UIColor.darkGray
        
        let more = UIBarButtonItem(image: UIImage(named: "SLKMore")!, style: .plain, target: nil, action: nil)
        more.tintColor = UIColor.darkGray
        
        navigationItem.leftBarButtonItems = [icon, title]
        navigationItem.rightBarButtonItems = [more, search]
        navigationItem.titleView = UIView()
    }

    @objc
    func didTapIcon() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
            self?.sendText(text: text)
        }
        
        return inputController
    }
    
}

extension SLKChatViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension SLKChatViewController {
    override func viewWillTransition(to: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        messageLayoutCache.removeAllObjects()
        super.viewWillTransition(to: to, with: coordinator)
    }
}

extension SLKChatViewController {
    func sendText(text: String) {
        let message = SLKMessageFactory.createTextMessage(text: text, senderId: "outgoing", isIncoming: false)
        (self.chatDataSource as! SLKChatDataSource).addMessages(messages: [message])
    }
}

class SLKTextMessageViewModel: TextMessageViewModel {
    override func getAvatar(completionHandler: ((UIImage?) -> Void)?) {
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
    
    func createMessageViewModel(message: MessageProtocol) -> MessageViewModelProtocol {
        let messageViewModel = messageViewModelBuilder.createMessageViewModel(message: message)
        let textMessageViewModel = SLKTextMessageViewModel(text: message.content, messageViewModel: messageViewModel)
        return textMessageViewModel
    }
}
