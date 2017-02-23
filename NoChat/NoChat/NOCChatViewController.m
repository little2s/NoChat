//
//  NOCChatViewController.m
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

#import "NOCChatViewController.h"
#import "NOCChatContainerView.h"
#import "NOCChatInputPanel.h"
#import "NOCChatCollectionView.h"
#import "NOCChatCollectionViewLayout.h"
#import "NOCChatItemCell.h"
#import "NOCChatItemCellLayout.h"
#import "NOCChatItem.h"

@interface NOCChatViewController ()

@end

@implementation NOCChatViewController

#pragma mark - Override

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)dealloc
{
    [self unregisterKeyboardNotifications];
}

- (void)loadView
{
    [super loadView];
    [self setupContainerView];
    [self setupBackgroundView];
    [self setupCollectionViewScrollToTopProxy];
    [self setupCollectionView];
    [self setupInputPanel];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerChatItemCells];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self adjustColletionViewInsets];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    CGSize previousSize = self.view.frame.size;
    if ((size.width - previousSize.height < FLT_EPSILON) && (size.height - previousSize.width < FLT_EPSILON )) {
        self.isRotating = YES;
    }
    
    __weak typeof(self) weakSelf = self;
    [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        if (weakSelf && weakSelf.isRotating) {
            weakSelf.isRotating = NO;
        }
    }];
}

#pragma mark - Public

+ (Class)cellLayoutClassForItemType:(NSString *)type
{
    NSAssert(NO, @"ERROR: required method not implemented: %s", __PRETTY_FUNCTION__);
    return nil;
}

+ (Class)inputPanelClass
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
        [self scrollToTopAnimated:YES];
    }
}

- (nullable id<NOCChatItemCellLayout>)createLayoutWithItem:(id<NOCChatItem>)item
{
    Class layoutClass = [[self class] cellLayoutClassForItemType:item.type];
    if (layoutClass == nil) {
        return nil;
    }
    
    return [[layoutClass alloc] initWithChatItem:item cellWidth:self.cellWidth];
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
        
        if (!CGAffineTransformEqualToTransform(cell.itemView.transform, collectionView.transform)) {
            cell.itemView.transform = collectionView.transform;
        }
    }];

    return cell;
}

#pragma mark - NOCChatCollectionViewLayoutDelegate

- (NSArray *)cellLayouts
{
    return self.layouts;
}

#pragma mark - NOCChatInputPanelDelgate

- (void)inputPanel:(NOCChatInputPanel *)inputPanel willChangeHeight:(CGFloat)height duration:(NSTimeInterval)duration animationCurve:(int)animationCurve
{
    [self adjustCollectionViewForSize:self.containerView.bounds.size keyboardHeight:self.keyboardHeight inputContainerHeight:height scrollToBottom:NO duration:duration animationCurve:0];
}

#pragma mark - UIScrollViewDelegate

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    NSAssert(scrollView == self.collectionViewScrollToTopProxy, @"Other scroll views should not set `scrollsToTop` true");
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

- (void)commonInit
{
    _inverted = YES;
    _chatInputContainerViewDefaultHeight = 45;
    _scrollFractionalThreshold = 0.05;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.hidesBottomBarWhenPushed = YES;
    [self registerKeyboardNotifications];
}

- (void)setupContainerView
{
    _containerView = [[NOCChatContainerView alloc] initWithFrame:self.view.bounds];
    _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _containerView.backgroundColor = [UIColor whiteColor];
    _containerView.clipsToBounds = YES;
    __weak typeof(self) weakSelf = self;
    _containerView.layoutForSize = ^(CGSize size) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.keyboardHeight < FLT_EPSILON) {
            [strongSelf performSizeChangesWithDuration:(strongSelf.isRotating ? 0.3 : 0.0) size:size];
        }
    };
    [self.view addSubview:_containerView];
}

- (void)setupBackgroundView
{
    _backgroundView = [[UIImageView alloc] initWithFrame:_containerView.bounds];
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    _backgroundView.clipsToBounds = YES;
    [_containerView addSubview:_backgroundView];
}

