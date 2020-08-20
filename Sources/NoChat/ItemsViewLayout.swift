//
//  ItemsViewLayout.swift
//  
//
//  Created by yinglun on 2020/8/9.
//

import UIKit

public protocol ItemsViewLayoutDelegate: class {
    var layouts: [AnyItemLayout] { get set }
}

open class ItemsViewLayout: UICollectionViewLayout {
    
    open var inset: UIEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    
    private var isInverted: Bool { (collectionView as? ItemsView)?.isInverted ?? false }
    
    private var layoutAttributes: [UICollectionViewLayoutAttributes] = []
    private var contentSize: CGSize = .zero
    
    private var insertIndexPaths: [IndexPath] = []
    private var deleteIndexPaths: [IndexPath] = []
        
    open var hasLayoutAttributes: Bool { contentSize.height > .ulpOfOne }
    
    open override var collectionViewContentSize: CGSize { contentSize }
    
    open override func prepare() {
        super.prepare()
        guard let collectionView = self.collectionView else { return }
        guard let delegate = collectionView.delegate as? ItemsViewLayoutDelegate else { return }
        layoutAttributes.removeAll()
        let contentWidth = collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right
        let (attributes, contentHeight) = layoutAttributesAndContentHeight(for: &delegate.layouts, containerWidth: contentWidth, maxHeight: .greatestFiniteMagnitude)
        layoutAttributes.append(contentsOf: attributes)
        contentSize = CGSize(width: contentWidth, height: contentHeight)
    }
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributesList: [UICollectionViewLayoutAttributes] = []
        for attributes in layoutAttributes {
            if rect.intersects(attributes.frame) {
                attributesList.append(attributes)
            }
        }
        return attributesList
    }
    
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard indexPath.item < layoutAttributes.count else { return nil }
        return layoutAttributes[indexPath.item]
    }
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return false
    }
    
    open func layoutAttributesAndContentHeight(for layouts: inout [AnyItemLayout], containerWidth: CGFloat, maxHeight: CGFloat) -> ([UICollectionViewLayoutAttributes], CGFloat) {
        var attributesList: [UICollectionViewLayoutAttributes] = []
        var y = inset.top
        for (index, layout) in layouts.enumerated() {
            let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: index, section: 0))
            var l = layout
            if abs(l.size.width - containerWidth) > .ulpOfOne {
                l.calculate(preferredWidth: containerWidth)
            }
            layouts[index] = l
            attributes.frame = CGRect(x: 0, y: y, width: l.size.width, height: l.size.height)
            attributesList.append(attributes)
            y += l.size.height
        }
        y += inset.bottom
        return (attributesList, min(y, maxHeight))
    }
    
    // MARK: - Animation
    
    open override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)
        guard isInverted else { return }
        self.deleteIndexPaths.removeAll()
        self.insertIndexPaths.removeAll()
        for updateItem in updateItems {
            switch updateItem.updateAction {
            case .delete:
                if let indexPath = updateItem.indexPathBeforeUpdate {
                    self.deleteIndexPaths.append(indexPath)
                }
            case .insert:
                if let indexPath = updateItem.indexPathAfterUpdate {
                    self.insertIndexPaths.append(indexPath)
                }
            default:
                break
            }
        }
    }
    
    open override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
        guard isInverted else { return }
        self.deleteIndexPaths.removeAll()
        self.insertIndexPaths.removeAll()
    }
    
    open override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        var attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
        guard isInverted else { return attributes }
        if insertIndexPaths.contains(itemIndexPath) {
            if attributes == nil {
                attributes = layoutAttributesForItem(at: itemIndexPath)
            }
            if let copyedAttributes = attributes?.copy() as? UICollectionViewLayoutAttributes {
                attributes = copyedAttributes
            }
            attributes?.transform3D = CATransform3DMakeTranslation(0, -floor(attributes!.frame.height * 1.125), 0)
            attributes?.alpha = 0
        }
        return attributes
    }
    
    open override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        var attributes = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)
        guard isInverted else { return attributes }
        if deleteIndexPaths.contains(itemIndexPath) {
            attributes = attributes?.copy() as? UICollectionViewLayoutAttributes
            attributes?.alpha = 0
        }
        return attributes
    }
}
