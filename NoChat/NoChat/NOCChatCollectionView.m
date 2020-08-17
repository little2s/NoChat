//
//  NOCChatCollectionView.m
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

#import "NOCChatCollectionView.h"

typedef NS_ENUM(NSUInteger, NOCChatCellVerticalEdge) {
    NOCChatCellVerticalEdgeTop,
    NOCChatCellVerticalEdgeBottom
};

@interface NOCChatCollectionView ()

@end

@implementation NOCChatCollectionView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.showsVerticalScrollIndicator = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.scrollsToTop = NO;
        self.alwaysBounceVertical = YES;
        self.exclusiveTouch = YES;
        //self.delaysContentTouches = NO;
        
        _inverted = YES;
        _scrollFractionalThreshold = 0.05;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapped)];
        tap.cancelsTouchesInView = NO;
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)onTapped
{
    if (self.tapAction) {
        self.tapAction();
    }
}

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    [super setContentInset:contentInset];
    
    UIEdgeInsets inset = self.scrollIndicatorInsets;
    inset.top = contentInset.top;
    inset.bottom = contentInset.bottom;
    inset.left = contentInset.left;
    inset.right = contentInset.right;
    self.scrollIndicatorInsets = inset;
    
    if (self.contentInsetChangedAction) {
        self.contentInsetChangedAction();
    }
}

- (void)changeWithInsertIndexPathes:(NSArray<NSIndexPath *> *)insertIndexPathes
                  deleteIndexPathes:(NSArray<NSIndexPath *> *)deleteIndexPathes
                  updateIndexPahtes:(NSArray<NSIndexPath *> *)updateIndexPahtes
                           animated:(BOOL)animated
                         completion:(void (^ _Nullable)(void))completion
{
    if (animated) {
        [self performBatchUpdates:^{
            if (insertIndexPathes.count > 0) {
                [self insertItemsAtIndexPaths:insertIndexPathes];
            }
            if (deleteIndexPathes.count > 0) {
                [self deleteItemsAtIndexPaths:deleteIndexPathes];
            }
            if (updateIndexPahtes.count > 0) {
                [self reloadItemsAtIndexPaths:updateIndexPahtes];
            }
        } completion:^(BOOL finished) {
            if (completion) {
                completion();
            }
        }];
    } else {
        [self.collectionViewLayout prepareLayout];
        [self reloadData];
        [self layoutIfNeeded];
        if (completion) {
            completion();
        }
    }

}

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

- (BOOL)isCloseToCollectionViewTop
{
    NOCChatCollectionView *collectionView = self;
    if (collectionView.contentSize.height > 0) {
        CGFloat minY = CGRectGetMinY([self collectionViewVisibleRect]);
        return (minY / collectionView.contentSize.height) < self.scrollFractionalThreshold;
    } else {
        return YES;
    }
}

- (BOOL)isScrolledAtCollectionViewTop
{
    NOCChatCollectionView *collectionView = self;
    if (collectionView.numberOfSections > 0 && [collectionView numberOfItemsInSection:0] > 0) {
        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
        return [self isIndexPathOfCollectionViewVisible:firstIndexPath atEdge:NOCChatCellVerticalEdgeTop];
    } else {
        return YES;
    }
}

- (void)scrollToCollectionViewTop:(BOOL)animated
{
    NOCChatCollectionView *collectionView = self;
    
    CGFloat offsetY = -collectionView.contentInset.top;
    CGPoint contentOffset = CGPointMake(collectionView.contentOffset.x, offsetY);

    [collectionView setContentOffset:contentOffset animated:animated];
}

- (BOOL)isCloseToCollectionViewBottom
{
    NOCChatCollectionView *collectionView = self;
    if (collectionView.contentSize.height > 0) {
        CGFloat maxY = CGRectGetMaxY([self collectionViewVisibleRect]);
        return (maxY / collectionView.contentSize.height) > (1 - self.scrollFractionalThreshold);
    } else {
        return YES;
    }
}

- (BOOL)isScrolledAtCollectionViewBottom
{
    NOCChatCollectionView *collectionView = self;
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
    NOCChatCollectionView *collectionView = self;
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
    UICollectionViewLayoutAttributes *layoutAttributes = [self.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath];
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
    NOCChatCollectionView *collectionView = self;
    UIEdgeInsets contentInset = collectionView.contentInset;
    CGRect bounds = collectionView.bounds;
    CGSize contentSize = collectionView.collectionViewLayout.collectionViewContentSize;
    return CGRectMake(0, collectionView.contentOffset.y + contentInset.top, bounds.size.width, MIN(contentSize.height, bounds.size.height - contentInset.top - contentInset.bottom));
}

- (void)stopScrollIfNeeded
{
    NOCChatCollectionView *collectionView = self;
    if (collectionView.isTracking || collectionView.isDragging || collectionView.isDecelerating) {
        [collectionView setContentOffset:collectionView.contentOffset animated:NO];
    }
}

@end
