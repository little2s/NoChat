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

extension ChatViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.decoratedChatItems.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let presenter = self.presenterForIndexPath(indexPath)
        let cell = presenter.dequeueCell(collectionView: collectionView, indexPath: indexPath)
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // Carefull: this index path can refer to old data source after an update. Don't use it to grab items from the model
        // Instead let's use a mapping presenter <--> cell
        if let oldPresenterForCell = self.presentersByCell.object(forKey: cell) as? ChatItemPresenterProtocol {
            self.presentersByCell.removeObject(forKey: cell)
            oldPresenterForCell.cellWasHidden(cell)
        }
    }

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // Here indexPath should always referer to updated data source.
        let presenter = self.presenterForIndexPath(indexPath)
        
        // Should bind data to cell here, more detail:
        // https://medium.com/ios-os-x-development/perfect-smooth-scrolling-in-uitableviews-fd609d5275a5#.lst6ta91u
        let decorationAttributes = self.decorationAttributesForIndexPath(indexPath)
        presenter.configureCell(cell, decorationAttributes: decorationAttributes)
        
        self.presentersByCell.setObject(presenter, forKey: cell)
        
        presenter.cellWillBeShown(cell)
    }

    public func presenterForIndexPath(_ indexPath: IndexPath) -> ChatItemPresenterProtocol {
        return self.presenterForIndex((indexPath as NSIndexPath).item, decoratedChatItems: self.decoratedChatItems)
    }

    public func presenterForIndex(_ index: Int, decoratedChatItems: [DecoratedChatItem]) -> ChatItemPresenterProtocol {
        guard index < decoratedChatItems.count else {
            // This can happen from didEndDisplayingCell if we reloaded with less messages
            return DummyChatItemPresenter()
        }

        let chatItem = decoratedChatItems[index].chatItem
        if let presenter = self.presentersByChatItem.object(forKey: chatItem) as? ChatItemPresenterProtocol {
            return presenter
        }
        let presenter = self.createPresenterForChatItem(chatItem)
        self.presentersByChatItem.setObject(presenter, forKey: chatItem)
        return presenter
    }

    public func createPresenterForChatItem(_ chatItem: ChatItemProtocol) -> ChatItemPresenterProtocol {
        for builder in self.presenterBuildersByType[chatItem.type] ?? [] {
            if builder.canHandleChatItem(chatItem) {
                return builder.createPresenterWithChatItem(chatItem)
            }
        }
        return DummyChatItemPresenter()
    }

    public func decorationAttributesForIndexPath(_ indexPath: IndexPath) -> ChatItemDecorationAttributesProtocol? {
        return self.decoratedChatItems[(indexPath as NSIndexPath).item].decorationAttributes
    }
}
