//
//  Message.swift
//  NoChatExample
//
//  Created by yinglun on 2020/8/15.
//  Copyright © 2020 little2s. All rights reserved.
//

import Foundation
import NoChat

struct Message {
    
    enum Body {
        case text(String)
    }
    
    let id: String
    
    let body: Body
    
    let from: String
    let to: String
    
    let date: Date
    
    static func text(id: String = ProcessInfo.processInfo.globallyUniqueString, from: String, content: String) -> Message {
        return Message(id: id, body: .text(content), from: from, to: "", date: Date())
    }
}

extension Message: Identifiable {
    var uniqueIdentifier: String { id }
    
    var isOutgoing: Bool { from == "me" }
}
