/*
 The MIT License (MIT)

 Copyright (c) 2015-present Badoo Trading Limited.

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
*/

import UIKit

public enum CellVerticalEdge {
    case top
    case bottom
}

extension CGFloat {
    static let bma_epsilon: CGFloat = 0.001
}

extension ChatViewController {

    public func isScrolledAtBottom() -> Bool {
        guard collectionView.numberOfSections > 0 && collectionView.numberOfItems(inSection: 0) > 0 else { return true }
        let sectionIndex = collectionView.numberOfSections - 1
        let itemIndex = collectionView.numberOfItems(inSection: sectionIndex) - 1
        let lastIndexPath = IndexPath(item: itemIndex, section: sectionIndex)
        return isIndexPathVisible(lastIndexPath, atEdge: .bottom)
    }

    public func isScrolledAtTop() -> Bool {
        guard collectionView.numberOfSections > 0 && collectionView.numberOfItems(inSection: 0) > 0 else { return true }
        let firstIndexPath = IndexPath(item: 0, section: 0)
        return isIndexPathVisible(firstIndexPath, atEdge: .top)
    }

    public func isCloseToBottom() -> Bool {
        guard collectionView.contentSize.height > 0 else { return true }
        return (visibleRect().maxY / collectionView.contentSize.height) > (1 - constants.autoloadingFractionalThreshold)
    }

    public func isCloseToTop() -> Bool {
        guard collectionView.contentSize.height > 0 else { return true }
        return (visibleRect().minY / collectionView.contentSize.height) < constants.autoloadingFractionalThreshold
    }

    public func isIndexPathVisible(_ indexPath: IndexPath, atEdge edge: CellVerticalEdge) -> Bool {
        if let attributes = collectionView.collectionViewLayout.layoutAttributesForItem(at: indexPath) {
            let visibleRect = self.visibleRect()
            let intersection = visibleRect.intersection(attributes.frame)
            if edge == .top {
                return abs(intersection.minY - attributes.frame.minY) < CGFloat.bma_epsilon
            } else {
                return abs(intersection.maxY - attributes.frame.maxY) < CGFloat.bma_epsilon
            }
        }
        return false
    }

    public func visibleRect() -> CGRect {
        let contentInset = collectionView.contentInset
        let collectionViewBounds = collectionView.bounds
        let contentSize = collectionView.collectionViewLayout.collectionViewContentSize
        return CGRect(x: CGFloat(0), y: collectionView.contentOffset.y + contentInset.top, width: collectionViewBounds.width, height: min(contentSize.height, collectionViewBounds.height - contentInset.top - contentInset.bottom))
    }
    
    public func scrollToBottom(animated: Bool) {
        let contentHeight = collectionView.collectionViewLayout.collectionViewContentSize.height
        
        let boundsHeight = collectionView.bounds.height
        
        guard contentHeight >= 0 && contentHeight < 20000 && boundsHeight >= 0 else { return }
        
        // Note that we don't rely on collectionView's contentSize. This is because it won't be valid after performBatchUpdates or reloadData
        // After reload data, collectionViewLayout.collectionViewContentSize won't be even valid, so you may want to refresh the layout manually
        let offsetY = max(-collectionView.contentInset.top, contentHeight - boundsHeight + collectionView.contentInset.bottom)

        // Don't use setContentOffset(:animated). If animated, contentOffset property will be updated along with the animation for each frame update
        // If a message is inserted while scrolling is happening (as in very fast typing), we want to take the "final" content offset (not the "real time" one) to check if we should scroll to bottom again
        if animated {
            UIView.animate(withDuration: constants.updatesAnimationDuration, animations: { () -> Void in
                self.collectionView.contentOffset = CGPoint(x: 0, y: offsetY)
            })
        } else {
            collectionView.contentOffset = CGPoint(x: 0, y: offsetY)
        }
    }
    
    public func scrollToTop(animated: Bool) {
        let offsetY = -collectionView.contentInset.top

        if animated {
            UIView.animate(withDuration: constants.updatesAnimationDuration, animations: { () -> Void in
                self.collectionView.contentOffset = CGPoint(x: 0, y: offsetY)
            })
        } else {
            collectionView.contentOffset = CGPoint(x: 0, y: offsetY)
        }
    }

    public func scrollToPreservePosition(oldRefRect: CGRect?, newRefRect: CGRect?) {
        guard let oldRefRect = oldRefRect, let newRefRect = newRefRect else {
            return
        }
        let diffY = newRefRect.minY - oldRefRect.minY
        collectionView.contentOffset = CGPoint(x: 0, y: collectionView.contentOffset.y + diffY)
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if collectionView.isDragging {
            autoLoadMoreContentIfNeeded()
        }
    }

    public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        autoLoadMoreContentIfNeeded()
    }

    public func autoLoadMoreContentIfNeeded() {
        guard autoLoadingEnabled, let dataSource = chatDataSource else { return }

        if isCloseToTop() && dataSource.hasMorePrevious {
            dataSource.loadPrevious({ [weak self] () -> Void in
                self?.enqueueModelUpdate(context: .pagination)
            })
        } else if isCloseToBottom() && dataSource.hasMoreNext {
            dataSource.loadNext({ [weak self] () -> Void in
                self?.enqueueModelUpdate(context: .pagination)
            })
        }
    }
}
