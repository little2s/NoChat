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
    case Top
    case Bottom
}

extension CGFloat {
    static let bma_epsilon: CGFloat = 0.001
}

extension ChatViewController {

    public func isScrolledAtBottom() -> Bool {
        guard collectionView.numberOfSections() > 0 && collectionView.numberOfItemsInSection(0) > 0 else { return true }
        let sectionIndex = collectionView.numberOfSections() - 1
        let itemIndex = collectionView.numberOfItemsInSection(sectionIndex) - 1
        let lastIndexPath = NSIndexPath(forItem: itemIndex, inSection: sectionIndex)
        return isIndexPathVisible(lastIndexPath, atEdge: .Bottom)
    }

    public func isScrolledAtTop() -> Bool {
        guard collectionView.numberOfSections() > 0 && collectionView.numberOfItemsInSection(0) > 0 else { return true }
        let firstIndexPath = NSIndexPath(forItem: 0, inSection: 0)
        return isIndexPathVisible(firstIndexPath, atEdge: .Top)
    }

    public func isCloseToBottom() -> Bool {
        guard collectionView.contentSize.height > 0 else { return true }
        return (visibleRect().maxY / collectionView.contentSize.height) > (1 - constants.autoloadingFractionalThreshold)
    }

    public func isCloseToTop() -> Bool {
        guard collectionView.contentSize.height > 0 else { return true }
        return (visibleRect().minY / collectionView.contentSize.height) < constants.autoloadingFractionalThreshold
    }

    public func isIndexPathVisible(indexPath: NSIndexPath, atEdge edge: CellVerticalEdge) -> Bool {
        if let attributes = collectionView.collectionViewLayout.layoutAttributesForItemAtIndexPath(indexPath) {
            let visibleRect = self.visibleRect()
            let intersection = visibleRect.intersect(attributes.frame)
            if edge == .Top {
                return CGFloat.abs(intersection.minY - attributes.frame.minY) < CGFloat.bma_epsilon
            } else {
                return CGFloat.abs(intersection.maxY - attributes.frame.maxY) < CGFloat.bma_epsilon
            }
        }
        return false
    }

    public func visibleRect() -> CGRect {
        let contentInset = collectionView.contentInset
        let collectionViewBounds = collectionView.bounds
        let contentSize = collectionView.collectionViewLayout.collectionViewContentSize()
        return CGRect(x: CGFloat(0), y: collectionView.contentOffset.y + contentInset.top, width: collectionViewBounds.width, height: min(contentSize.height, collectionViewBounds.height - contentInset.top - contentInset.bottom))
    }
    
    public func scrollToBottom(animated animated: Bool) {
        let contentHeight = collectionView.collectionViewLayout.collectionViewContentSize().height
        
        let boundsHeight = collectionView.bounds.height
        
        guard contentHeight >= 0 && contentHeight < 20000 && boundsHeight >= 0 else { return }
        
        // Note that we don't rely on collectionView's contentSize. This is because it won't be valid after performBatchUpdates or reloadData
        // After reload data, collectionViewLayout.collectionViewContentSize won't be even valid, so you may want to refresh the layout manually
        let offsetY = max(-collectionView.contentInset.top, contentHeight - boundsHeight + collectionView.contentInset.bottom)

        // Don't use setContentOffset(:animated). If animated, contentOffset property will be updated along with the animation for each frame update
        // If a message is inserted while scrolling is happening (as in very fast typing), we want to take the "final" content offset (not the "real time" one) to check if we should scroll to bottom again
        if animated {
            UIView.animateWithDuration(constants.updatesAnimationDuration, animations: { () -> Void in
                self.collectionView.contentOffset = CGPoint(x: 0, y: offsetY)
            })
        } else {
            collectionView.contentOffset = CGPoint(x: 0, y: offsetY)
        }
    }
    
    public func scrollToTop(animated animated: Bool) {
        let offsetY = -collectionView.contentInset.top

        if animated {
            UIView.animateWithDuration(constants.updatesAnimationDuration, animations: { () -> Void in
                self.collectionView.contentOffset = CGPoint(x: 0, y: offsetY)
            })
        } else {
            collectionView.contentOffset = CGPoint(x: 0, y: offsetY)
        }
    }

    public func scrollToPreservePosition(oldRefRect oldRefRect: CGRect?, newRefRect: CGRect?) {
        guard let oldRefRect = oldRefRect, newRefRect = newRefRect else {
            return
        }
        let diffY = newRefRect.minY - oldRefRect.minY
        collectionView.contentOffset = CGPoint(x: 0, y: collectionView.contentOffset.y + diffY)
    }

    public func scrollViewDidScroll(scrollView: UIScrollView) {
        if collectionView.dragging {
            autoLoadMoreContentIfNeeded()
        }
    }

    public func scrollViewDidScrollToTop(scrollView: UIScrollView) {
        autoLoadMoreContentIfNeeded()
    }

    public func autoLoadMoreContentIfNeeded() {
        guard autoLoadingEnabled, let dataSource = chatDataSource else { return }

        if isCloseToTop() && dataSource.hasMorePrevious {
            dataSource.loadPrevious({ [weak self] () -> Void in
                self?.enqueueModelUpdate(context: .Pagination)
            })
        } else if isCloseToBottom() && dataSource.hasMoreNext {
            dataSource.loadNext({ [weak self] () -> Void in
                self?.enqueueModelUpdate(context: .Pagination)
            })
        }
    }
}
