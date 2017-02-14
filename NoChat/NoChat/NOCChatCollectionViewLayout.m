//
//  NOCChatCollectionViewLayout.m
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

#import "NOCChatCollectionViewLayout.h"
#import "NOCChatItemCellLayout.h"

@implementation NOCChatCollectionViewLayout {
    BOOL _isInverted;
    
    NSMutableArray *_layoutAttributes;
    CGSize _contentSize;
    
    NSMutableArray *_insertIndexPaths;
    NSMutableArray *_deleteIndexPaths;
}

#pragma mark - Overrides

- (instancetype)initWithInverted:(BOOL)inverted
{
    self = [super init];
    if (self) {
        _isInverted = inverted;
        [self commonInit];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isInverted = YES;
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _layoutAttributes = [[NSMutableArray alloc] init];
    _contentSize = CGSizeZero;
    _inset = UIEdgeInsetsMake(8, 0, 8, 0);
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

#pragma mark - Animation

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{
    [super prepareForCollectionViewUpdates:updateItems];
    
    if (!_isInverted) {
        return;
    }
    
    _deleteIndexPaths = [NSMutableArray array];
    _insertIndexPaths = [NSMutableArray array];
    
    for (UICollectionViewUpdateItem *update in updateItems) {
        if (update.updateAction == UICollectionUpdateActionDelete) {
            [_deleteIndexPaths addObject:update.indexPathBeforeUpdate];
        } else if (update.updateAction == UICollectionUpdateActionInsert) {
            [_insertIndexPaths addObject:update.indexPathAfterUpdate];
        }
    }
}

- (void)finalizeCollectionViewUpdates
{
    [super finalizeCollectionViewUpdates];
    
    if (!_isInverted) {
        return;
    }
    
    _deleteIndexPaths = nil;
    _insertIndexPaths = nil;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes *attributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
    
    if (!_isInverted) {
        return attributes;
    }
    
    if ([_insertIndexPaths containsObject:itemIndexPath]) {
        if (!attributes) {
            attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
        }
        
        attributes = [attributes copy];
        
        attributes.transform3D = CATransform3DMakeTranslation(0, -floor(attributes.frame.size.height * 1.125), 0);
        
        attributes.alpha = 0;
    }
    
    return attributes;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes *attributes = [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];
    
    if (!_isInverted) {
        return attributes;
    }
    
    if ([_deleteIndexPaths containsObject:itemIndexPath]) {
        attributes = [attributes copy];
        
        attributes.alpha = 0;
    }
    
    return attributes;
}

#pragma mark - Public

- (BOOL)hasLayoutAttributes
{
    return _contentSize.height > FLT_EPSILON;
}

- (NSArray *)layoutAttributesForLayouts:(NSArray *)layouts containerWidth:(CGFloat)containerWidth maxHeight:(CGFloat)maxHeight contentHeight:(CGFloat *)contentHeight
{
    NSMutableArray *layoutAttributes = [[NSMutableArray alloc] init];
    
    __block CGFloat verticalOffset = _inset.top;
    
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
    
    verticalOffset += _inset.bottom;
    
    if (contentHeight != NULL) {
        *contentHeight = MIN(verticalOffset, maxHeight);
    }
    
    return layoutAttributes;
}

@end
