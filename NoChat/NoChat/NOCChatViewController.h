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

@property (nonatomic, strong) NSMutableArray *layouts;
@property (nonatomic, strong) dispatch_queue_t serialQueue;

@property (nonatomic, assign, readonly, getter=isInverted) BOOL inverted;
@property (nonatomic, assign, readonly) UIEdgeInsets chatCollectionViewContentInset;
@property (nonatomic, assign, readonly) UIEdgeInsets chatCollectionViewScrollIndicatorInsets;
@property (nonatomic, assign, readonly) CGFloat chatInputContainerViewDefaultHeight;

@property (nonatomic, assign, readonly) CGFloat cellWidth;

+ (Class)cellLayoutClassForItemType:(NSString *)type;
+ (Class)chatInputViewClass;
- (void)registerChatItemCells;

@end

@interface NOCChatViewController (NOCUpdates)

- (void)reloadChatItems:(NSArray *)chatItems;
- (void)addChatItems:(NSArray *)chatItems;

@end

@interface NOCChatViewController (NOCScroll)

- (BOOL)isScrolledAtTop;
- (void)scrollToTop:(BOOL)animated;

- (BOOL)isScrolledAtBottom;
- (void)scrollToBottom:(BOOL)animated;

@end
