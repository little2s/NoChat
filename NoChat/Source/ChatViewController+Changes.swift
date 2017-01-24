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

import Foundation

// MARK: ChatCollectionViewLayoutDelegate
extension ChatViewController: ChatCollectionViewLayoutDelegate {
    public func chatCollectionViewLayoutModel() -> ChatCollectionViewLayoutModel {
        if self.layoutModel.calculatedForWidth != self.collectionView.bounds.width {
            self.layoutModel = self.createLayoutModel(self.decoratedChatItems, collectionViewWidth: self.collectionView.bounds.width)
            
        }
        return self.layoutModel
    }
}

// MARK: ChatDataSourceDelegateProtocol
extension ChatViewController: ChatDataSourceDelegateProtocol {
    public func chatDataSourceDidUpdate(_ chatDataSource: ChatDataSourceProtocol) {
        self.enqueueModelUpdate(context: .normal)
    }
    
    public func chatDataSourceDidUpdate(_ chatDataSource: ChatDataSourceProtocol, updateType: UpdateContext) {
        self.enqueueModelUpdate(context: updateType)
    }
}

public enum UpdateContext {
    case normal
    case firstLoad
    case pagination
    case reload
    case messageCountReduction
}

// MARK: Methods for change
extension ChatViewController {

    

    public func enqueueModelUpdate(context: UpdateContext) {
        let newItems = self.chatDataSource?.chatItems ?? []
        
        
        self.updateQueue.addTask({ [weak self] (completion) -> () in
            guard let sSelf = self else { return }

            let oldItems = sSelf.decoratedChatItems.map { $0.chatItem }
            sSelf.updateModels(newItems: newItems, oldItems: oldItems, context: context, completion: {
                if sSelf.updateQueue.isEmpty {
                    sSelf.enqueueMessageCountReductionIfNeeded()
                }
                completion()
            })
        })
    }

    public func enqueueMessageCountReductionIfNeeded() {
        guard let preferredMaxMessageCount = self.constants.preferredMaxMessageCount , (self.chatDataSource?.chatItems.count ?? 0) > preferredMaxMessageCount else { return }
        self.updateQueue.addTask { [weak self] (completion) -> () in
            guard let sSelf = self else { return }
            sSelf.chatDataSource?.adjustNumberOfMessages(preferredMaxCount: sSelf.constants.preferredMaxMessageCountAdjustment, focusPosition: sSelf.focusPosition, completion: { (didAdjust) -> Void in
                guard didAdjust, let sSelf = self else {
                    completion()
                    return
                }
                let newItems = sSelf.chatDataSource?.chatItems ?? []
                let oldItems = sSelf.decoratedChatItems.map { $0.chatItem }
                sSelf.updateModels(newItems: newItems, oldItems: oldItems, context: .messageCountReduction, completion: completion )
            })
        }
    }

    // Returns scrolling position in interval [0, 1], 0 top, 1 bottom
    public var focusPosition: Double {
        if self.isCloseToBottom() {
            return 1
        } else if self.isCloseToTop() {
            return 0
        }

        let contentHeight = self.collectionView.contentSize.height
        guard contentHeight > 0 else {
            return 0.5
        }

        // Rough estimation
        let midContentOffset = self.collectionView.contentOffset.y + self.visibleRect().height / 2
        return min(max(0, Double(midContentOffset / contentHeight)), 1.0)
    }

    func updateVisibleCells(_ changes: CollectionChanges) {
        // Datasource should be already updated!

        let visibleIndexPaths = Set(self.collectionView.indexPathsForVisibleItems.filter { (indexPath) -> Bool in
            return !changes.insertedIndexPaths.contains(indexPath) && !changes.deletedIndexPaths.contains(indexPath)
        })

        var updatedIndexPaths = Set<IndexPath>()
        for move in changes.movedIndexPaths {
            updatedIndexPaths.insert(move.indexPathOld as IndexPath)
            if let cell = self.collectionView.cellForItem(at: move.indexPathOld as IndexPath) {
                self.presenterForIndexPath(move.indexPathNew).configureCell(cell, decorationAttributes: self.decorationAttributesForIndexPath(move.indexPathNew))
            }
        }

        // Update remaining visible cells
        let remaining = visibleIndexPaths.subtracting(updatedIndexPaths)
        for indexPath in remaining {
            if let cell = self.collectionView.cellForItem(at: indexPath) {
                self.presenterForIndexPath(indexPath).configureCell(cell, decorationAttributes: self.decorationAttributesForIndexPath(indexPath))
            }
        }
    }

    func performBatchUpdates(
        updateModelClosure: @escaping () -> Void,
        changes: CollectionChanges,
        context: UpdateContext,
        completion: @escaping () -> Void) {
            let shouldScrollToBottom = context != .pagination
            let oldRect = self.rectAtIndexPath(changes.movedIndexPaths.first?.indexPathOld)
            let myCompletion = {
                // Found that cells may not match correct index paths here yet! (see comment below)
                // Waiting for next loop seems to fix the issue
                DispatchQueue.main.async(execute: { () -> Void in
                    completion()
                })
            }

            if context == .normal {

                UIView.animate(withDuration: self.constants.updatesAnimationDuration, animations: { () -> Void in
                    // We want to update visible cells to support easy removal of bubble tail or any other updates that may be needed after a data update
                    // Collection view state is not constistent after performBatchUpdates. It can happen that we ask a cell for an index path and we still get the old one.
                    // Visible cells can be either updated in completion block (easier but with delay) or before, taking into account if some cell is gonna be moved

                    updateModelClosure()
                    self.updateVisibleCells(changes)

                    self.collectionView.performBatchUpdates({ () -> Void in
                        self.collectionView.deleteItems(at: Array(changes.deletedIndexPaths) as [IndexPath])
                        self.collectionView.insertItems(at: Array(changes.insertedIndexPaths) as [IndexPath])
                        for move in changes.movedIndexPaths {
                            self.collectionView.moveItem(at: move.indexPathOld as IndexPath, to: move.indexPathNew as IndexPath)
                        }
                    }) { (finished) -> Void in
                        myCompletion()
                    }
                })
        
            } else {
                updateModelClosure()
                self.collectionView.reloadData()
                self.collectionView.collectionViewLayout.prepare()
                myCompletion()
            }

            if shouldScrollToBottom {
                if inverted {
                    self.scrollToTop(animated: context == .normal)
                } else {
                    self.scrollToBottom(animated: context == .normal)
                }
            } else {
                let newRect = self.rectAtIndexPath(changes.movedIndexPaths.first?.indexPathNew)
                self.scrollToPreservePosition(oldRefRect: oldRect, newRefRect: newRect)
            }
    }

