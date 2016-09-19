//
//  MessageViewModel.swift
//  NoChat
//
//  Created by little2s on 16/3/17.
//  Copyright © 2016年 Ninty. All rights reserved.
//

import Foundation

// MARK: MessageViewModel
open class MessageViewModel: NSObject, MessageViewModelProtocol {
    open var isIncoming: Bool {
        return message.isIncoming
    }
    
    open var status: Observable<MessageViewModelStatus>
    
    open lazy var date: String = {
        return self.dateFormatter.string(from: self.message.date as Date)
    }()
    
    open fileprivate(set) var message: MessageProtocol
    
    fileprivate let dateFormatter: DateFormatter
    
    deinit {
        guard let msg = message as? Message else { return }
        msg.removeObserver(self, forKeyPath: "deliveryStatus")
    }
    
    public init(dateFormatter: DateFormatter, message: MessageProtocol) {
        self.dateFormatter = dateFormatter
        self.message = message
        self.status = Observable(message.deliveryStatus.viewModelStatus())
        
        super.init()
        
        guard let msg = message as? Message else { return }
        msg.addObserver(self, forKeyPath: "deliveryStatus", options: .new, context: nil)
    }
    
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let msg = object as? Message,
            let keyPath = keyPath, keyPath == "deliveryStatus" {
            dispatch_async_safely_to_main_queue {
                self.status.value = msg.deliveryStatus.viewModelStatus()
            }
            return
        }
        
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
    
    open func getAvatar(_ completionHandler: ((UIImage?) -> Void)?) {

    }
    
}

// MARK: MessageViewModelBuilder
open class MessageViewModelBuilder: MessageViewModelBuilderProtocol {
    open static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    public init() {}
    
    open func createMessageViewModel(_ message: MessageProtocol) -> MessageViewModelProtocol {
        return MessageViewModel(dateFormatter: MessageViewModelBuilder.dateFormatter, message: message)
    }
}

