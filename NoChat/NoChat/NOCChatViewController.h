//
//  NOCChatViewController.h
//  NoChat-Example
//
//  Created by little2s on 2016/12/24.
//  Copyright © 2016年 little2s. All rights reserved.
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

@property (nullable, nonatomic, strong) NOCChatInputPanel *inputPanel;

@property (nonatomic, assign) CGFloat halfTransitionKeyboardHeight;
@property (nonatomic, assign) CGFloat keyboardHeight;
@property (nonatomic, assign) BOOL isRotating;

@property (nonatomic, assign) BOOL isInControllerTransition;

@property (nonatomic, strong) NSMutableArray<id<NOCChatItemCellLayout>> *layouts;
@property (nonatomic, strong) dispatch_queue_t serialQueue; // queue for changes

@property (nonatomic, assign, getter=isInverted) BOOL inverted;
@property (nonatomic, assign) UIEdgeInsets chatCollectionViewContentInset;
@property (nonatomic, assign) UIEdgeInsets chatCollectionViewScrollIndicatorInsets;
@property (nonatomic, assign) CGFloat chatInputContainerViewDefaultHeight;
@property (nonatomic, assign) CGFloat scrollFractionalThreshold; // in [0, 1]

@property (nonatomic, assign, readonly) CGFloat cellWidth;

+ (nullable Class)cellLayoutClassForItemType:(NSString *)type;
+ (nullable Class)inputPanelClass;
- (void)registerChatItemCells;

- (void)didTapStatusBar;

@end

@interface NOCChatViewController (NOCChanges)

- (void)loadChatItems:(NSArray<id<NOCChatItem>> *)chatItems completion:(nullable void (^)(BOOL finished))completion;
- (void)appendChatItems:(NSArray<id<NOCChatItem>> *)chatItems completion:(nullable void (^)(BOOL finished))completion;

- (NSUInteger)indexOfChatItem:(id<NOCChatItem>)chatItem;

- (void)insertChatItems:(NSArray<id<NOCChatItem>> *)chatItems atIndexes:(NSIndexSet *)indexes completion:(nullable void (^)(BOOL finished))completion;
- (void)deleteChatItemsAtIndexes:(NSIndexSet *)indexes completion:(nullable void (^)(BOOL finished))completion;
- (void)reloadChatItemsAtIndexes:(NSIndexSet *)indexes completion:(nullable void (^)(BOOL finished))completion;

@end

@interface NOCChatViewController (NOCScrolling)

- (BOOL)isCloseToTop;
- (BOOL)isScrolledAtTop;
- (void)scrollToTop:(BOOL)animated;

- (BOOL)isCloseToBottom;
- (BOOL)isScrolledAtBottom;
- (void)scrollToBottom:(BOOL)animated;

- (void)stopScrollIfNeeded;

@end

NS_ASSUME_NONNULL_END
