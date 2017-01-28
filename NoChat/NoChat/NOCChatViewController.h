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

@property (nullable, nonatomic, strong) NSLayoutConstraint *chatInputContainerViewHeightConstraint;

@property (nonatomic, strong) NSMutableArray<id<NOCChatItemCellLayout>> *layouts;
@property (nonatomic, strong) dispatch_queue_t serialQueue; // queue for changes

@property (nonatomic, assign, getter=isInverted) BOOL inverted;
@property (nonatomic, assign) UIEdgeInsets chatCollectionViewContentInset;
@property (nonatomic, assign) UIEdgeInsets chatCollectionViewScrollIndicatorInsets;
@property (nonatomic, assign) CGFloat chatInputContainerViewDefaultHeight;
@property (nonatomic, assign) CGFloat scrollFractionalThreshold; // in [0, 1]

@property (nonatomic, assign, readonly) CGFloat cellWidth;

+ (nullable Class)cellLayoutClassForItemType:(NSString *)type;
+ (nullable Class)chatInputViewClass;
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
