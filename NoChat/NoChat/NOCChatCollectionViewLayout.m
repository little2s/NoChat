//
//  NOCChatCollectionViewLayout.m
//  NoChat-Example
//
//  Created by little2s on 2016/12/24.
//  Copyright © 2016年 little2s. All rights reserved.
//

#import "NOCChatCollectionViewLayout.h"
#import "NOCChatItemCellLayout.h"

@implementation NOCChatCollectionViewLayout {
    NSMutableArray *_layoutAttributes;
    CGSize _contentSize;
}

#pragma mark - Overrides

- (instancetype)init
{
    self = [super init];
    if (self) {
        _layoutAttributes = [[NSMutableArray alloc] init];
        _contentSize = CGSizeZero;
    }
    return self;
}

- (void)prepareLayout
{
    [super prepareLayout];
    
    [_layoutAttributes removeAllObjects];
    
    CGFloat contentHeight = 0;
    [_layoutAttributes addObjectsFromArray:[self layoutAttributesForLayouts:[(id<NOCChatCollectionViewLayoutDelegate>)self.collectionView.delegate cellLayouts] containerWidth:self.collectionView.bounds.size.width maxHeight:CGFLOAT_MAX contentHeight:&contentHeight]];
    
    _contentSize = CGSizeMake(self.collectionView.bounds.size.width, contentHeight);
}

- (CGSize)collectionViewContentSize
{
    return _contentSize;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (UICollectionViewLayoutAttributes *attributes in _layoutAttributes) {
        if (!CGRectIsNull(CGRectIntersection(rect, attributes.frame))) {
            [array addObject:attributes];
        }
    }
    
    return array;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= _layoutAttributes.count) {
        return nil;
    }
    
    return _layoutAttributes[indexPath.row];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return NO;
}

#pragma mark - Public

- (BOOL)hasLayoutAttributes
{
    return _contentSize.height > FLT_EPSILON;
}

- (NSArray *)layoutAttributesForLayouts:(NSArray *)layouts containerWidth:(CGFloat)containerWidth maxHeight:(CGFloat)maxHeight contentHeight:(CGFloat *)contentHeight
{
    return [NOCChatCollectionViewLayout layoutAttributesForLayouts:layouts containerWidth:containerWidth maxHeight:maxHeight contentHeight:contentHeight];
}

+ (NSArray *)layoutAttributesForLayouts:(NSArray *)layouts containerWidth:(CGFloat)containerWidth maxHeight:(CGFloat)maxHeight contentHeight:(CGFloat *)contentHeight
{
    NSMutableArray *layoutAttributes = [[NSMutableArray alloc] init];
    
    __block CGFloat verticalOffset = 0;
    
    [layouts enumerateObjectsUsingBlock:^(id<NOCChatItemCellLayout> layout, NSUInteger i, BOOL *stop) {
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        
        if (ABS(layout.width - containerWidth) > FLT_EPSILON) {
            layout.width = containerWidth;
            [layout calculateLayout];
        }
        attributes.frame = CGRectMake(0, verticalOffset, layout.width, layout.height);
        
        [layoutAttributes addObject:attributes];
        
        verticalOffset += layout.height;
    }];
    
    if (contentHeight != NULL) {
        *contentHeight = MIN(verticalOffset, maxHeight);
    }
    
    return layoutAttributes;
}

@end
