//
//  NOCChatViewController.h
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
#import "NOCChatCollectionViewLayout.h"
#import "NOCChatItemCell.h"
#import "NOCChatInputPanel.h"

@class NOCChatContainerView;
@class NOCChatCollectionView;

NS_ASSUME_NONNULL_BEGIN

@interface NOCChatViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, NOCChatCollectionViewLayoutDelegate, NOCChatInputPanelDelegate, NOCChatItemCellDelegate>

@property (nullable, nonatomic, strong) NOCChatContainerView *containerView;
@property (nullable, nonatomic, strong) UIImageView *backgroundView;

@property (nullable, nonatomic, strong) NOCChatCollectionView *collectionView;
@property (nullable, nonatomic, strong) NOCChatCollectionViewLayout *collectionLayout;
@property (nullable, nonatomic, strong) UIScrollView *collectionViewScrollToTopProxy;

// Supporting you have only one input panel. If you had custom input panels,
// this property would be a pointer which point to current panel.
@property (nullable, nonatomic, strong) NOCChatInputPanel *inputPanel;

@property (nonatomic, assign) CGFloat halfTransitionKeyboardHeight;
@property (nonatomic, assign) CGFloat keyboardHeight;
@property (nonatomic, assign) BOOL isRotating;

@property (nonatomic, assign) BOOL isInControllerTransition;

//
// Pay more attention to inverted mode with layouts,
// as you see on collectionView:
//
// +------------+                +------------+
// |    ...     |                |  layout 0  |
// |  layout 2  |                |  layout 1  |
// |  layout 1  |       VS.      |  layout 2  |
// |  layout 0  |                |    ...     |
// +------------+                +------------+
//
// inverted is YES               inverted is NO
//
@property (nonatomic, strong) NSMutableArray<id<NOCChatItemCellLayout>> *layouts;

// Default is YES.
@property (nonatomic, assign, getter=isInverted) BOOL inverted;

@property (nonatomic, assign) CGFloat chatInputContainerViewDefaultHeight;
@property (nonatomic, assign) CGFloat scrollFractionalThreshold; // in [0, 1]

@property (nonatomic, assign, readonly) CGFloat cellWidth;

+ (nullable Class)cellLayoutClassForItemType:(NSString *)type;
+ (nullable Class)inputPanelClass;
- (void)registerChatItemCells;

- (void)didTapStatusBar;

- (nullable id<NOCChatItemCellLayout>)createLayoutWithItem:(id<NOCChatItem>)item;

@end

//
// Pay more attention to use these methods with inverted mode.
// These methods won't check or even map the relationship
// between layouts and their indexes for you.
//
@interface NOCChatViewController (NOCChanges)

- (void)insertLayouts:(NSArray<id<NOCChatItemCellLayout>> *)layouts atIndexes:(NSIndexSet *)indexes animated:(BOOL)animated;
- (void)deleteLayoutsAtIndexes:(NSIndexSet *)indexes animated:(BOOL)animated;
- (void)updateLayoutAtIndex:(NSUInteger)index toLayout:(id<NOCChatItemCellLayout>)layout animated:(BOOL)animated;

@end

//
// These scrolling methods already deal with inverted mode for you.
// For example `isScrolledAtBottom`, the `bottom` is the bottom you see on screen,
// maybe not real bottom of collectionView.
//
@interface NOCChatViewController (NOCScrolling)

- (BOOL)isCloseToTop;
- (BOOL)isScrolledAtTop;
- (void)scrollToTopAnimated:(BOOL)animated;

- (BOOL)isCloseToBottom;
- (BOOL)isScrolledAtBottom;
- (void)scrollToBottomAnimated:(BOOL)animated;

- (void)stopScrollIfNeeded;

@end

NS_ASSUME_NONNULL_END
