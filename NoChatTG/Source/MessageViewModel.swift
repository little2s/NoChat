//
//  MessageViewModel.swift
//  NoChat
//
//  Created by little2s on 16/3/17.
//  Copyright © 2016年 Ninty. All rights reserved.
//

import Foundation

// MARK: MessageViewModel
public class MessageViewModel: NSObject, MessageViewModelProtocol {
    public var isIncoming: Bool {
        return message.isIncoming
    }
    
    public var status: Observable<MessageViewModelStatus>
    
    public lazy var date: String = {
        return self.dateFormatter.string(from: self.message.date as Date)
    }()
    
    public private(set) var message: MessageProtocol
    
    private let dateFormatter: DateFormatter
    
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
    
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let msg = object as? Message,
            let keyPath = keyPath, keyPath == "deliveryStatus" {
            dispatch_async_safely_to_main_queue {
                self.status.value = msg.deliveryStatus.viewModelStatus()
            }
            return
        }
        
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
    
    public func getAvatar(completionHandler: ((UIImage?) -> Void)?) {

    }
    
}

// MARK: MessageViewModelBuilder
public class MessageViewModelBuilder: MessageViewModelBuilderProtocol {
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    public init() {}
    
    public func createMessageViewModel(message: MessageProtocol) -> MessageViewModelProtocol {
        return MessageViewModel(dateFormatter: MessageViewModelBuilder.dateFormatter, message: message)
    }
}

