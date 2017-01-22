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

NS_ASSUME_NONNULL_BEGIN

@interface NOCChatViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NOCChatInputViewDelegate, NOCChatItemCellDelegate>

@property (nullable, nonatomic, weak) UIImageView *backgroundView;
@property (nullable, nonatomic, weak) UIScrollView *proxyScrollView;
@property (nullable, nonatomic, weak) UIView *chatCollectionContainerView;
@property (nullable, nonatomic, weak) NOCChatCollectionView *collectionView;
@property (nullable, nonatomic, weak) UIView *chatInputContainerView;
@property (nullable, nonatomic, weak) NOCChatInputView *chatInputView;

@property (nullable, nonatomic, strong, readonly) NSArray<id<NOCChatItem>> *chatItems;
@property (nullable, nonatomic, strong) NSMutableArray<id<NOCChatItemCellLayout>> *layouts;
@property (nonatomic, strong) dispatch_queue_t serialQueue;
@property (nonatomic, assign, getter=isUpdating) BOOL updating;

@property (nonatomic, assign, getter=isInverted) BOOL inverted;
@property (nonatomic, assign) UIEdgeInsets chatCollectionViewContentInset;
@property (nonatomic, assign) UIEdgeInsets chatCollectionViewScrollIndicatorInsets;
@property (nonatomic, assign) CGFloat chatInputContainerViewDefaultHeight;

@property (nonatomic, assign, readonly) CGFloat cellWidth;

@property (nonatomic, assign, getter=isAutoLoadAboveChatItemsEnable) BOOL autoLoadAboveChatItemsEnable;
@property (nonatomic, assign, getter=isAutoLoadBelowChatItemsEnable) BOOL autoLoadBelowChatItemsEnable;
@property (nonatomic, assign) CGFloat autoLoadingFractionalThreshold;

+ (nullable Class)cellLayoutClassForItemType:(NSString *)type;
+ (nullable Class)chatInputViewClass;
- (void)registerChatItemCells;

- (void)loadAboveChatItems;
- (void)loadBelowChatItems;

@end

@interface NOCChatViewController (NOCChanges)

- (void)reloadChatItems:(NSArray<id<NOCChatItem>> *)chatItems;
- (void)appendChatItems:(NSArray<id<NOCChatItem>> *)chatItems;

- (NSUInteger)indexOfChatItem:(id<NOCChatItem>)chatItem;

- (void)insertChatItems:(NSArray<id<NOCChatItem>> *)chatItems atIndexes:(NSIndexSet *)indexes;
- (void)deleteChatItemsAtIndexes:(NSIndexSet *)indexes;
- (void)updateChatItemsAtIndexes:(NSIndexSet *)indexes;

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
