//
//  BubbleViewPortocol.swift
//  NoChat
//
//  Created by little2s on 16/3/4.
//  Copyright © 2016年 little2s. All rights reserved.
//

import UIKit

public enum ViewContext {
    case normal
    case sizing // You may skip some cell updates for faster sizing
}

public protocol MaximumLayoutWidthSpecificable {
    var preferredMaxLayoutWidth: CGFloat { get set }
}

public protocol BackgroundSizingQueryable {
    var canCalculateSizeInBackground: Bool { get }
}

public protocol BubbleViewProtocol: MaximumLayoutWidthSpecificable, BackgroundSizingQueryable {
    static var bubbleIdentifier: String { get }
    var viewContext: ViewContext { get set }
    var messageViewModel: MessageViewModelProtocol! { get set }
    var selected: Bool { get set }
    func bubbleSizeThatFits(_ size: CGSize) -> CGSize
    func  performBatchUpdates(_ updateClosure: @escaping () -> Void, animated: Bool, completion: (() -> Void)?)
}
