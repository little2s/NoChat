//
//  ItemsView.swift
//  
//
//  Created by yinglun on 2020/8/9.
//

import UIKit

open class ItemsView: UICollectionView {
    
    open var contentInsetChangedAction: (() -> Void)?
    
    open override var contentInset: UIEdgeInsets {
        didSet {
            scrollIndicatorInsets = contentInset
            contentInsetChangedAction?()
        }
    }
    
    open var tapAction: (() -> Void)?
    
    open var tapGestureRecognizer: UITapGestureRecognizer?
    
    open var isInverted: Bool = false {
        didSet {
            if isInverted {
                transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
            } else {
                transform = .identity
            }
        }
    }
    
    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = UIColor.clear
        showsVerticalScrollIndicator = true
        showsHorizontalScrollIndicator = false
        scrollsToTop = false
        alwaysBounceVertical = true
        contentInsetAdjustmentBehavior = .never
        setupTapGestureRecognizer()
    }
    
    private func setupTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapped))
        tapGestureRecognizer.cancelsTouchesInView = false
        addGestureRecognizer(tapGestureRecognizer)
        self.tapGestureRecognizer = tapGestureRecognizer
    }
    
    @objc private func onTapped() {
        tapAction?()
    }
    
    // MARK: - Change
        
    public struct Change {
        public var insertIndexPathes: [IndexPath] = []
        public var deleteIndexPathes: [IndexPath] = []
        public var updateIndexPahtes: [IndexPath] = []
        public init(insertIndexPathes: [IndexPath] = [], deleteIndexPathes: [IndexPath] = [], updateIndexPahtes: [IndexPath] = []) {
            self.insertIndexPathes = insertIndexPathes
            self.deleteIndexPathes = deleteIndexPathes
            self.updateIndexPahtes = updateIndexPahtes
        }
    }
    
    open func performChange(_ change: Change, animated: Bool, completion: (() -> Void)? = nil) {
        if animated {
            performBatchUpdates({
                if change.insertIndexPathes.count > 0 {
                    self.insertItems(at: change.insertIndexPathes)
                }
                if change.deleteIndexPathes.count > 0 {
                    self.deleteItems(at: change.deleteIndexPathes)
                }
                if change.updateIndexPahtes.count > 0 {
                    self.reloadItems(at: change.updateIndexPahtes)
                }
            }, completion: { _ in
                completion?()
            })
        } else {
            collectionViewLayout.prepare()
            reloadData()
            layoutIfNeeded()
            completion?()
        }
    }
    
    // MARK: - Scrolling
    
    open var scrollFractionalThreshold: CGFloat = 0.05
    
    ///
    /// These scrolling methods already deal with inverted mode for you.
    /// For example `isScrolledAtBottom`, the `bottom` is the bottom you see on screen,
    /// maybe not real bottom of collectionView.
    ///
    open var isCloseToTop: Bool {
        isInverted ? isCloseToCollectionViewBottom() : isCloseToCollectionViewTop()
    }
    
    open var isScrolledAtTop: Bool {
        isInverted ? isScrolledAtCollectionViewBottom() : isScrolledAtCollectionViewTop()
    }
    
    open func scrollToTop(animated: Bool) {
        if isInverted {
            scrollToCollectionViewBottom(animated: animated)
        } else {
            scrollToCollectionViewTop(animated: animated)
        }
    }
    
    open var isCloseToBottom: Bool {
        isInverted ? isCloseToCollectionViewTop() : isCloseToCollectionViewBottom()
    }
    
    open var isScrolledAtBottom: Bool {
        isInverted ? isScrolledAtCollectionViewTop() : isScrolledAtCollectionViewBottom()
    }
    
    open func scrollToBottom(animated: Bool) {
        if isInverted {
            scrollToCollectionViewTop(animated: animated)
        } else {
            scrollToCollectionViewBottom(animated: animated)
        }
    }
    
    open func stopScrollIfNeeded() {
        if isTracking || isDragging || isDecelerating {
            setContentOffset(contentOffset, animated: false)
        }
    }
    
    private func isCloseToCollectionViewTop() -> Bool {
        if contentSize.height > 0 {
            let minY = collectionViewVisibleRect().minY;
            return (minY / contentSize.height) < self.scrollFractionalThreshold;
        } else {
            return true
        }
    }
    
    private func isScrolledAtCollectionViewTop() -> Bool {
        if numberOfSections > 0, numberOfItems(inSection: 0) > 0 {
            let firstIndexPath = IndexPath(item: 0, section: 0)
            return isIndexPathOfCollectionViewVisible(indexPath: firstIndexPath, edge: .top)
        } else {
            return true
        }
    }
    
    private func scrollToCollectionViewTop(animated: Bool) {
        var contentOffset = self.contentOffset
        contentOffset.y = -contentInset.top
        setContentOffset(contentOffset, animated: animated)
    }
    
    private func isCloseToCollectionViewBottom() -> Bool {
        if contentSize.height > 0 {
            let maxY = collectionViewVisibleRect().maxY;
            return (maxY / contentSize.height) > (1 - self.scrollFractionalThreshold);
        } else {
            return true
        }
    }
    
    private func isScrolledAtCollectionViewBottom() -> Bool {
        let count = numberOfItems(inSection: 0)
        if numberOfSections > 0, count > 0 {
            let lastIndexPath = IndexPath(item: count - 1, section: 0)
            return isIndexPathOfCollectionViewVisible(indexPath: lastIndexPath, edge: .bottom)
        } else {
            return true
        }
    }
    
    private func scrollToCollectionViewBottom(animated: Bool) {
        let contentHeight = collectionViewLayout.collectionViewContentSize.height
        let boundsHeight = bounds.height
        guard contentHeight >= 0, boundsHeight >= 0 else { return }
        let offsetY = max(-contentInset.top, contentHeight - boundsHeight + contentInset.bottom)
        var contentOffset = self.contentOffset
        contentOffset.y = offsetY
        setContentOffset(contentOffset, animated: animated)
    }
    
    private enum VerticalEdge {
        case top
        case bottom
    }
    
    private func isIndexPathOfCollectionViewVisible(indexPath: IndexPath, edge: VerticalEdge) -> Bool {
        guard let layoutAttributes = collectionViewLayout.layoutAttributesForItem(at: indexPath) else { return false }
        let visibleRect = collectionViewVisibleRect()
        let cellRect = layoutAttributes.frame
        let intersection = visibleRect.intersection(cellRect)
        switch edge {
        case .top:
            return abs(intersection.minY - cellRect.minY) < .ulpOfOne
        case .bottom:
            return abs(intersection.maxY - cellRect.maxY) < .ulpOfOne
        }
    }
    
    private func collectionViewVisibleRect() -> CGRect {
        let contentInset = self.contentInset
        let bounds = self.bounds
        let contentSize = collectionViewLayout.collectionViewContentSize
        let contentOffset = self.contentOffset
        return CGRect(x: 0, y: contentOffset.y + contentInset.top, width: bounds.width, height: min(contentSize.height, bounds.height - contentInset.top - contentInset.bottom))
    }
    
}
