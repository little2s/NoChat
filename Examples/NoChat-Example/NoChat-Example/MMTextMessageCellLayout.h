//
//  MMTextMessageCellLayout.h
//  NoChat-Example
//
//  Created by little2s on 2017/1/22.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import "MMBaseMessageCellLayout.h"
#import <YYText/YYText.h>

@interface MMTextMessageCellLayout : MMBaseMessageCellLayout

@property (nonatomic, assign) CGRect textLabelFrame;
@property (nonatomic, strong) YYTextLayout *textLayout;

@end

@interface MMTextMessageCellLayout (MMStyle)

+ (UIFont *)textFont;
+ (UIColor *)textColor;
+ (UIColor *)linkColor;

@end

@interface MMTextLinePositionModifier : NSObject <YYTextLinePositionModifier>

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, assign) CGFloat paddingTop;
@property (nonatomic, assign) CGFloat paddingBottom;
@property (nonatomic, assign) CGFloat lineHeightMultiple;

- (CGFloat)heightForLineCount:(NSUInteger)lineCount;

@end
