//
//  NOCChatViewController.m
//  NoChat-Example
//
//  Created by little2s on 2016/12/24.
//  Copyright © 2016年 little2s. All rights reserved.
//

#import "NOCChatViewController.h"
#import "NOCChatCollectionView.h"
#import "NOCChatCollectionViewLayout.h"
#import "NOCChatItemCell.h"
#import "NOCChatItemCellLayout.h"
#import "NOCChatInputView.h"
#import "NOCChatItem.h"

@interface NOCChatViewController ()

@end

@implementation NOCChatViewController

#pragma mark - Override

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.inverted = YES;
        self.chatCollectionViewContentInset = UIEdgeInsetsMake(8, 0, 8, 0);
        self.chatCollectionViewScrollIndicatorInsets = UIEdgeInsetsZero;
        self.chatInputContainerViewDefaultHeight = 45;
        self.scrollFractionalThreshold = 0.05;
        dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_DEFAULT, 0);
        self.serialQueue = dispatch_queue_create("com.little2s.nochat.chatvc.changes", attr);
        self.hidesBottomBarWhenPushed = YES;
        self.automaticallyAdjustsScrollViewInsets = NO; // use `chatCollectionContainerView` and `topLayoutGuide` instead
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupSubviews];
    [self setupLayoutConstraints];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerChatItemCells];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    if (self.layouts.count == 0) {
        return;
    }
    
    [self.collectionView.collectionViewLayout invalidateLayout];
    dispatch_async(self.serialQueue, ^{
        [self.layouts enumerateObjectsUsingBlock:^(id<NOCChatItemCellLayout> layout, NSUInteger idx, BOOL *stop) {
            layout.width = size.width;
            [layout calculateLayout];
        }];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    });
}

#pragma mark - Public

+ (Class)cellLayoutClassForItemType:(NSString *)type
{
    NSAssert(NO, @"ERROR: required method not implemented: %s", __PRETTY_FUNCTION__);
    return nil;
}

+ (Class)chatInputViewClass
{
    NSAssert(NO, @"ERROR: required method not implemented: %s", __PRETTY_FUNCTION__);
    return nil;
}

- (void)registerChatItemCells
{
    NSAssert(NO, @"ERROR: required method not implemented: %s", __PRETTY_FUNCTION__);
}

- (void)didTapStatusBar
{
    BOOL shouldScrollToTop = ![self isScrolledAtTop];
    if (shouldScrollToTop) {
        [self scrollToTop:YES];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.layouts.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<NOCChatItemCellLayout> layout = self.layouts[indexPath.item];
    NOCChatItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:layout.reuseIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    
    [UIView performWithoutAnimation:^{
        cell.layout = layout;
        cell.contentView.transform = collectionView.transform;
    }];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = self.cellWidth;
    CGFloat height = ((id<NOCChatItemCellLayout>)self.layouts[indexPath.row]).height;
    return CGSizeMake(width, height);
}

#pragma mark - NOCChatInputViewDelegate

- (void)chatInputView:(NOCChatInputView *)chatInputView didUpdateHeight:(CGFloat)newHeight oldHeight:(CGFloat)oldHeight
{
    CGFloat dH = newHeight - oldHeight;
    if (fabs(dH) < 1) {
        return;
    }
    
    [self stopScrollIfNeeded];
    
    CGFloat minChatInputContainerViewHeight = [self chatInputContainerViewDefaultHeight];
    self.chatInputContainerViewHeightConstraint.constant = MAX(minChatInputContainerViewHeight, newHeight);
    
    CGPoint newContentOffset;
    UIEdgeInsets newContentInset;
    if (!self.inverted) {
        UIEdgeInsets oldContentInset = self.collectionView.contentInset;
        newContentInset = UIEdgeInsetsMake(self.chatCollectionViewContentInset.top, self.chatCollectionViewContentInset.left, self.chatCollectionViewContentInset.bottom + newHeight, self.chatCollectionViewContentInset.right);
        UIEdgeInsets contentInset = dH > 0 ? oldContentInset : newContentInset;
        newContentOffset = [self contentOffsetWithContentInset:contentInset dH:dH];
    } else {
        UIEdgeInsets oldContentInset = self.collectionView.contentInset;
        newContentInset = UIEdgeInsetsMake(self.chatCollectionViewContentInset.top + newHeight, self.chatCollectionViewContentInset.left, self.chatCollectionViewContentInset.bottom, self.chatCollectionViewContentInset.right);
        UIEdgeInsets contentInset = dH > 0 ? newContentInset : oldContentInset;
        newContentOffset = [self contentOffsetWithContentInset:contentInset dH:-dH];
    }
    
    self.collectionView.contentOffset = newContentOffset;
    self.collectionView.contentInset = newContentInset;
    
    [self.view layoutIfNeeded];
}

- (CGPoint)contentOffsetWithContentInset:(UIEdgeInsets)contentInset dH:(CGFloat)dH
{
    CGFloat topPadding = contentInset.top;
    CGFloat bottomPadding = contentInset.bottom;
    CGFloat dY = self.collectionView.contentOffset.y + dH;
    CGFloat minY = 0 - topPadding;
    CGFloat maxY = minY + self.collectionView.contentSize.height + topPadding + bottomPadding;
    CGPoint oldContentOffset = self.collectionView.contentOffset;
    CGFloat newContentOffsetX = oldContentOffset.x;
    CGFloat newContentOffsetY = MAX(minY, MIN(maxY, dY));
    return CGPointMake(newContentOffsetX, newContentOffsetY);
}

#pragma mark - UIScrollViewDelegate

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    NSAssert(scrollView == self.proxyScrollView, @"Other scroll views should not set `scrollsToTop` true");
    [self didTapStatusBar];
    return NO;
}

