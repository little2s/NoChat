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
    case Delivering
    case Delivered
    case Failure
    
    public var description: String {
        switch self {
        case .Delivering:
            return "Delivering"
        case .Delivered:
            return "Delivered"
        case .Failure:
            return "Failure"
        }
    }
}

@objc
public enum MessageAttachmentTransferDirection: Int, CustomStringConvertible {
    case Upload
    case Download
    
    public var description: String {
        switch self {
        case .Upload:
            return "Upload"
        case .Download:
            return "Download"
        }
    }
}

@objc
public enum MessageAttachmentTransferStatus: Int, CustomStringConvertible {
    case Idle
    case Transfering
    case Success
    case Failure
    
    public var description: String {
        switch self {
        case .Idle:
            return "Idle"
        case .Transfering:
            return "Transfering"
        case .Success:
            return "Success"
        case .Failure:
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
    var date: NSDate { get }
    var deliveryStatus: MessageDeliveryStatus { get set }
    var attachments: [MessageAttachmentProtocol] { get }
    var content: String { get }
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