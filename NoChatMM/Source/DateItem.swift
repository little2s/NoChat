//
//  DateItem.swift
//  NoChat
//
//  Created by little2s on 16/4/7.
//  Copyright © 2016年 Ninty. All rights reserved.
//

import Foundation
import NoChat

open class DateItem: ChatItemProtocol {
    open static let itemType: ChatItemType = "DateItem"
    
    open let uid: String
    open let date: Date
    open var type: String {
        return DateItem.itemType
    }
    
    public init(uid: String, date: Date) {
        self.uid = uid
        self.date = date
    }
}
