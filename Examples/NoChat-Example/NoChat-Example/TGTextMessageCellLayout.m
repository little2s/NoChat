//
//  TGTextMessageCellLayout.m
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

#import "TGTextMessageCellLayout.h"
#import "NOCMessage.h"
#import "NSAttributedString+NoChat.h"

@implementation TGTextMessageCellLayout {
    NSMutableAttributedString *_attributedText;
}

- (instancetype)initWithChatItem:(id<NOCChatItem>)chatItem cellWidth:(CGFloat)width
{
    self = [super initWithChatItem:chatItem cellWidth:width];
    if (self) {
        self.reuseIdentifier = @"TGTextMessageCell";
        [self setupAttributedText];
        [self setupAttributedTime];
        [self setupHasTail];
        [self setupBubbleImage];
        [self calculateLayout];
    }
    return self;
}

- (void)setupAttributedText
{
    NSString *text = self.message.text;
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text attributes:@{ NSFontAttributeName: [TGTextMessageCellLayout textFont], NSForegroundColorAttributeName: [TGTextMessageCellLayout textColor] }];
    
    if ([text isEqualToString:@"/start"]) {
        [attributedText yy_setColor:[TGTextMessageCellLayout linkColor] range:attributedText.yy_rangeOfAll];
        
        YYTextBorder *highlightBorder = [YYTextBorder new];
        highlightBorder.insets = UIEdgeInsetsMake(-2, 0, -2, 0);
        highlightBorder.cornerRadius = 2;
        highlightBorder.fillColor = [TGTextMessageCellLayout linkBackgroundColor];
        
        YYTextHighlight *highlight = [YYTextHighlight new];
        [highlight setBackgroundBorder:highlightBorder];
        highlight.userInfo = @{ @"command": text };
        
        [attributedText yy_setTextHighlight:highlight range:attributedText.yy_rangeOfAll];
    }

    _attributedText = attributedText;
}

- (void)setupAttributedTime
{
    NSString *timeString = [[TGTextMessageCellLayout timeFormatter] stringFromDate:self.message.date];
    UIColor *timeColor = self.isOutgoing ? [TGTextMessageCellLayout outgoingTimeColor] : [TGTextMessageCellLayout incomingTimeColor];
    _attributedTime = [[NSAttributedString alloc] initWithString:timeString attributes:@{
        NSFontAttributeName: [TGTextMessageCellLayout timeFont],
        NSForegroundColorAttributeName: timeColor
    }];
}

- (void)setupHasTail
{
    _hasTail = YES;
}

- (void)setupBubbleImage
{
    BOOL isOutgoing = self.isOutgoing;
    BOOL isBubbleFull = self.hasTail;
    _bubbleImage = isOutgoing ? (isBubbleFull ? [TGTextMessageCellLayout fullOutgoingBubbleImage] : [TGTextMessageCellLayout partialOutgoingBubbleImage]) : (isBubbleFull ? [TGTextMessageCellLayout fullIncomingBubbleImage] : [TGTextMessageCellLayout partialIncomingBubbleImage]);
    _highlightBubbleImage = isOutgoing ? (isBubbleFull ? [TGTextMessageCellLayout highlightFullOutgoingBubbleImage] : [TGTextMessageCellLayout highlightPartialOutgoingBubbleImage]) : (isBubbleFull ? [TGTextMessageCellLayout highlightFullIncomingBubbleImage] : [TGTextMessageCellLayout highlightPartialIncomingBubbleImage]);
}

