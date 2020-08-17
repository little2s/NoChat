//
//  ItemLayout.swift
//  
//
//  Created by yinglun on 2020/8/9.
//

import UIKit

public protocol Identifiable {
    var uniqueIdentifier: String { get }
}

public enum CellRegister {
    case `class`(AnyClass?)
    case nib(UINib?)
}

public protocol CellReuseIdentifiable {
    var cellReuseIdentifier: String { get }
    var cellRegister: CellRegister { get }
}

public protocol SizeCalculator {
    var size: CGSize { get }
    mutating func calculate(preferredWidth: CGFloat)
}

public protocol ItemLayout: Identifiable, CellReuseIdentifiable, SizeCalculator {
    associatedtype Item: Identifiable
    var item: Item { get }
    init(item: Item)
}

public extension ItemLayout {
    var uniqueIdentifier: String { item.uniqueIdentifier }
}

///Type erasured layout.
public struct AnyItemLayout: Identifiable, CellReuseIdentifiable, SizeCalculator {
    public var value: Any { layout }
    
    public var uniqueIdentifier: String { layout.uniqueIdentifier }
    
    public var cellReuseIdentifier: String { layout.cellReuseIdentifier }
    
    public var cellRegister: CellRegister { layout.cellRegister }

    public var size: CGSize { layout.size }

    private var layout: Identifiable & CellReuseIdentifiable & SizeCalculator
    
    init<T>(layout: T) where T: ItemLayout {
        self.layout = layout
    }
    
    public mutating func calculate(preferredWidth: CGFloat) {
        layout.calculate(preferredWidth: preferredWidth)
    }
    
}

public extension ItemLayout {
    func toAny() -> AnyItemLayout {
        return AnyItemLayout(layout: self)
    }
}
