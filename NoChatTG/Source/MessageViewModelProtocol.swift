//
//  MessageViewModelProtocol.swift
//  NoChat
//
//  Created by little2s on 16/3/17.
//  Copyright © 2016年 Ninty. All rights reserved.
//

import Foundation

// MARK: Enumerate
public enum MessageViewModelStatus {
    case sending
    case success
    case failure
}

extension MessageDeliveryStatus {
    public func viewModelStatus() -> MessageViewModelStatus {
        switch self {
        case .delivered:
            return .success
        case .failure:
            return .failure
        case .delivering:
            return .sending
        }
    }
}

// MARK: Protocol

// Why class? https://gist.github.com/diegosanchezr/29979d22c995b4180830
public protocol MessageViewModelProtocol: class {
    var isIncoming: Bool { get }
    var status: Observable<MessageViewModelStatus> { get set }
    var date: String { get }
    var message: MessageProtocol { get }
    var showAvatar : Bool { get }
    // Always asynchronous get avatar
    func getAvatar(_ completionHandler: ((UIImage?) -> Void)?)
}

// Use DecoratedMessageViewModelProtocol for extension MessageViewModel
// Do not use MessageViewModelProtocol directly
public protocol DecoratedMessageViewModelProtocol: MessageViewModelProtocol {
    var messageViewModel: MessageViewModelProtocol { get }
}

extension DecoratedMessageViewModelProtocol {
    public var isIncoming: Bool {
        return messageViewModel.isIncoming
    }
    
    // do not use this directly, because status is value type, a little tricky...
    public var status: Observable<MessageViewModelStatus> {
        set {
            messageViewModel.status = status
        }
        get {
            return messageViewModel.status
        }
    }
    
    public var date: String {
        return messageViewModel.date
    }
    
    public var message: MessageProtocol {
        return messageViewModel.message
    }
    
    public func getAvatar(_ completionHandler: ((UIImage?) -> Void)?) {
        return messageViewModel.getAvatar(completionHandler)
    }
}

public protocol MessageViewModelBuilderProtocol {
    func createMessageViewModel(_ message: MessageProtocol) -> MessageViewModelProtocol
}