- (void)calculateLayout
{
    self.height = 0;
    self.bubbleViewFrame = CGRectZero;
    self.bubbleImageViewFrame = CGRectZero;
    self.textLabelFrame = CGRectZero;
    self.textLayout = nil;
    self.timeLabelFrame = CGRectZero;
    self.deliveryStatusViewFrame = CGRectZero;
    
    NSMutableAttributedString *text = _attributedText;
    if (text.length == 0) {
        return;
    }
    
    // dynamic font support
    [text yy_setAttribute:NSFontAttributeName value:[TGTextMessageCellLayout textFont]];
    
    BOOL isOutgoing = self.isOutgoing;
    UIEdgeInsets bubbleMargin = self.bubbleViewMargin;
    CGFloat prefrredMaxBubbleWidth = ceil(self.width * 0.75);
    CGFloat bubbleViewWidth = prefrredMaxBubbleWidth;
    
    // prelayout
    CGSize unlimitSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
    CGSize timeLabelSize = [self.attributedTime noc_sizeThatFits:unlimitSize];
    CGFloat timeLabelWidth = timeLabelSize.width;
    CGFloat timeLabelHeight = 15;
    
    CGFloat outgoingStateWidth = (isOutgoing && (self.message.deliveryStatus != NOCMessageDeliveryStatusFailure)) ? 15 : 0;
    CGFloat outgoingStateHeight = outgoingStateWidth;
    
    CGFloat hPadding = 8;
    CGFloat vPadding = 4;
    
    UIEdgeInsets textMargin = isOutgoing ? UIEdgeInsetsMake(8, 10, 8, 15) : UIEdgeInsetsMake(8, 15, 8, 10);
    CGFloat textLabelWidth = bubbleViewWidth - textMargin.left - textMargin.right - hPadding - timeLabelWidth - hPadding/2 - outgoingStateWidth;
    
    TGTextLinePositionModifier *modifier = [[TGTextLinePositionModifier alloc] init];
    modifier.font = [TGTextMessageCellLayout textFont];
    modifier.paddingTop = 2;
    modifier.paddingBottom = 2;
    
    YYTextContainer *container = [[YYTextContainer alloc] init];
    container.size = CGSizeMake(textLabelWidth, CGFLOAT_MAX);
    container.linePositionModifier = modifier;
    
    self.textLayout = [YYTextLayout layoutWithContainer:container text:text];
    if (!self.textLayout) {
        return;
    }
    
    CGFloat bubbleViewHeight = 0;
    if (self.textLayout.rowCount > 1) { // relayout
        textLabelWidth = bubbleViewWidth - textMargin.left - textMargin.right;
        container.size = CGSizeMake(textLabelWidth, CGFLOAT_MAX);
        
        self.textLayout = [YYTextLayout layoutWithContainer:container text:text];
        if (!self.textLayout) {
            return;
        }
        
        // layout content in bubble
        textLabelWidth = ceil(self.textLayout.textBoundingSize.width);
        CGFloat textLabelHeight = ceil([modifier heightForLineCount:self.textLayout.rowCount]);
        self.textLabelFrame = CGRectMake(textMargin.left, textMargin.top, textLabelWidth, textLabelHeight);
        
        CGPoint tryPoint = CGPointMake(textLabelWidth - outgoingStateWidth - hPadding/2 - timeLabelWidth - hPadding, textLabelHeight - timeLabelHeight/2);
        
        BOOL needNewline = ([self.textLayout textRangeAtPoint:tryPoint] != nil);
        if (needNewline) {
            CGFloat x = bubbleViewWidth - textMargin.right - outgoingStateWidth - hPadding/2 - timeLabelWidth;
            CGFloat y = textMargin.top + textLabelHeight;
            
            y += vPadding;
            self.timeLabelFrame = CGRectMake(x, y, timeLabelWidth, timeLabelHeight);
            
            x += (timeLabelWidth + hPadding/2);
            self.deliveryStatusViewFrame = CGRectMake(x, y, outgoingStateWidth, outgoingStateHeight);
            
            bubbleViewHeight = textMargin.top + textLabelHeight + vPadding + timeLabelHeight + textMargin.bottom;
            self.bubbleViewFrame = isOutgoing ? CGRectMake(self.width - bubbleMargin.right - bubbleViewWidth, bubbleMargin.top, bubbleViewWidth, bubbleViewHeight) : CGRectMake(bubbleMargin.left, bubbleMargin.top, bubbleViewWidth, bubbleViewHeight);
            self.bubbleImageViewFrame = CGRectMake(0, 0, bubbleViewWidth, bubbleViewHeight);
        } else {
            bubbleViewHeight = textLabelHeight + textMargin.top + textMargin.bottom;
            self.bubbleViewFrame = isOutgoing ? CGRectMake(self.width - bubbleMargin.right - bubbleViewWidth, bubbleMargin.top, bubbleViewWidth, bubbleViewHeight) : CGRectMake(bubbleMargin.left, bubbleMargin.top, bubbleViewWidth, bubbleViewHeight);
            self.bubbleImageViewFrame = CGRectMake(0, 0, bubbleViewWidth, bubbleViewHeight);
            
            CGFloat x = bubbleViewWidth - textMargin.right - outgoingStateWidth - hPadding/2 - timeLabelWidth;
            CGFloat y = bubbleViewHeight - textMargin.bottom - timeLabelHeight;
            self.timeLabelFrame = CGRectMake(x, y, timeLabelWidth, timeLabelHeight);
            
            x += (timeLabelWidth + hPadding/2);
            self.deliveryStatusViewFrame = CGRectMake(x, y, outgoingStateWidth, outgoingStateHeight);
        }
    } else {
        textLabelWidth = ceil(self.textLayout.textBoundingSize.width);
        CGFloat textLabelHeight = ceil([modifier heightForLineCount:self.textLayout.rowCount]);
        
        bubbleViewWidth = textMargin.left + textLabelWidth + hPadding + timeLabelWidth + hPadding/2 +  outgoingStateWidth + textMargin.right;
        bubbleViewHeight = textLabelHeight + textMargin.top + textMargin.bottom;
        self.bubbleViewFrame = isOutgoing ? CGRectMake(self.width - bubbleMargin.right - bubbleViewWidth, bubbleMargin.top, bubbleViewWidth, bubbleViewHeight) : CGRectMake(bubbleMargin.left, bubbleMargin.top, bubbleViewWidth, bubbleViewHeight);
        self.bubbleImageViewFrame = CGRectMake(0, 0, bubbleViewWidth, bubbleViewHeight);
        
        CGFloat x = textMargin.left;
        CGFloat y = textMargin.top;
        self.textLabelFrame = CGRectMake(x, y, textLabelWidth, textLabelHeight);
        
        x += textLabelWidth + hPadding;
        y = bubbleViewHeight - textMargin.bottom - timeLabelHeight;
        self.timeLabelFrame = CGRectMake(x, y, timeLabelWidth, timeLabelHeight);
        
        x += (timeLabelWidth + hPadding/2);
        self.deliveryStatusViewFrame = CGRectMake(x, y, outgoingStateWidth, outgoingStateHeight);
    }
    
    self.height = bubbleViewHeight + bubbleMargin.top + bubbleMargin.bottom;
}