#pragma mark - Getters

- (NSMutableArray<id<NOCChatItemCellLayout>> *)layouts
{
    if (!_layouts) {
        _layouts = [[NSMutableArray alloc] init];
    }
    return _layouts;
}

- (CGFloat)cellWidth
{
    return self.view.bounds.size.width;
}

#pragma mark - Private

- (void)setupSubviews
{
    [self setupBackgroundView];
    [self setupProxyScrollView];
    [self setupChatCollectionContainerView];
    [self setupChatCollectionView];
    [self setupChatInputContainerView];
    [self setupChatInputView];
}

- (void)setupBackgroundView
{
    UIImageView *backgroundView = [[UIImageView alloc] init];
    backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    backgroundView.clipsToBounds = YES;
    [self.view addSubview:backgroundView];
    self.backgroundView = backgroundView;
}

- (void)setupProxyScrollView
{
    UIScrollView *proxyScrollView = [[UIScrollView alloc] init];
    proxyScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    proxyScrollView.contentSize = CGSizeMake(600, 1000);
    proxyScrollView.contentOffset = CGPointMake(0, 1);
    proxyScrollView.scrollsToTop = YES;
    proxyScrollView.scrollEnabled = YES;
    proxyScrollView.showsVerticalScrollIndicator = NO;
    proxyScrollView.showsHorizontalScrollIndicator = NO;
    proxyScrollView.backgroundColor = [UIColor clearColor];
    proxyScrollView.delegate = self;
    [self.view addSubview:proxyScrollView];
    self.proxyScrollView = proxyScrollView;
}

- (void)setupChatCollectionContainerView
{
    UIView *chatCollectionContainerView = [[UIView alloc] init];
    chatCollectionContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    chatCollectionContainerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:chatCollectionContainerView];
    self.chatCollectionContainerView = chatCollectionContainerView;
}

- (void)setupChatCollectionView
{
    __weak typeof(self) weakSelf = self;
    
    NOCChatCollectionViewLayout *collectionViewLayout = [[NOCChatCollectionViewLayout alloc] init];
    NOCChatCollectionView *collectionView = [[NOCChatCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:collectionViewLayout];
    collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    UIEdgeInsets contentInset = self.isInverted ? UIEdgeInsetsMake(self.chatCollectionViewContentInset.top + self.chatInputContainerViewDefaultHeight, self.chatCollectionViewContentInset.left, self.chatCollectionViewContentInset.bottom, self.chatCollectionViewContentInset.right) : UIEdgeInsetsMake(self.chatCollectionViewContentInset.top, self.chatCollectionViewContentInset.left, self.chatCollectionViewContentInset.bottom + self.chatInputContainerViewDefaultHeight, self.chatCollectionViewContentInset.right);
    collectionView.contentInset = contentInset;
    collectionView.scrollIndicatorInsets = self.chatCollectionViewScrollIndicatorInsets;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    if (self.isInverted) {
        collectionView.transform = CGAffineTransformMake(1, 0, 0, -1, 0, 0);
    }
    collectionView.tapAction = ^(){
        [weakSelf.chatInputView endInputting:YES];
    };
    [self.chatCollectionContainerView addSubview:collectionView];
    self.collectionView = collectionView;
}

- (void)setupChatInputContainerView
{
    UIView *chatInputContainerView = [[UIView alloc] init];
    chatInputContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    chatInputContainerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:chatInputContainerView];
    self.chatInputContainerView = chatInputContainerView;
}