- (void)setupCollectionViewScrollToTopProxy
{
    _collectionViewScrollToTopProxy = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _containerView.bounds.size.width, 8)];
    _collectionViewScrollToTopProxy.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _collectionViewScrollToTopProxy.contentSize = CGSizeMake(1, 16);
    _collectionViewScrollToTopProxy.contentOffset = CGPointMake(0, 8);
    _collectionViewScrollToTopProxy.scrollsToTop = YES;
    _collectionViewScrollToTopProxy.scrollEnabled = YES;
    _collectionViewScrollToTopProxy.showsVerticalScrollIndicator = NO;
    _collectionViewScrollToTopProxy.showsHorizontalScrollIndicator = NO;
    _collectionViewScrollToTopProxy.backgroundColor = [UIColor clearColor];
    _collectionViewScrollToTopProxy.delegate = self;
    [_containerView addSubview:_collectionViewScrollToTopProxy];
}

- (void)setupCollectionView
{
    CGSize collectionViewSize = _containerView.bounds.size;
    
    _collectionLayout = [[NOCChatCollectionViewLayout alloc] initWithInverted:self.isInverted];
    
    _collectionView = [[NOCChatCollectionView alloc] initWithFrame:CGRectMake(0, 0, collectionViewSize.width, collectionViewSize.height) collectionViewLayout:_collectionLayout];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    
    UIEdgeInsets originalInset = UIEdgeInsetsZero;
    UIEdgeInsets inset = originalInset;
    if (self.isInverted) {
        inset.top += self.chatInputContainerViewDefaultHeight;
    } else {
        inset.bottom += self.chatInputContainerViewDefaultHeight;
    }
    _collectionView.contentInset = inset;

    if (self.isInverted) {
        _collectionView.transform = CGAffineTransformMake(1, 0, 0, -1, 0, 0);
    }
    
    __weak typeof(self) weakSelf = self;
    _collectionView.tapAction = ^() {
        if (weakSelf) {
            [weakSelf.inputPanel endInputting:YES];
        }
    };
    [_containerView addSubview:_collectionView];
}

- (void)setupInputPanel
{
    Class inputPanelClass = [[self class] inputPanelClass];
    _inputPanel = [[inputPanelClass alloc] initWithFrame:CGRectMake(0, self.containerView.bounds.size.height - self.chatInputContainerViewDefaultHeight, self.containerView.bounds.size.width, self.chatInputContainerViewDefaultHeight)];
    _inputPanel.delegate = self;
    [_containerView addSubview:_inputPanel];
}

- (void)registerKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
}

- (void)unregisterKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    if (!self.collectionView) {
        return;
    }
    
    if (self.isInControllerTransition) {
        return;
    }
    
    CGSize collectionViewSize = self.containerView.frame.size;
    
    NSTimeInterval duration = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] == nil ? 0.3 : [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    int curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    CGRect screenKeyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardFrame = [self.containerView convertRect:screenKeyboardFrame fromView:nil];
    
    CGFloat keyboardHeight = (keyboardFrame.size.height <= FLT_EPSILON || keyboardFrame.size.width <= FLT_EPSILON) ? 0.0f : (collectionViewSize.height - keyboardFrame.origin.y);
    
    self.halfTransitionKeyboardHeight = keyboardHeight;
    
    keyboardHeight = MAX(keyboardHeight, 0.0f);
    
    if (keyboardFrame.origin.y + keyboardFrame.size.height < collectionViewSize.height - FLT_EPSILON) {
        keyboardHeight = 0.0f;
    }
    
    if (ABS(self.keyboardHeight - keyboardHeight) < FLT_EPSILON && ABS(collectionViewSize.width - self.collectionView.frame.size.width) < FLT_EPSILON) {
        return;
    }
    
    if (self.isRotating && keyboardHeight < FLT_EPSILON) {
        return;
    }
    
    if (ABS(self.keyboardHeight - keyboardHeight) > FLT_EPSILON) {
        self.keyboardHeight = keyboardHeight;
        
        if (ABS(collectionViewSize.width - self.collectionView.frame.size.width) > FLT_EPSILON) {
            if ([NSThread isMainThread]) {
                [self performSizeChangesWithDuration:0.3 size:self.containerView.bounds.size];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self performSizeChangesWithDuration:0.3 size:self.containerView.bounds.size];
                });
            }
        } else {
            [self.inputPanel adjustForSize:self.containerView.bounds.size keyboardHeight:keyboardHeight  duration:duration animationCurve:curve];
            [self adjustCollectionViewForSize:self.containerView.bounds.size keyboardHeight:keyboardHeight inputContainerHeight:self.inputPanel.frame.size.height scrollToBottom:NO duration:duration animationCurve:curve];
        }
    }
}

