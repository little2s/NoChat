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

@property (nonatomic, strong) NSLayoutConstraint *chatInputContainerViewHeightConstraint;

@end

@implementation NOCChatViewController

+ (Class)cellLayoutClassForItemType:(NSString *)type
{
    return nil;
}

+ (Class)chatInputViewClass
{
    return [NOCChatInputView class];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // use `chatCollectionContainerView` and `topLayoutGuide` instead
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.serialQueue = dispatch_queue_create("com.little2s.nochat.chatvc", DISPATCH_QUEUE_SERIAL);
    [self setupSubviews];
    [self setupLayoutConstraints];
    [self registerChatItemCells];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [self.collectionView.collectionViewLayout invalidateLayout];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        for (id<NOCChatItemCellLayout> layout in self.layouts) {
            layout.width = size.width;
            [layout calculateLayout];
        }
        if (self.layouts.count > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
        }
    });
}

- (void)registerChatItemCells
{
    [self.collectionView registerClass:[NOCChatItemCell class] forCellWithReuseIdentifier:[NOCChatItemCell reuseIdentifier]];
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
    if (fabs(dH) > 1) {
        CGFloat minChatInputContainerViewHeight = [self chatInputContainerViewDefaultHeight];
        self.chatInputContainerViewHeightConstraint.constant = MAX(minChatInputContainerViewHeight, newHeight);
        if (!self.inverted) {
            CGFloat topPadding = self.collectionView.contentInset.top;
            CGFloat bottomPadding = self.collectionView.contentInset.bottom;
            CGFloat dY = self.collectionView.contentOffset.y + dH;
            CGFloat minY = 0 - topPadding;
            CGFloat maxY = minY + self.collectionView.contentSize.height + topPadding + bottomPadding;
            CGPoint oldContentOffset = self.collectionView.contentOffset;
            CGFloat newContentOffsetX = oldContentOffset.x;
            CGFloat newContentOffsetY = MAX(minY, MIN(maxY, dY));
            self.collectionView.contentOffset = CGPointMake(newContentOffsetX, newContentOffsetY);
        }
        [self.view layoutIfNeeded];
    }
}

#pragma mark - UIScrollViewDelegate

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    NSAssert(scrollView == self.proxyScrollView, @"Other scroll views should not set `scrollsToTop` true");
    
    BOOL shouldScrollToTop = ![self isScrolledAtTop];
    if (shouldScrollToTop) {
        [self scrollToTop:YES];
    }
    
    return NO;
}

#pragma mark - Private

- (void)didTapChatCollectionContainerView:(UITapGestureRecognizer *)recognizer
{
    [self.chatInputView endInputting:YES];
}

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
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapChatCollectionContainerView:)];
    [chatCollectionContainerView addGestureRecognizer:recognizer];
    [self.view addSubview:chatCollectionContainerView];
    self.chatCollectionContainerView = chatCollectionContainerView;
}

- (void)setupChatCollectionView
{
    NOCChatCollectionViewLayout *collectionViewLayout = [[NOCChatCollectionViewLayout alloc] init];
    collectionViewLayout.minimumLineSpacing = 0;
    NOCChatCollectionView *collectionView = [[NOCChatCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:collectionViewLayout];
    collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    collectionView.contentInset = self.chatCollectionViewContentInset;
    collectionView.scrollIndicatorInsets = self.chatCollectionViewScrollIndicatorInsets;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    if (self.isInverted) {
        collectionView.transform = CGAffineTransformMake(1, 0, 0, -1, 0, 0);
    }
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
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.topLayoutGuide attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.chatCollectionContainerView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.proxyScrollView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.chatCollectionContainerView attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.chatInputContainerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.chatCollectionContainerView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.proxyScrollView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.chatCollectionContainerView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    
    [self pinSubview:self.collectionView toSuperview:self.chatCollectionContainerView];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.chatInputContainerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.chatCollectionContainerView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.chatInputContainerView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.chatInputContainerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.chatInputContainerView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    self.chatInputContainerViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.chatInputContainerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:self.chatInputContainerViewDefaultHeight];
    [self.chatInputContainerView addConstraint:self.chatInputContainerViewHeightConstraint];
    
    [self pinSubview:self.chatInputView toSuperview:self.chatInputContainerView];
}

