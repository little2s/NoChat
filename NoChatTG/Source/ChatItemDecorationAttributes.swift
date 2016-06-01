//
//  ChatItemDecorationAttributes.swift
//  NoChatTG
//
//  Created by little2s on 16/5/17.
//  Copyright © 2016年 little2s. All rights reserved.
//

import Foundation
import NoChat

public struct ChatItemDecorationAttributes: ChatItemDecorationAttributesProtocol {
    public let bottomMargin: CGFloat
    public let showsTail: Bool
    public init(bottomMargin: CGFloat, showsTail: Bool) {
        self.bottomMargin = bottomMargin
        self.showsTail = showsTail
    }
}