- (void)keyboardDidChangeFrame:(NSNotification *)notification
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] == nil) {
        CGSize collectionViewSize = self.containerView.frame.size;
        
        NSTimeInterval duration = 0.3;
        int curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue];
        CGRect screenKeyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGRect keyboardFrame = [self.containerView convertRect:screenKeyboardFrame fromView:nil];
        
        CGFloat keyboardHeight = (keyboardFrame.size.height <= FLT_EPSILON || keyboardFrame.size.width <= FLT_EPSILON) ? 0 : (collectionViewSize.height - keyboardFrame.origin.y);
        
        if (keyboardFrame.origin.y + keyboardFrame.size.height < collectionViewSize.height - FLT_EPSILON) {
            keyboardHeight = 0;
        }
        
        self.keyboardHeight = keyboardHeight;
        
        [self.inputPanel adjustForSize:self.containerView.bounds.size keyboardHeight:keyboardHeight duration:duration animationCurve:curve];
        [self adjustCollectionViewForSize:self.containerView.bounds.size keyboardHeight:keyboardHeight inputContainerHeight:self.inputPanel.frame.size.height scrollToBottom:NO duration:duration animationCurve:curve];
    }
}

- (void)adjustColletionViewInsets
{
    CGFloat topPadding = self.topLayoutGuide.length;
    UIEdgeInsets originalInset = self.collectionView.contentInset;
    UIEdgeInsets inset = originalInset;
    if (self.isInverted) {
        inset.bottom = topPadding;
    } else {
        inset.top = topPadding;
    }
    self.collectionView.contentInset = inset;
}

- (void)adjustCollectionViewForSize:(CGSize)size keyboardHeight:(CGFloat)keyboardHeight inputContainerHeight:(CGFloat)inputContainerHeight scrollToBottom:(BOOL)scrollToBottom duration:(NSTimeInterval)duration animationCurve:(int)animationCurve
{
    [self stopScrollIfNeeded];
    
    CGFloat contentHeight = self.collectionView.contentSize.height;
    
    UIEdgeInsets originalInset = self.collectionView.contentInset;
    UIEdgeInsets inset = originalInset;
    if (self.isInverted) {
        inset.top = keyboardHeight + inputContainerHeight;
    } else {
        inset.bottom = keyboardHeight + inputContainerHeight;
    }
    
    CGPoint originalContentOffset = self.collectionView.contentOffset;
    CGPoint contentOffset = originalContentOffset;
    
    if (scrollToBottom) {
        if (self.isInverted) {
            contentOffset = CGPointMake(0, -inset.top);
        } else {
            contentOffset = CGPointMake(0, contentHeight - self.collectionView.bounds.size.height + inset.bottom);
        }
    } else {
        if (self.isInverted) {
            contentOffset.y += originalInset.top - inset.top;
        } else {
            contentOffset.y += inset.bottom - originalInset.bottom;
        }
        contentOffset.y = MIN(contentOffset.y, contentHeight - self.collectionView.bounds.size.height + inset.bottom);
        contentOffset.y = MAX(contentOffset.y, -inset.top);
    }
    
    if (duration > DBL_EPSILON) {        
        [UIView animateWithDuration:duration delay:0 options:(animationCurve << 16) | UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.collectionView.contentInset = inset;
            if (!CGPointEqualToPoint(contentOffset, originalContentOffset)) {
                self.collectionView.contentOffset = contentOffset;
            }
        } completion:nil];
    } else {
        self.collectionView.contentInset = inset;
        if (!CGPointEqualToPoint(contentOffset, originalContentOffset)) {
            self.collectionView.contentOffset = contentOffset;
        }
    }
}

