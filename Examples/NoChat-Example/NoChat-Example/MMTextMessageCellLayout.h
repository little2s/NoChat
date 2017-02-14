//
//  MMTextMessageCellLayout.h
//  NoChat-Example
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

#import "MMBaseMessageCellLayout.h"
#import <YYText/YYText.h>

@interface MMTextMessageCellLayout : MMBaseMessageCellLayout


@property (nonatomic, strong) UIImage *bubbleImage;
@property (nonatomic, strong) UIImage *highlightBubbleImage;

@property (nonatomic, assign) CGRect bubbleImageViewFrame;
@property (nonatomic, assign) CGRect textLabelFrame;
@property (nonatomic, strong) YYTextLayout *textLayout;

@end

@interface MMTextMessageCellLayout (MMStyle)

+ (UIImage *)outgoingBubbleImage;
+ (UIImage *)highlightOutgoingBubbleImage;
+ (UIImage *)incomingBubbleImage;
+ (UIImage *)highlightIncomingBubbleImage;

+ (UIFont *)textFont;
+ (UIColor *)textColor;
+ (UIColor *)linkColor;
+ (UIColor *)linkBackgroundColor;

@end

@interface MMTextLinePositionModifier : NSObject <YYTextLinePositionModifier>

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, assign) CGFloat paddingTop;
@property (nonatomic, assign) CGFloat paddingBottom;
@property (nonatomic, assign) CGFloat lineHeightMultiple;

- (CGFloat)heightForLineCount:(NSUInteger)lineCount;

@end