- (void)pinSubview:(UIView *)subview toSuperview:(UIView *)superview
{
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
}

#pragma mark - Getters

- (NSMutableArray *)layouts
{
    if (!_layouts) {
        _layouts = [[NSMutableArray alloc] init];
    }
    return _layouts;
}

- (BOOL)isInverted
{
    return YES;
}

- (UIEdgeInsets)chatCollectionViewContentInset
{
    return UIEdgeInsetsMake(8, 0, 8, 0);
}

- (UIEdgeInsets)chatCollectionViewScrollIndicatorInsets
{
    return UIEdgeInsetsZero;
}

- (CGFloat)chatInputContainerViewDefaultHeight
{
    return 45;
}

- (CGFloat)cellWidth
{
    return self.view.bounds.size.width - self.collectionView.contentInset.left - self.collectionView.contentInset.right;
}

@end

@implementation NOCChatViewController (NOCUpdates)

- (void)reloadChatItems:(NSArray *)chatItems
{
    dispatch_async(self.serialQueue, ^{
        [self.layouts removeAllObjects];
        [self addLayoutsWithChatItems:chatItems];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    });
}

- (void)addChatItems:(NSArray *)chatItems
{
    dispatch_async(self.serialQueue, ^{
        [self addLayoutsWithChatItems:chatItems];
        
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        for (NSInteger index = 0; index < chatItems.count; index++) {
            NSInteger item = self.isInverted ? (chatItems.count - 1 - index) : (index + self.layouts.count);
            [indexPaths addObject:[NSIndexPath indexPathForItem:item inSection:0]];
        }
        if (indexPaths.count > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView insertItemsAtIndexPaths:indexPaths];
            });
        }
    });
}

#pragma mark - Private

- (void)addLayoutsWithChatItems:(NSArray *)chatItems
{
    for (id<NOCChatItem> chatItem in chatItems) {
        Class layoutClass = [[self class] cellLayoutClassForItemType:chatItem.type];
        if (layoutClass) {
            id<NOCChatItemCellLayout> layout = [[layoutClass alloc] initWithChatItem:chatItem cellWidth:self.cellWidth];
            if (self.inverted) {
                [self.layouts insertObject:layout atIndex:0];
            } else {
                [self.layouts addObject:layout];
            }
        }
    }
}

@end

@implementation NOCChatViewController (NOCScroll)

typedef NS_ENUM(NSUInteger, NOCChatCellVerticalEdge) {
    NOCChatCellVerticalEdgeTop,
    NOCChatCellVerticalEdgeBottom
};

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
    NSIndexPath *firstIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [collectionView scrollToItemAtIndexPath:firstIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:animated];
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
    
    NSInteger sectionIndex = [collectionView numberOfSections] - 1;
    NSInteger itemIndex = [collectionView numberOfItemsInSection:sectionIndex] - 1;
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex];
    [collectionView scrollToItemAtIndexPath:lastIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:animated];
}

- (BOOL)isIndexPathOfCollectionViewVisible:(NSIndexPath *)indexPath atEdge:(NOCChatCellVerticalEdge)edge
{
    UICollectionViewLayoutAttributes *layoutAttributes = [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath];
    if (layoutAttributes) {
        CGRect visibleRect = [self collectionViewVisibleRect];
        CGRect cellRect = layoutAttributes.frame;
        CGRect intersection = CGRectIntersection(visibleRect, cellRect);
        BOOL result;
        switch (edge) {
            case NOCChatCellVerticalEdgeTop: {
                result = fabs(CGRectGetMinY(intersection) - CGRectGetMinY(cellRect)) < 0.001;
                break;
            }
            case NOCChatCellVerticalEdgeBottom: {
                result = fabs(CGRectGetMaxY(intersection) - CGRectGetMaxY(cellRect)) < 0.001;
                break;
            }
        }
        return result;
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

@end