@end

@implementation TGTextMessageCellLayout (TGStyle)

+ (UIImage *)fullOutgoingBubbleImage
{
    static UIImage *_fullOutgoingBubbleImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _fullOutgoingBubbleImage = [UIImage imageNamed:@"TGBubbleOutgoingFull"];
    });
    return _fullOutgoingBubbleImage;
}

+ (UIImage *)highlightFullOutgoingBubbleImage
{
    static UIImage *_highlightFullOutgoingBubbleImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _highlightFullOutgoingBubbleImage = [UIImage imageNamed:@"TGBubbleOutgoingFullHL"];
    });
    return _highlightFullOutgoingBubbleImage;
}

+ (UIImage *)partialOutgoingBubbleImage
{
    static UIImage *_partialOutgoingBubbleImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _partialOutgoingBubbleImage = [UIImage imageNamed:@"TGBubbleOutgoingPartial"];
    });
    return _partialOutgoingBubbleImage;
}

+ (UIImage *)highlightPartialOutgoingBubbleImage
{
    static UIImage *_highlightPartialOutgoingBubbleImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _highlightPartialOutgoingBubbleImage = [UIImage imageNamed:@"TGBubbleOutgoingPartialHL"];
    });
    return _highlightPartialOutgoingBubbleImage;
}

