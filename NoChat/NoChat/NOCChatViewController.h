//
//  NOCChatViewController.h
//  NoChat-Example
//
//  Created by little2s on 2016/12/24.
//  Copyright © 2016年 little2s. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NOCChatInputView.h"
#import "NOCChatItemCell.h"

@class NOCChatCollectionView;

@interface NOCChatViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NOCChatInputViewDelegate, NOCChatItemCellDelegate>

@property (nonatomic, weak) UIImageView *backgroundView;
@property (nonatomic, weak) UIScrollView *proxyScrollView;
@property (nonatomic, weak) UIView *chatCollectionContainerView;
@property (nonatomic, weak) NOCChatCollectionView *collectionView;
@property (nonatomic, weak) UIView *chatInputContainerView;
@property (nonatomic, weak) NOCChatInputView *chatInputView;

@property (nonatomic, strong, readonly) NSArray<id<NOCChatItem>> *chatItems;
@property (nonatomic, strong) NSMutableArray<id<NOCChatItemCellLayout>> *layouts;
@property (nonatomic, strong) dispatch_queue_t serialQueue;
@property (nonatomic, assign, getter=isUpdating) BOOL updating;

@property (nonatomic, assign, getter=isInverted) BOOL inverted;
@property (nonatomic, assign) UIEdgeInsets chatCollectionViewContentInset;
@property (nonatomic, assign) UIEdgeInsets chatCollectionViewScrollIndicatorInsets;
@property (nonatomic, assign) CGFloat chatInputContainerViewDefaultHeight;

@property (nonatomic, assign, readonly) CGFloat cellWidth;

@property (nonatomic, assign, getter=isAutoScrollToBottomEnable) BOOL autoScrollToBottomEnable;
@property (nonatomic, assign, getter=isAutoLoadingEnable) BOOL autoLoadingEnable;
@property (nonatomic, assign) CGFloat autoLoadingFractionalThreshold;
@property (nonatomic, copy) void(^loadPreviousChatItems)();

+ (Class)cellLayoutClassForItemType:(NSString *)type;
+ (Class)chatInputViewClass;
- (void)registerChatItemCells;

@end

@interface NOCChatViewController (NOCUpdates)

- (void)reloadWithChatItems:(NSArray<id<NOCChatItem>> *)chatItems;
- (void)appendChatItems:(NSArray<id<NOCChatItem>> *)chatItems;

- (NSUInteger)indexOfChatItem:(id<NOCChatItem>)chatItem;

- (void)insertChatItems:(NSArray<id<NOCChatItem>> *)chatItems atIndexes:(NSIndexSet *)indexes;
- (void)deleteChatItemsAtIndexes:(NSIndexSet *)indexes;
- (void)updateChatItemsAtIndexes:(NSIndexSet *)indexes;

@end

@interface NOCChatViewController (NOCScroll)

- (BOOL)isCloseToTop;
- (BOOL)isScrolledAtTop;
- (void)scrollToTop:(BOOL)animated;

- (BOOL)isCloseToBottom;
- (BOOL)isScrolledAtBottom;
- (void)scrollToBottom:(BOOL)animated;

- (void)stopScrollIfNeeded;

@end
