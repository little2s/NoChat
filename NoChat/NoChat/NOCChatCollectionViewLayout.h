//
//  NOCChatCollectionViewLayout.h
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

#import <UIKit/UIKit.h>

@class NOCChatCollectionViewLayout;
@protocol NOCChatItemCellLayout;

NS_ASSUME_NONNULL_BEGIN

@protocol NOCChatCollectionViewLayoutDelegate <UICollectionViewDelegate>

@required
- (NSArray<id<NOCChatItemCellLayout>> *)cellLayouts;

@end

@interface NOCChatCollectionViewLayout : UICollectionViewLayout

@property (nonatomic, assign) UIEdgeInsets inset;

- (instancetype)initWithInverted:(BOOL)inverted;

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForLayouts:(NSArray<id<NOCChatItemCellLayout>> *)layouts containerWidth:(CGFloat)containerWidth maxHeight:(CGFloat)maxHeight contentHeight:(nullable CGFloat *)contentHeight;

- (BOOL)hasLayoutAttributes;

@end

NS_ASSUME_NONNULL_END