- (void)setupChatInputView
{
    Class chatInputViewClass = [[self class] chatInputViewClass];
    NOCChatInputView *chatInputView = [[chatInputViewClass alloc] init];
    chatInputView.translatesAutoresizingMaskIntoConstraints = NO;
    chatInputView.delegate = self;
    [self.chatInputContainerView addSubview:chatInputView];
    self.chatInputView = chatInputView;
}

- (void)setupLayoutConstraints
{
    [self.backgroundView setContentHuggingPriority:240 forAxis:UILayoutConstraintAxisHorizontal];
    [self.backgroundView setContentHuggingPriority:240 forAxis:UILayoutConstraintAxisVertical];
    [self.backgroundView setContentCompressionResistancePriority:240 forAxis:UILayoutConstraintAxisHorizontal];
    [self.backgroundView setContentCompressionResistancePriority:240 forAxis:UILayoutConstraintAxisVertical];
    
    [self pinSubview:self.backgroundView toSuperview:self.view];
    
    [self pinSubview:self.proxyScrollView toSuperview:self.view];
    
    [NSLayoutConstraint constraintWithItem:self.topLayoutGuide attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.chatCollectionContainerView attribute:NSLayoutAttributeTop multiplier:1 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.chatCollectionContainerView attribute:NSLayoutAttributeLeading multiplier:1 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.chatCollectionContainerView attribute:NSLayoutAttributeBottom multiplier:1 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.chatCollectionContainerView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0].active = YES;
    
    [self pinSubview:self.collectionView toSuperview:self.chatCollectionContainerView];
    
    [NSLayoutConstraint constraintWithItem:self.chatInputContainerView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.chatInputContainerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.chatInputContainerView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0].active = YES;
    self.chatInputContainerViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.chatInputContainerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:self.chatInputContainerViewDefaultHeight];
    self.chatInputContainerViewHeightConstraint.active = YES;
    
    [self pinSubview:self.chatInputView toSuperview:self.chatInputContainerView];
}

- (void)pinSubview:(UIView *)subview toSuperview:(UIView *)superview
{
    NSLayoutConstraint *topLC = [NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSLayoutConstraint *leadingLC = [NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    NSLayoutConstraint *bottomLC = [NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint *trailingLC = [NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
    [NSLayoutConstraint activateConstraints:@[topLC, leadingLC, bottomLC, trailingLC]];
}

@end

#pragma mark - Changes

@implementation NOCChatViewController (NOCChanges)

- (void)loadChatItems:(NSArray<id<NOCChatItem>> *)chatItems completion:(nullable void (^)(BOOL))completion
{
    dispatch_async(self.serialQueue, ^{
        [self.layouts removeAllObjects];
        
        [chatItems enumerateObjectsUsingBlock:^(id<NOCChatItem> chatItem, NSUInteger idx, BOOL *stop) {
            Class layoutClass = [[self class] cellLayoutClassForItemType:chatItem.type];
            id<NOCChatItemCellLayout> layout = [[layoutClass alloc] initWithChatItem:chatItem cellWidth:self.cellWidth];
            if (self.inverted) {
                [self.layouts insertObject:layout atIndex:0];
            } else {
                [self.layouts addObject:layout];
            }
        }];

        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
            if (completion) {
                completion(YES);
            }
        });
    });
}

- (void)appendChatItems:(NSArray<id<NOCChatItem>> *)chatItems completion:(nullable void (^)(BOOL))completion
{
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.layouts.count, chatItems.count)];
    [self insertChatItems:chatItems atIndexes:indexes completion:completion];
}

- (NSUInteger)indexOfChatItem:(id<NOCChatItem>)chatItem
{
    __block NSUInteger result = NSNotFound;
    [self.layouts enumerateObjectsUsingBlock:^(id<NOCChatItemCellLayout> layout, NSUInteger idx, BOOL *stop) {
        if ([layout.chatItem.uniqueIdentifier isEqualToString:chatItem.uniqueIdentifier]) {
            result = idx;
            *stop = YES;
        }
    }];
    return result;
}

