//
//  ChatItemDecorationAttributes.swift
//  NoChatMM
//
//  Created by little2s on 16/5/17.
//  Copyright © 2016年 little2s. All rights reserved.
//

import Foundation
import NoChat

public struct ChatItemDecorationAttributes: ChatItemDecorationAttributesProtocol {
    public let bottomMargin: CGFloat
    public init(bottomMargin: CGFloat) {
        self.bottomMargin = bottomMargin
    }
}