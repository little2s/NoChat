//
//  ConversationViewController.swift
//  Demo
//
//  Created by little2s on 16/5/10.
//  Copyright © 2016年 little2s. All rights reserved.
//

import UIKit
import NoChat
import NoChatTG

class TGChatViewController: ChatViewController {
    
    lazy var titleView: TitleView! = {
        let view = TitleView()
        return view
    }()
    
    lazy var avatarButton: AvatarButton! = {
        let button = AvatarButton()
        return button
    }()
    
    override var title: String? {
        set {
            titleView.titleLabel.text = newValue
        }
        get {
            return titleView.titleLabel.text
        }
    }
    
    let messageLayoutCache = NSCache()
    
    override func viewDidLoad() {
        inverted = true
        super.viewDidLoad()
        
        wallpaperView.image = UIImage(named: "TGWallpaper")!
        
        navigationItem.titleView = titleView
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        spacer.width = -12
        
        let right = UIBarButtonItem(customView: avatarButton)
        
        navigationItem.rightBarButtonItems = [spacer, right]
    }

    
    // Setup chat items
    override func createPresenterBuilders() -> [ChatItemType: [ChatItemPresenterBuilderProtocol]] {
        return [
            DateItem.itemType : [
                DateItemPresenterBuider()
            ],
            MessageType.Text.rawValue : [
                MessagePresenterBuilder<TextBubbleView, TGTextMessageViewModelBuilder>(
                    viewModelBuilder: TGTextMessageViewModelBuilder(),
                    layoutCache: messageLayoutCache
                )
            ]
        ]
    }
    
    // Setup chat input views
    override func createChatInputViewController() -> UIViewController {
        let inputController = NoChatTG.ChatInputViewController()
        
        inputController.onSendText = { [weak self] text in
            self?.sendText(text)
        }
        
        inputController.onChooseAttach = { [weak self] in
            self?.showAttachSheet()
        }
        
        return inputController
    }
    
}

extension TGChatViewController {
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        messageLayoutCache.removeAllObjects()
        
        if size.width > size.height {
            titleView.horizontalLayout()
            avatarButton.horizontalLayout()
        } else {
            titleView.verticalLayout()
            avatarButton.verticalLayout()
        }
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
}

extension TGChatViewController {
    func sendText(text: String) {
        let message = TGMessageFactory.createTextMessage(text: text, senderId: "outgoing", isIncoming: false)
        (self.chatDataSource as! TGChatDataSource).addMessages([message])
    }
    
    func showAttachSheet() {
        let sheet = UIAlertController(title: "Choose attchment", message: "", preferredStyle: .ActionSheet)
        
        sheet.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { _ in
        }))
        
        sheet.addAction(UIAlertAction(title: "Photos", style: .Default, handler: { _ in
        }))
        
        sheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        presentViewController(sheet, animated: true, completion: nil)
    }
}

class TitleView: UIView {
    
    var titleLabel: UILabel!
    var detailLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let titleFont: UIFont
        if #available(iOS 8.2, *) {
            titleFont = UIFont.systemFontOfSize(16, weight: UIFontWeightMedium)
        } else {
            titleFont = UIFont(name: "HelveticaNeue-Medium", size: 16)!
        }
        
        titleLabel = UILabel()
        titleLabel.font = titleFont
        titleLabel.textColor = UIColor.blackColor()
        titleLabel.textAlignment = .Center
        addSubview(titleLabel)
        
        detailLabel = UILabel()
        detailLabel.font = UIFont.systemFontOfSize(12)
        detailLabel.textColor = UIColor.grayColor()
        detailLabel.textAlignment = .Center
        addSubview(detailLabel)
        
        detailLabel.text = "last seen yesterday at 5:56 PM"
        
        verticalLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func verticalLayout() {
        frame = CGRect(x: 0, y: 0, width: 200, height: 44)
        
        titleLabel.frame = CGRect(x: 0, y: 4, width: frame.width, height: 21)
        detailLabel.frame = CGRect(x: 0, y: titleLabel.frame.maxY + 2, width: frame.width, height: 15)
    }
    
    func horizontalLayout() {
        frame = CGRect(x: 0, y: 0, width: 300, height: 40)
        
        let titleSize = titleLabel.sizeThatFits(CGSize(width: CGFloat.max, height: 21))
        let detailSize = detailLabel.sizeThatFits(CGSize(width: CGFloat.max, height: 15))
        
        let contentWidth = titleSize.width + 6 + detailSize.width
        
        var currentX = frame.width / 2 - contentWidth / 2
        
        titleLabel.frame = CGRect(x: currentX, y: frame.height / 2 - titleSize.height / 2, width: titleSize.width, height: titleSize.height)
        
        currentX += titleSize.width + 6
        
        detailLabel.frame = CGRect(x: currentX, y: frame.height / 2 - detailSize.height / 2, width: detailSize.width, height: detailSize.height)
    }
    
}

class AvatarButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setImage(UIImage(named: "TGUserInfo")!, forState: .Normal)
        
        verticalLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func verticalLayout() {
        frame = CGRect(x: 0, y: 0, width: 37, height: 37)
    }
    
    func horizontalLayout() {
        frame = CGRect(x: 0, y: 0, width: 28, height: 28)
    }
}


class TGTextMessageViewModel: TextMessageViewModel {

}

class TGTextMessageViewModelBuilder: MessageViewModelBuilderProtocol {
    
    private let messageViewModelBuilder = MessageViewModelBuilder()
    
    func createMessageViewModel(message message: MessageProtocol) -> MessageViewModelProtocol {
        let messageViewModel = messageViewModelBuilder.createMessageViewModel(message: message)
        messageViewModel.status.value = .Success
        let textMessageViewModel = TGTextMessageViewModel(text: message.content, messageViewModel: messageViewModel)
        return textMessageViewModel
    }
}