+ (UIImage *)fullIncomingBubbleImage
{
    static UIImage *_fullIncomingBubbleImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _fullIncomingBubbleImage = [UIImage imageNamed:@"TGBubbleIncomingFull"];
    });
    return _fullIncomingBubbleImage;
}

+ (UIImage *)highlightFullIncomingBubbleImage
{
    static UIImage *_highlightFullIncomingBubbleImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _highlightFullIncomingBubbleImage = [UIImage imageNamed:@"TGBubbleIncomingFullHL"];
    });
    return _highlightFullIncomingBubbleImage;
}

+ (UIImage *)partialIncomingBubbleImage
{
    static UIImage *_partialIncomingBubbleImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _partialIncomingBubbleImage = [UIImage imageNamed:@"TGBubbleIncomingPartial"];
    });
    return _partialIncomingBubbleImage;
}

+ (UIImage *)highlightPartialIncomingBubbleImage
{
    static UIImage *_highlightPartialIncomingBubbleImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _highlightPartialIncomingBubbleImage = [UIImage imageNamed:@"TGBubbleIncomingPartialHL"];
    });
    return _highlightPartialIncomingBubbleImage;
}

+ (UIFont *)textFont
{
    return [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}

+ (UIColor *)textColor
{
    return [UIColor blackColor];
}

+ (UIColor *)linkColor
{
    static UIColor *_linkColor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _linkColor = [UIColor colorWithRed:0/255.0 green:75/255.0 blue:173/255.0 alpha:1];
    });
    return _linkColor;
}

+ (UIColor *)linkBackgroundColor
{
    static UIColor *_linkBackgroundColor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _linkBackgroundColor = [UIColor colorWithRed:191/255.0 green:223/255.0 blue:254/255.0 alpha:1];
    });
    return _linkBackgroundColor;
}

+ (UIFont *)timeFont
{
    static UIFont *_timeFont = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _timeFont = [UIFont italicSystemFontOfSize:12];
    });
    return _timeFont;
}

+ (UIColor *)outgoingTimeColor
{
    static UIColor *_outgoingTimeColor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _outgoingTimeColor = [UIColor colorWithRed:59/255.0 green:171/255.0 blue:61/255.0 alpha:1];
    });
    return _outgoingTimeColor;
}

+ (UIColor *)incomingTimeColor
{
    return [UIColor lightGrayColor];
}

+ (NSDateFormatter *)timeFormatter
{
    static NSDateFormatter *_timeFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _timeFormatter = [[NSDateFormatter alloc] init];
        _timeFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        _timeFormatter.dateFormat = @"h:mm a";
    });
    return _timeFormatter;
}

@end

@implementation TGTextLinePositionModifier

- (instancetype)init
{
    self = [super init];
    if ([NSProcessInfo.processInfo isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){9,0,0}]) {
        _lineHeightMultiple = 1.34;   // for PingFang SC
    } else {
        _lineHeightMultiple = 1.3125; // for Heiti SC
    }
    return self;
}

- (void)modifyLines:(NSArray *)lines fromText:(NSAttributedString *)text inContainer:(YYTextContainer *)container
{
    CGFloat ascent = _font.pointSize * 0.86;
    
    CGFloat lineHeight = _font.pointSize * _lineHeightMultiple;
    for (YYTextLine *line in lines) {
        CGPoint position = line.position;
        position.y = _paddingTop + ascent + line.row  * lineHeight;
        line.position = position;
    }
}

- (id)copyWithZone:(NSZone *)zone
{
    TGTextLinePositionModifier *one = [self.class new];
    one->_font = _font;
    one->_paddingTop = _paddingTop;
    one->_paddingBottom = _paddingBottom;
    one->_lineHeightMultiple = _lineHeightMultiple;
    return one;
}

- (CGFloat)heightForLineCount:(NSUInteger)lineCount
{
    if (lineCount == 0) return 0;
    CGFloat ascent = _font.pointSize * 0.86;
    CGFloat descent = _font.pointSize * 0.14;
    CGFloat lineHeight = _font.pointSize * _lineHeightMultiple;
    return _paddingTop + _paddingBottom + ascent + descent + (lineCount - 1) * lineHeight;
}

@end
