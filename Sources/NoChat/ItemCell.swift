//
//  ItemCell.swift
//  
//
//  Created by yinglun on 2020/8/9.
//

import UIKit

public protocol ItemCellDelegate: class { }

open class ItemCell: UICollectionViewCell {
    
    open class var reuseIdentifier: String { "\(Self.self)" }
    
    open weak var delegate: ItemCellDelegate?
    
    open var layout: AnyItemLayout? {
        didSet {
            if let size = layout?.size, size != itemView.frame.size {
                itemView.frame = CGRect(origin: .zero, size: size)
            }
        }
    }
    
    public let itemView = UIView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        itemView.frame = contentView.bounds
        contentView.addSubview(itemView)
    }
}