    private func updateModels(newItems: [ChatItemProtocol], oldItems: [ChatItemProtocol], context: UpdateContext, completion: @escaping () -> Void) {
        let collectionViewWidth = self.collectionView.bounds.width
        let realContext = self.isFirstLayout ? .firstLoad : context
        let performInBackground = realContext != .firstLoad

        self.autoLoadingEnabled = false
        let perfomBatchUpdates: (_ changes: CollectionChanges, _ updateModelClosure: @escaping () -> Void) -> ()  = { [weak self] (changes, updateModelClosure) in
            self?.performBatchUpdates(
                updateModelClosure: updateModelClosure,
                changes: changes,
                context: realContext,
                completion: { () -> Void in
                    self?.autoLoadingEnabled = true
                    completion()
            })
        }

        let createModelUpdate = {
            return self.createModelUpdates(
                newItems: newItems,
                oldItems: oldItems,
                collectionViewWidth:collectionViewWidth)
        }

        if performInBackground {
            DispatchQueue.global(qos: .userInitiated).async { () -> Void in
                let modelUpdate = createModelUpdate()
                DispatchQueue.main.async(execute: { () -> Void in
                    perfomBatchUpdates(modelUpdate.changes, modelUpdate.updateModelClosure)
                })
            }
        } else {
            let modelUpdate = createModelUpdate()
            perfomBatchUpdates(modelUpdate.changes, modelUpdate.updateModelClosure)
        }
    }

    fileprivate func createModelUpdates(newItems: [ChatItemProtocol], oldItems: [ChatItemProtocol], collectionViewWidth: CGFloat) -> (changes: CollectionChanges, updateModelClosure: () -> Void) {
        let newDecoratedItems = self.chatItemsDecorator?.decorateItems(newItems, inverted: self.inverted) ?? newItems.map { DecoratedChatItem(chatItem: $0, decorationAttributes: nil) }
        let changes = generateChanges(
            oldCollection: oldItems.map { $0 },
            newCollection: newDecoratedItems.map { $0.chatItem })
        let layoutModel = self.createLayoutModel(newDecoratedItems, collectionViewWidth: collectionViewWidth)
        let updateModelClosure : () -> Void = { [weak self] in
            self?.layoutModel = layoutModel
            self?.decoratedChatItems = newDecoratedItems
        }
        return (changes, updateModelClosure)
    }

    fileprivate func createLayoutModel(_ decoratedItems: [DecoratedChatItem], collectionViewWidth: CGFloat) -> ChatCollectionViewLayoutModel {
        typealias IntermediateItemLayoutData = (height: CGFloat?, bottomMargin: CGFloat)
        typealias ItemLayoutData = (height: CGFloat, bottomMargin: CGFloat)

        func createLayoutModel(intermediateLayoutData: [IntermediateItemLayoutData]) -> ChatCollectionViewLayoutModel {
            let layoutData = intermediateLayoutData.map { (intermediateLayoutData: IntermediateItemLayoutData) -> ItemLayoutData in
                return (height: intermediateLayoutData.height!, bottomMargin: intermediateLayoutData.bottomMargin)
            }
            return ChatCollectionViewLayoutModel.createModel(self.collectionView.bounds.width, itemsLayoutData: layoutData)
        }

        let isInbackground = !Thread.isMainThread
        var intermediateLayoutData = [IntermediateItemLayoutData]()
        var itemsForMainThread = [(index: Int, item: DecoratedChatItem, presenter: ChatItemPresenterProtocol?)]()

        for (index, decoratedItem) in decoratedItems.enumerated() {
            let presenter = self.presenterForIndex(index, decoratedChatItems: decoratedItems)
            var height: CGFloat?
            let bottomMargin: CGFloat = decoratedItem.decorationAttributes?.bottomMargin ?? 0
            if !isInbackground || presenter.canCalculateHeightInBackground {
                height = presenter.heightForCell(maximumWidth: collectionViewWidth, decorationAttributes: decoratedItem.decorationAttributes)
            } else {
                itemsForMainThread.append((index: index, item: decoratedItem, presenter: presenter))
            }
            intermediateLayoutData.append((height: height, bottomMargin: bottomMargin))
        }

        if itemsForMainThread.count > 0 {
            DispatchQueue.main.sync(execute: { () -> Void in
                for (index, decoratedItem, presenter) in itemsForMainThread {
                    let height = presenter?.heightForCell(maximumWidth: collectionViewWidth, decorationAttributes: decoratedItem.decorationAttributes)
                    intermediateLayoutData[index].height = height
                }
            })
        }
        return createLayoutModel(intermediateLayoutData: intermediateLayoutData)
    }
}


