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

@property (nonatomic, strong) NSAttributedString *attributedTime;
@property (nonatomic, assign) BOOL hasTail;
@property (nonatomic, strong) UIImage *bubbleImage;
@property (nonatomic, strong) UIImage *highlightBubbleImage;

@property (nonatomic, assign) CGRect bubbleImageViewFrame;
@property (nonatomic, assign) CGRect textLabelFrame;
@property (nonatomic, strong) YYTextLayout *textLayout;
@property (nonatomic, assign) CGRect timeLabelFrame;
@property (nonatomic, assign) CGRect deliveryStatusViewFrame;

@end

@interface TGTextMessageCellLayout (TGStyle)

+ (UIImage *)fullOutgoingBubbleImage;
+ (UIImage *)highlightFullOutgoingBubbleImage;
+ (UIImage *)partialOutgoingBubbleImage;
+ (UIImage *)highlightPartialOutgoingBubbleImage;
+ (UIImage *)fullIncomingBubbleImage;
+ (UIImage *)highlightFullIncomingBubbleImage;
+ (UIImage *)partialIncomingBubbleImage;
+ (UIImage *)highlightPartialIncomingBubbleImage;

+ (UIFont *)textFont;
+ (UIColor *)textColor;
+ (UIColor *)linkColor;
+ (UIColor *)linkBackgroundColor;

+ (UIFont *)timeFont;
+ (UIColor *)outgoingTimeColor;
+ (UIColor *)incomingTimeColor;
+ (NSDateFormatter *)timeFormatter;

@end

@interface TGTextLinePositionModifier : NSObject <YYTextLinePositionModifier>

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, assign) CGFloat paddingTop;
@property (nonatomic, assign) CGFloat paddingBottom;
@property (nonatomic, assign) CGFloat lineHeightMultiple;

- (CGFloat)heightForLineCount:(NSUInteger)lineCount;

@end
