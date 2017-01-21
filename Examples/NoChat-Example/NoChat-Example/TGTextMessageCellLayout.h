//
//  TGTextMessageCellLayout.h
//  NoChat-Example
//
//  Created by little2s on 2017/1/21.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import "TGBaseMessageCellLayout.h"
#import <YYText/YYText.h>

@interface TGTextMessageCellLayout : TGBaseMessageCellLayout

@property (nonatomic, assign) CGRect textLabelFrame;
@property (nonatomic, strong) YYTextLayout *textLayout;

@end

@interface TGTextMessageCellLayout (TGStyle)

+ (UIFont *)textFont;
+ (UIColor *)textColor;
+ (UIColor *)linkColor;

@end

@interface TGTextLinePositionModifier : NSObject <YYTextLinePositionModifier>

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, assign) CGFloat paddingTop;
@property (nonatomic, assign) CGFloat paddingBottom;
@property (nonatomic, assign) CGFloat lineHeightMultiple;

- (CGFloat)heightForLineCount:(NSUInteger)lineCount;

@end
