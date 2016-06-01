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
        return self.dateFormatter.stringFromDate(self.message.date)
    }()
    
    public private(set) var message: MessageProtocol
    
    private let dateFormatter: NSDateFormatter
    
    deinit {
        guard let msg = message as? Message else { return }
        msg.removeObserver(self, forKeyPath: "deliveryStatus")
    }
    
    public init(dateFormatter: NSDateFormatter, message: MessageProtocol) {
        self.dateFormatter = dateFormatter
        self.message = message
        self.status = Observable(message.deliveryStatus.viewModelStatus())
        
        super.init()
        
        guard let msg = message as? Message else { return }
        msg.addObserver(self, forKeyPath: "deliveryStatus", options: .New, context: nil)
    }
    
    // MARK: KVO
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if let msg = object as? Message,
            keyPath = keyPath where keyPath == "deliveryStatus" {
                dispatch_async_safely_to_main_queue {
                    self.status.value = msg.deliveryStatus.viewModelStatus()
                }
                return
        }
        
        super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
    }
    
    public func getAvatar(completionHandler completionHandler: (UIImage? -> Void)?) {

    }
    
}

// MARK: MessageViewModelBuilder
public class MessageViewModelBuilder: MessageViewModelBuilderProtocol {
    public static let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    public init() {}
    
    public func createMessageViewModel(message message: MessageProtocol) -> MessageViewModelProtocol {
        return MessageViewModel(dateFormatter: MessageViewModelBuilder.dateFormatter, message: message)
    }
}

