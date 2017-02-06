//
//  NOCChatCollectionViewLayout.h
//  NoChat-Example
//
//  Created by little2s on 2016/12/24.
//  Copyright © 2016年 little2s. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NOCChatCollectionViewLayout;
@protocol NOCChatItemCellLayout;

NS_ASSUME_NONNULL_BEGIN

@protocol NOCChatCollectionViewLayoutDelegate <UICollectionViewDelegate>

@required
- (NSArray<id<NOCChatItemCellLayout>> *)cellLayouts;

@end

@interface NOCChatCollectionViewLayout : UICollectionViewLayout

+ (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForLayouts:(NSArray<id<NOCChatItemCellLayout>> *)layouts containerWidth:(CGFloat)containerWidth maxHeight:(CGFloat)maxHeight contentHeight:(nullable CGFloat *)contentHeight;
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForLayouts:(NSArray<id<NOCChatItemCellLayout>> *)layouts containerWidth:(CGFloat)containerWidth maxHeight:(CGFloat)maxHeight contentHeight:(nullable CGFloat *)contentHeight;

- (BOOL)hasLayoutAttributes;

@end

NS_ASSUME_NONNULL_END