- (void)insertChatItems:(NSArray<id<NOCChatItem>> *)chatItems atIndexes:(NSIndexSet *)indexes completion:(nullable void (^)(BOOL))completion
{
    dispatch_async(self.serialQueue, ^{
        if (!chatItems.count == indexes.count) {
            return;
        }
        
        NSMutableArray *insertedPaths = [[NSMutableArray alloc] init];
        __block NSInteger i = 0;
        [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            id<NOCChatItem> chatItem = chatItems[i];
            Class layoutClass = [[self class] cellLayoutClassForItemType:chatItem.type];
            id<NOCChatItemCellLayout> layout = [[layoutClass alloc] initWithChatItem:chatItem cellWidth:self.cellWidth];
            NSUInteger index = self.isInverted ? self.layouts.count - 1 - idx + 1 : idx;
            [self.layouts insertObject:layout atIndex:index];
            [insertedPaths addObject:[NSIndexPath indexPathForItem:index inSection:0]];
            i++;
        }];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            NOCChatCollectionView *collectionView = self.collectionView;
            [collectionView performBatchUpdates:^{
                [collectionView insertItemsAtIndexPaths:insertedPaths];
            } completion:completion];
        });
    });
}

- (void)deleteChatItemsAtIndexes:(NSIndexSet *)indexes completion:(nullable void (^)(BOOL))completion
{
    dispatch_async(self.serialQueue, ^{
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            NSUInteger index = self.isInverted ? self.layouts.count - 1 - idx : idx;
            [self.layouts removeObjectAtIndex:index];
            [indexPaths addObject:[NSIndexPath indexPathForItem:index inSection:0]];
        }];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            NOCChatCollectionView *collectionView = self.collectionView;
            [collectionView performBatchUpdates:^{
                [collectionView deleteItemsAtIndexPaths:indexPaths];
            } completion:completion];
        });
    });
}

- (void)reloadChatItemsAtIndexes:(NSIndexSet *)indexes completion:(nullable void (^)(BOOL))completion
{
    dispatch_async(self.serialQueue, ^{
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            NSUInteger index = self.isInverted ? self.layouts.count - 1 - idx : idx;
            id<NOCChatItemCellLayout> layout = self.layouts[index];
            layout.width = self.cellWidth;
            [layout calculateLayout];
            [indexPaths addObject:[NSIndexPath indexPathForItem:index inSection:0]];
        }];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            NOCChatCollectionView *collectionView = self.collectionView;
            [collectionView performBatchUpdates:^{
                [collectionView reloadItemsAtIndexPaths:indexPaths];
            } completion:completion];
        });
    });
}

@end

#pragma mark - Scrolling

@implementation NOCChatViewController (NOCScrolling)

typedef NS_ENUM(NSUInteger, NOCChatCellVerticalEdge) {
    NOCChatCellVerticalEdgeTop,
    NOCChatCellVerticalEdgeBottom
};

- (BOOL)isCloseToTop
{
    return self.isInverted ? [self isCloseToCollectionViewBottom] : [self isCloseToCollectionViewTop];
}

- (BOOL)isScrolledAtTop
{
    return self.isInverted ? [self isScrolledAtCollectionViewBottom] : [self isScrolledAtCollectionViewTop];
}

- (void)scrollToTop:(BOOL)animated
{
    if (self.isInverted) {
        [self scrollToCollectionViewBottom:animated];
    } else {
        [self scrollToCollectionViewTop:animated];
    }
}

- (BOOL)isCloseToBottom
{
    return self.isInverted ? [self isCloseToCollectionViewTop] : [self isCloseToCollectionViewBottom];
}

- (BOOL)isScrolledAtBottom
{
    return self.isInverted ? [self isScrolledAtCollectionViewTop] : [self isScrolledAtCollectionViewBottom];
}

- (void)scrollToBottom:(BOOL)animated
{
    if (self.isInverted) {
        [self scrollToCollectionViewTop:animated];
    } else {
        [self scrollToCollectionViewBottom:animated];
    }
}

#pragma mark - Private

- (BOOL)isCloseToCollectionViewTop
{
    NOCChatCollectionView *collectionView = self.collectionView;
    if (collectionView.contentSize.height > 0) {
        CGFloat minY = CGRectGetMinY([self collectionViewVisibleRect]);
        return (minY / collectionView.contentSize.height) < self.scrollFractionalThreshold;
    } else {
        return YES;
    }
}

