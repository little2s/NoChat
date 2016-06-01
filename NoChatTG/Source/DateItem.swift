//
//  DateItem.swift
//  NoChat
//
//  Created by little2s on 16/4/7.
//  Copyright © 2016年 Ninty. All rights reserved.
//

import Foundation
import NoChat

public class DateItem: ChatItemProtocol {
    public static let itemType: ChatItemType = "DateItem"
    
    public let uid: String
    public let date: NSDate
    public var type: String {
        return DateItem.itemType
    }
    
    public init(uid: String, date: NSDate) {
        self.uid = uid
        self.date = date
    }
}