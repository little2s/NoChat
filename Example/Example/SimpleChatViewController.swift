//
//  SimpleChatViewController.swift
//  NoChatExample
//
//  Created by yinglun on 2020/8/15.
//  Copyright © 2020 little2s. All rights reserved.
//

import UIKit
import NoChat

class SimpleChatViewController: ChatViewController {
    
    private let dataSource = SimpleChatDataSource()
    
    private var inputCoordinator: SimpleInputCoordinator!
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.inputPanel = SimpleInputPanel()
        self.inputPanelDefaultHeight = SimpleInputPanel.Layout.baseHeight
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        inputCoordinator = SimpleInputCoordinator(chatViewController: self)
        dataSource.chatViewController = self
        dataSource.loadMessages()
    }
    
}


class SimpleChatDataSource {
    
    weak var chatViewController: SimpleChatViewController?
    
    private let layoutQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .userInitiated
        queue.name = "simple-chat-layout"
        return queue
    }()
    
    func loadMessages() {
        let width = UIScreen.main.bounds.width
        layoutQueue.addOperation {
            let messages: [Message] = [
                Message.text(from: "bot", content: "NoChat is a lightweight chat UI framework which has no particular faces. "),
                Message.text(from: "me", content: "The projects in Examples directory show you how to use this framework to implement a text game with user interface like Telegram or WeChat very easily."),
                Message.text(from: "me", content: "You can custom your own with NoChat :].")
            ]
            
            let layouts: [AnyItemLayout] = messages.map {
                var layout = TextMessageLayout(item: $0)
                layout.calculate(preferredWidth: width)
                return layout.toAny()
            }
            
            OperationQueue.main.addOperation {
                self.chatViewController?.layouts = layouts
                self.chatViewController?.collectionView.collectionViewLayout.prepare()
                self.chatViewController?.collectionView.reloadData()
                self.chatViewController?.collectionView.layoutIfNeeded()
            }
        }
    }
    
}