- (void)performSizeChangesWithDuration:(NSTimeInterval)duration size:(CGSize)size
{
    [self stopScrollIfNeeded];
    
    BOOL animated = duration > DBL_EPSILON;
    CGSize collectionViewSize = size;
    CGFloat keyboardHeight = self.keyboardHeight;
    
    [self.inputPanel changeToSize:size keyboardHeight:keyboardHeight duration:duration];
    
    CGFloat maxOriginY = self.isInverted ? self.collectionView.contentOffset.y + self.collectionView.contentInset.top : self.collectionView.contentOffset.y + self.collectionView.bounds.size.height - self.collectionView.contentInset.bottom;
    CGPoint previousContentOffset = self.collectionView.contentOffset;
    CGRect previousCollectionFrame = self.collectionView.frame;
    
    NSInteger anchorItemIndex = -1;
    CGFloat anchorItemOriginY = 0;
    CGFloat anchorItemRelativeOffset = 0;
    CGFloat anchorItemHeight = 0;
    
    NSMutableArray *previousItemFrames = [[NSMutableArray alloc] init];
    CGRect previousVisibleBounds = CGRectMake(previousContentOffset.x, previousContentOffset.y, self.collectionView.frame.size.width, self.collectionView.frame.size.height);
    
    NSMutableSet *previousVisibleItemIndices = [[NSMutableSet alloc] init];
    
    NSArray *previousLayoutAttributes = [self.collectionLayout layoutAttributesForLayouts:self.layouts containerWidth:previousCollectionFrame.size.width maxHeight:CGFLOAT_MAX contentHeight:NULL];
    
    NSInteger chatItemsCount = self.layouts.count;
    for (NSInteger i = 0; i < chatItemsCount; i++) {
        UICollectionViewLayoutAttributes *attributes = previousLayoutAttributes[i];
        CGRect itemFrame = attributes.frame;
        
        if (itemFrame.origin.y < maxOriginY) {
            anchorItemHeight = itemFrame.size.height;
            anchorItemIndex = i;
            anchorItemOriginY = itemFrame.origin.y;
        }
        
        if (!CGRectIsEmpty(CGRectIntersection(itemFrame, previousVisibleBounds))) {
            [previousVisibleItemIndices addObject:@(i)];
        }
        
        [previousItemFrames addObject:[NSValue valueWithCGRect:itemFrame]];
    }
    
    if (anchorItemIndex != -1) {
        if (anchorItemHeight > 1.0f) {
            anchorItemRelativeOffset = (anchorItemOriginY - maxOriginY) / anchorItemHeight;
        }
    }
    
    self.collectionView.frame = CGRectMake(0, 0, collectionViewSize.width, collectionViewSize.height);
    
    [self.collectionLayout invalidateLayout];
    
    UIEdgeInsets originalInset = self.collectionView.contentInset;
    UIEdgeInsets inset = originalInset;
    if (self.isInverted) {
        inset.top = keyboardHeight + self.inputPanel.frame.size.height;
    } else {
        inset.bottom = keyboardHeight + self.inputPanel.frame.size.height;
    }
    self.collectionView.contentInset = inset;
    
    CGFloat newContentHeight = 0;
    NSArray *newLayoutAttributes = [self.collectionLayout layoutAttributesForLayouts:self.layouts containerWidth:collectionViewSize.width maxHeight:CGFLOAT_MAX contentHeight:&newContentHeight];
    
    CGPoint newContentOffset = CGPointZero;
    newContentOffset.y = -self.collectionView.contentInset.top;
    if (anchorItemIndex >= 0 && anchorItemIndex < newLayoutAttributes.count) {
        UICollectionViewLayoutAttributes *attributes = newLayoutAttributes[anchorItemIndex];
        if (self.isInverted) {
            newContentOffset.y += attributes.frame.origin.y - floor(anchorItemRelativeOffset * attributes.frame.size.height);
        } else {
            newContentOffset.y += self.collectionView.contentInset.top + attributes.frame.origin.y - floor(anchorItemRelativeOffset * attributes.frame.size.height) - (self.collectionView.bounds.size.height - self.collectionView.contentInset.bottom);
        }
    }
    newContentOffset.y = MIN(newContentOffset.y, newContentHeight + self.collectionView.contentInset.bottom - self.collectionView.frame.size.height);
    newContentOffset.y = MAX(newContentOffset.y, -self.collectionView.contentInset.top);
    
    NSMutableArray *transitiveItemIndicesWithFrames = [[NSMutableArray alloc] init];
    
    CGRect newVisibleBounds = CGRectMake(newContentOffset.x, newContentOffset.y, self.collectionView.frame.size.width, self.collectionView.frame.size.height);
    for (NSInteger i = 0; i < chatItemsCount; i++) {
        UICollectionViewLayoutAttributes *attributes = newLayoutAttributes[i];
        CGRect itemFrame = attributes.frame;
        
        if (CGRectIsEmpty(CGRectIntersection(itemFrame, newVisibleBounds)) && [previousVisibleItemIndices containsObject:@(i)]) {
            [transitiveItemIndicesWithFrames addObject:@[@(i), [NSValue valueWithCGRect:itemFrame]]];
        }
    }
    
    NSMutableDictionary *transitiveCells = [[NSMutableDictionary alloc] init];
    
    if (animated && !self.collectionView.decelerating && !self.collectionView.dragging && !self.collectionView.tracking) {
        for (NSArray *nDesc in transitiveItemIndicesWithFrames) {
            NSNumber *nIndex = nDesc[0];
            
            NOCChatItemCell *currentCell = (NOCChatItemCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:[nIndex intValue] inSection:0]];
            if (currentCell != nil) {
                NOCChatItemCell *transitiveCell = [[NOCChatItemCell alloc] initWithFrame:[nDesc[1] CGRectValue]];
                transitiveCell.layout = self.layouts[[nIndex intValue]];
                
                transitiveCells[nIndex] = transitiveCell;
            }
        }
    }
    
    self.collectionView.contentOffset = newContentOffset;
    
    [self updateCellLayouts];
    [self.collectionView layoutSubviews];
    
    if (animated) {
        self.collectionView.clipsToBounds = NO;
        
        CGFloat contentOffsetDifference = newContentOffset.y - previousContentOffset.y + (self.collectionView.frame.size.height - previousCollectionFrame.size.height);
        CGFloat widthDifference = self.collectionView.frame.size.width - previousCollectionFrame.size.width;
        
        NSMutableArray *itemFramesToRestore = [[NSMutableArray alloc] init];
        
        for (NSInteger i = 0; i < chatItemsCount; i++) {
            NOCChatItemCell *cell = (NOCChatItemCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            NOCChatItemCell *transitiveCell = transitiveCells[@(i)];
            
            if (transitiveCell != nil) {
                if (cell == nil) {
                    cell = transitiveCell;
                    [_collectionView addSubview:transitiveCell];
                } else {
                    [transitiveCells removeObjectForKey:@(i)];
                }
            }
            
            if (cell != nil) {
                [itemFramesToRestore addObject:@[@(i), [NSValue valueWithCGRect:cell.frame]]];
                CGRect previousFrame = [previousItemFrames[i] CGRectValue];
                cell.frame = CGRectOffset(previousFrame, widthDifference, contentOffsetDifference);
                
                [self adjustLayoutForCell:cell];
            }
        }
        
        [UIView animateWithDuration:duration animations:^{
            for (NSArray *frameDesc in itemFramesToRestore) {
                NOCChatItemCell *cell = (NOCChatItemCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:[frameDesc[0] intValue] inSection:0]];
                if (cell == nil) {
                    cell = transitiveCells[frameDesc[0]];
                }
                cell.frame = [frameDesc[1] CGRectValue];
                
                [self adjustLayoutForCell:cell];
            }
        } completion:^(BOOL finished) {
            if (finished) {
                self.collectionView.clipsToBounds = YES;
            }
            
            [transitiveCells enumerateKeysAndObjectsUsingBlock:^(NSNumber *nIndex, NOCChatItemCell *cell, BOOL *stop) {
                [cell removeFromSuperview];
            }];
        }];
    }
}