- (BOOL)isScrolledAtCollectionViewTop
{
    NOCChatCollectionView *collectionView = self.collectionView;
    if (collectionView.numberOfSections > 0 && [collectionView numberOfItemsInSection:0] > 0) {
        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
        return [self isIndexPathOfCollectionViewVisible:firstIndexPath atEdge:NOCChatCellVerticalEdgeTop];
    } else {
        return YES;
    }
}

- (void)scrollToCollectionViewTop:(BOOL)animated
{
    NOCChatCollectionView *collectionView = self.collectionView;
    
    CGFloat offsetY = -collectionView.contentInset.top;
    CGPoint contentOffset = CGPointMake(collectionView.contentOffset.x, offsetY);

    [collectionView setContentOffset:contentOffset animated:animated];
}

- (BOOL)isCloseToCollectionViewBottom
{
    NOCChatCollectionView *collectionView = self.collectionView;
    if (collectionView.contentSize.height > 0) {
        CGFloat maxY = CGRectGetMaxY([self collectionViewVisibleRect]);
        return (maxY / collectionView.contentSize.height) > (1 - self.scrollFractionalThreshold);
    } else {
        return YES;
    }
}

- (BOOL)isScrolledAtCollectionViewBottom
{
    NOCChatCollectionView *collectionView = self.collectionView;
    if (collectionView.numberOfSections > 0 && [collectionView numberOfItemsInSection:0] > 0) {
        NSInteger sectionIndex = [collectionView numberOfSections] - 1;
        NSInteger itemIndex = [collectionView numberOfItemsInSection:sectionIndex] - 1;
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex];
        return [self isIndexPathOfCollectionViewVisible:lastIndexPath atEdge:NOCChatCellVerticalEdgeBottom];
    } else {
        return YES;
    }
}

- (void)scrollToCollectionViewBottom:(BOOL)animated
{
    NOCChatCollectionView *collectionView = self.collectionView;
    CGFloat contentHeight = collectionView.collectionViewLayout.collectionViewContentSize.height;
    CGFloat boundsHeight = collectionView.bounds.size.height;
    
    if (!(contentHeight >= 0 && contentHeight < CGFLOAT_MAX && boundsHeight >= 0)) {
        return;
    }
    
    // Note that we don't rely on collectionView's contentSize. This is because it won't be valid after performBatchUpdates or reloadData
    // After reload data, collectionViewLayout.collectionViewContentSize won't be even valid, so you may want to refresh the layout manually
    CGFloat offsetY = MAX(-collectionView.contentInset.top, contentHeight-boundsHeight+collectionView.contentInset.bottom);
    CGPoint contentOffset = CGPointMake(collectionView.contentOffset.x, offsetY);
    
    [collectionView setContentOffset:contentOffset animated:animated];
}

- (BOOL)isIndexPathOfCollectionViewVisible:(NSIndexPath *)indexPath atEdge:(NOCChatCellVerticalEdge)edge
{
    UICollectionViewLayoutAttributes *layoutAttributes = [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath];
    if (layoutAttributes) {
        CGRect visibleRect = [self collectionViewVisibleRect];
        CGRect cellRect = layoutAttributes.frame;
        CGRect intersection = CGRectIntersection(visibleRect, cellRect);
        if (edge == NOCChatCellVerticalEdgeTop) {
            return fabs(CGRectGetMinY(intersection) - CGRectGetMinY(cellRect)) < 0.001;
        } else {
            return fabs(CGRectGetMaxY(intersection) - CGRectGetMaxY(cellRect)) < 0.001;
        }
    } else {
        return NO;
    }
}

- (CGRect)collectionViewVisibleRect
{
    NOCChatCollectionView *collectionView = self.collectionView;
    UIEdgeInsets contentInset = collectionView.contentInset;
    CGRect bounds = collectionView.bounds;
    CGSize contentSize = collectionView.collectionViewLayout.collectionViewContentSize;
    CGFloat y = collectionView.contentOffset.y + contentInset.top;
    CGFloat width = bounds.size.width;
    CGFloat height = MIN(contentSize.height, bounds.size.height - contentInset.top - contentInset.bottom);
    return CGRectMake(0, y, width, height);
}

- (void)stopScrollIfNeeded
{
    NOCChatCollectionView *collectionView = self.collectionView;
    if (collectionView.isDragging || collectionView.isDecelerating) {
        [collectionView setContentOffset:collectionView.contentOffset animated:NO];
    }
}

@end
