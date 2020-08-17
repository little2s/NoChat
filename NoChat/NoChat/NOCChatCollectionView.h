//
//  NOCChatCollectionView.h
//  NoChat
//
//  Copyright (c) 2016-present, little2s.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^NOCChatCollectionViewAction)(void);

@interface NOCChatCollectionView : UICollectionView

// Default is YES.
@property (nonatomic, assign, getter=isInverted) BOOL inverted;

@property (nonatomic, assign) CGFloat scrollFractionalThreshold; // in [0, 1]

@property (nullable, nonatomic, copy) NOCChatCollectionViewAction tapAction;

@property (nullable, nonatomic, copy) NOCChatCollectionViewAction contentInsetChangedAction;

- (void)changeWithInsertIndexPathes:(NSArray<NSIndexPath *> *)insertIndexPathes
                  deleteIndexPathes:(NSArray<NSIndexPath *> *)deleteIndexPathes
                  updateIndexPahtes:(NSArray<NSIndexPath *> *)updateIndexPahtes
                           animated:(BOOL)animated
                         completion:(void (^ _Nullable)(void))completion;

//
// These scrolling methods already deal with inverted mode for you.
// For example `isScrolledAtBottom`, the `bottom` is the bottom you see on screen,
// maybe not real bottom of collectionView.
//
- (BOOL)isCloseToTop;
- (BOOL)isScrolledAtTop;
- (void)scrollToTopAnimated:(BOOL)animated;

- (BOOL)isCloseToBottom;
- (BOOL)isScrolledAtBottom;
- (void)scrollToBottomAnimated:(BOOL)animated;

- (void)stopScrollIfNeeded;

@end

NS_ASSUME_NONNULL_END