- (void)updateCellLayouts
{
    for (NSInteger i = 0; i < self.layouts.count; i++) {
        NOCChatItemCell *cell = (NOCChatItemCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        if (cell) {
            cell.layout = self.layouts[i];
        }
    }
}

- (void)adjustLayoutForCell:(NOCChatItemCell *)cell
{
    id<NOCChatItemCellLayout> layout = cell.layout;
    layout.width = cell.frame.size.width;
    [layout calculateLayout];
    cell.layout = layout;
}

@end

#pragma mark - Changes

@implementation NOCChatViewController (NOCChanges)

- (void)insertLayouts:(NSArray<id<NOCChatItemCellLayout>> *)layouts atIndexes:(NSIndexSet *)indexes animated:(BOOL)animated
{
    if (layouts.count != indexes.count) {
        return;
    }
    
    NSMutableArray *insertedPaths = [[NSMutableArray alloc] init];
    
    __block NSUInteger i = 0;
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        id<NOCChatItemCellLayout> layout = layouts[i];
        [self.layouts insertObject:layout atIndex:idx];
        
        [insertedPaths addObject:[NSIndexPath indexPathForItem:idx inSection:0]];
        i++;
    }];
    
    NOCChatCollectionView *collectionView = self.collectionView;
    
    if (animated) {
        [collectionView performBatchUpdates:^{
            [collectionView insertItemsAtIndexPaths:insertedPaths];
        } completion:nil];
    } else {
        [self.collectionLayout prepareLayout];
        [collectionView reloadData];
        [collectionView layoutIfNeeded];
    }
}

