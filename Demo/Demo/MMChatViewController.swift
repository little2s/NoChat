//
//  MMChatViewController.swift
//  Demo
//
//  Created by little2s on 16/5/31.
//  Copyright © 2016年 little2s. All rights reserved.
//

import UIKit
import NoChat
import NoChatMM

class MMChatViewController: ChatViewController {
    
    let messageLayoutCache = NSCache<AnyObject, AnyObject>()
    
    override func viewDidLoad() {
        inverted = false
        defaultInputContainerHeight = 50
        super.viewDidLoad()
        
        wallpaperView.image = UIImage(named: "MMWallpaper")!
        
        let rightItem = UIBarButtonItem(image: UIImage(named: "MMUserInfo")!, style: .plain, target: self, action: #selector(didTapRightItem))
        navigationItem.rightBarButtonItem = rightItem
    }
    
    @objc
    func didTapRightItem() {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.barTintColor = UIColor(white: 0.1, alpha: 0.9)
        navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.barTintColor = nil
        navigationController?.navigationBar.tintColor = nil
        super.viewWillDisappear(animated)
    }
    
    // Setup chat items
    override func createPresenterBuilders() -> [ChatItemType: [ChatItemPresenterBuilderProtocol]] {
        return [
            DateItem.itemType : [
                DateItemPresenterBuider()
            ],
            
            MessageType.Text.rawValue : [
                MessagePresenterBuilder<TextBubbleView, MMTextMessageViewModelBuilder>(
                    viewModelBuilder: MMTextMessageViewModelBuilder(),
                    layoutCache: messageLayoutCache
                )
            ]
        ]
    }
    
    // Setup chat input views
    override func createChatInputViewController() -> UIViewController {
        let inputController = NoChatMM.ChatInputViewController()
        
        inputController.onSendText = { [weak self] text in
            self?.sendText(text: text)
        }
        
        return inputController
    }
    
}

extension MMChatViewController {
    override func viewWillTransition(to: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        messageLayoutCache.removeAllObjects()
        super.viewWillTransition(to: to, with: coordinator)
    }
}

extension MMChatViewController {
    func sendText(text: String) {
        let message = MMMessageFactory.createTextMessage(text: text, senderId: "outgoing", isIncoming: false)
        (self.chatDataSource as! MMChatDataSource).addMessages(messages: [message])
    }
}



class MMTextMessageViewModel: TextMessageViewModel {
    override func getAvatar(completionHandler: ((UIImage?) -> Void)?) {
        if message.senderId == "incoming" {
            let image = UIImage(named: "MMAvatarIncoming")
            completionHandler?(image)
        } else {
            let image = UIImage(named: "MMAvatarOutgoing")
            completionHandler?(image)
        }
    }
}

class MMTextMessageViewModelBuilder: MessageViewModelBuilderProtocol {
    
    private let messageViewModelBuilder = MessageViewModelBuilder()
    
    func createMessageViewModel(message: MessageProtocol) -> MessageViewModelProtocol {
        let messageViewModel = messageViewModelBuilder.createMessageViewModel(message: message)
        let textMessageViewModel = MMTextMessageViewModel(text: message.content, messageViewModel: messageViewModel)
        return textMessageViewModel
    }
}

