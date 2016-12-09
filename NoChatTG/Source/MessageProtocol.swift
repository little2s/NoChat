//
//  MessageProtocol.swift
//  NoChat
//
//  Created by little2s on 16/3/17.
//  Copyright © 2016年 Ninty. All rights reserved.
//

import Foundation
import NoChat

// MARK: Enumerate
@objc
public enum MessageDeliveryStatus: Int, CustomStringConvertible { // can be KVO
    case delivering
    case delivered
    case failure
    
    public var description: String {
        switch self {
        case .delivering:
            return "Delivering"
        case .delivered:
            return "Delivered"
        case .failure:
            return "Failure"
        }
    }
}

@objc
public enum MessageAttachmentTransferDirection: Int, CustomStringConvertible {
    case upload
    case download
    
    public var description: String {
        switch self {
        case .upload:
            return "Upload"
        case .download:
            return "Download"
        }
    }
}

@objc
public enum MessageAttachmentTransferStatus: Int, CustomStringConvertible {
    case idle
    case transfering
    case success
    case failure
    
    public var description: String {
        switch self {
        case .idle:
            return "Idle"
        case .transfering:
            return "Transfering"
        case .success:
            return "Success"
        case .failure:
            return "Failure"
        }
    }
}

// MARK: Protocol
public protocol MessageAttachmentProtocol {
    var key: String { get }
    var transferDirection: MessageAttachmentTransferDirection { get set }
    var transferStatus: MessageAttachmentTransferStatus { get set }
    var transferProgress: Double { get set }
}

public protocol MessageProtocol: ChatItemProtocol {
    var msgId: String { get }
    var msgType: String { get }
    var senderId: String { get }
    var isIncoming: Bool { get }
    var date: Date { get }
    var deliveryStatus: MessageDeliveryStatus { get set }
    var attachments: [MessageAttachmentProtocol] { get }
    var content: String { get }
    var showAvatar: Bool { get }
}

// MARK: Default implemtation for ChatItemProtocol
extension MessageProtocol {
    public var uid: String { return msgId }
    public var type: ChatItemType { return msgType }
    
    public var hasAttachments: Bool {
        return !attachments.isEmpty
    }
    public var firstAttachment: MessageAttachmentProtocol? {
        return attachments.first
    }
}