- (void)deleteLayoutsAtIndexes:(NSIndexSet *)indexes animated:(BOOL)animated
{
    NSMutableArray *insertedPaths = [[NSMutableArray alloc] init];
    
    __block NSUInteger i = 0;
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [self.layouts removeObjectAtIndex:idx];
        
        [insertedPaths addObject:[NSIndexPath indexPathForItem:idx inSection:0]];
        i++;
    }];
    
    NOCChatCollectionView *collectionView = self.collectionView;
    
    if (animated) {
        [collectionView performBatchUpdates:^{
            [collectionView deleteItemsAtIndexPaths:insertedPaths];
        } completion:nil];
    } else {
        [self.collectionLayout prepareLayout];
        [collectionView reloadData];
        [collectionView layoutIfNeeded];
    }
}

- (void)updateLayoutAtIndex:(NSUInteger)index toLayout:(id<NOCChatItemCellLayout>)layout animated:(BOOL)animated
{
    if (index >= self.layouts.count) {
        return;
    }
    
    self.layouts[index] = layout;
    
    NOCChatCollectionView *collectionView = self.collectionView;
    
    if (animated) {
        [collectionView performBatchUpdates:^{
            [collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
        } completion:nil];
    } else {
        [self.collectionLayout prepareLayout];
        [collectionView reloadData];
        [collectionView layoutIfNeeded];
    }
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

- (void)scrollToTopAnimated:(BOOL)animated
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

- (void)scrollToBottomAnimated:(BOOL)animated
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
    
    CGFloat offsetY = MAX(-collectionView.contentInset.top, contentHeight - boundsHeight + collectionView.contentInset.bottom);
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
            return ABS(CGRectGetMinY(intersection) - CGRectGetMinY(cellRect)) < FLT_EPSILON;
        } else {
            return ABS(CGRectGetMaxY(intersection) - CGRectGetMaxY(cellRect)) < FLT_EPSILON;
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
    return CGRectMake(0, collectionView.contentOffset.y + contentInset.top, bounds.size.width, MIN(contentSize.height, bounds.size.height - contentInset.top - contentInset.bottom));
}

- (void)stopScrollIfNeeded
{
    NOCChatCollectionView *collectionView = self.collectionView;
    if (collectionView.isTracking || collectionView.isDragging || collectionView.isDecelerating) {
        [collectionView setContentOffset:collectionView.contentOffset animated:NO];
    }
}

@end
