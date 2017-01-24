//
//  MMTextMessageCellLayout.m
//  NoChat-Example
//
//  Created by little2s on 2017/1/22.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import "MMTextMessageCellLayout.h"
#import "NOCMessage.h"

@implementation MMTextMessageCellLayout {
    NSMutableAttributedString *_attributedText;
}

- (instancetype)initWithChatItem:(id<NOCChatItem>)chatItem cellWidth:(CGFloat)width
{
    self = [super initWithChatItem:chatItem cellWidth:width];
    if (self) {
        self.reuseIdentifier = @"MMTextMessageCell";
        [self setupAttributedText];
        [self setupBubbleImage];
        [self calculateLayout];
    }
    return self;
}

- (void)setupAttributedText
{
    NSString *text = self.message.text;
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:text attributes:@{ NSFontAttributeName: [MMTextMessageCellLayout textFont], NSForegroundColorAttributeName: [MMTextMessageCellLayout textColor] }];
    
    YYTextBorder *highlightBorder = [YYTextBorder new];
    highlightBorder.insets = UIEdgeInsetsZero;
    highlightBorder.cornerRadius = 3;
    highlightBorder.fillColor = [UIColor colorWithWhite:0.85 alpha:1];
    
    NSDataDetector *detecor = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray *linkResults = [detecor matchesInString:attrString.string options:kNilOptions range:NSMakeRange(0, attrString.length)];
    for (NSTextCheckingResult *linkResult in linkResults) {
        if (linkResult.range.location == NSNotFound && linkResult.range.length <= 1) {
            continue;
        }
        if ([attrString attribute:YYTextHighlightAttributeName atIndex:linkResult.range.length effectiveRange:NULL] == nil) {
            [attrString addAttributes:@{ NSForegroundColorAttributeName: [MMTextMessageCellLayout linkColor], NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle), NSUnderlineColorAttributeName: [MMTextMessageCellLayout linkColor] } range:linkResult.range];
            
            YYTextHighlight *highlight = [YYTextHighlight new];
            [highlight setBackgroundBorder:highlightBorder];
            highlight.userInfo = @{ @"url": [attrString.string substringWithRange:linkResult.range] };
            [attrString addAttribute:YYTextHighlightAttributeName value:highlight range:linkResult.range];
        }
    }
    
    _attributedText = attrString;
}

- (void)setupBubbleImage
{
    _bubbleImage = self.isOutgoing ? [MMTextMessageCellLayout outgoingBubbleImage] : [MMTextMessageCellLayout incomingBubbleImage];
    _highlightBubbleImage = self.isOutgoing ?[MMTextMessageCellLayout highlightOutgoingBubbleImage] : [MMTextMessageCellLayout highlightIncomingBubbleImage];
}

- (void)calculateLayout
{
    self.height = 0;
    self.avatarImageViewFrame = CGRectZero;
    self.bubbleViewFrame = CGRectZero;
    self.bubbleImageViewFrame = CGRectZero;
    self.textLabelFrame = CGRectZero;
    self.textLayout = nil;
    
    NSMutableAttributedString *text = _attributedText;
    if (text.length == 0) {
        return;
    }
    
    // dynamic font support
    [text yy_setAttribute:NSFontAttributeName value:[MMTextMessageCellLayout textFont]];
    
    BOOL isOutgoing = self.isOutgoing;
    UIEdgeInsets bubbleMargin = self.bubbleViewMargin;
    CGFloat prefrredMaxBubbleWidth = ceil(self.width * 0.68);
    CGFloat bubbleViewWidth = prefrredMaxBubbleWidth;
    
    UIEdgeInsets textMargin = isOutgoing ? UIEdgeInsetsMake(12, 20, 20, 22) : UIEdgeInsetsMake(12, 22, 20, 20);
    CGFloat textLabelWidth = bubbleViewWidth - textMargin.left - textMargin.right;
    
    MMTextLinePositionModifier *modifier = [[MMTextLinePositionModifier alloc] init];
    modifier.font = [MMTextMessageCellLayout textFont];
    modifier.paddingTop = 2;
    modifier.paddingBottom = 2;
    
    YYTextContainer *container = [[YYTextContainer alloc] init];
    container.size = CGSizeMake(textLabelWidth, CGFLOAT_MAX);
    container.linePositionModifier = modifier;
    
    self.textLayout = [YYTextLayout layoutWithContainer:container text:text];
    if (!self.textLayout) {
        return;
    }
    
    textLabelWidth = ceil(self.textLayout.textBoundingSize.width);
    CGFloat textLabelHeight = ceil([modifier heightForLineCount:self.textLayout.rowCount]);
    self.textLabelFrame = CGRectMake(textMargin.left, textMargin.top, textLabelWidth, textLabelHeight);
    
    bubbleViewWidth = textLabelWidth + textMargin.left + textMargin.right;
    CGFloat bubbleViewHeight = textLabelHeight + textMargin.top + textMargin.bottom;
    self.bubbleViewFrame = isOutgoing ? CGRectMake(self.width - bubbleMargin.right - bubbleViewWidth, bubbleMargin.top, bubbleViewWidth, bubbleViewHeight) : CGRectMake(bubbleMargin.left, bubbleMargin.top, bubbleViewWidth, bubbleViewHeight);
    self.bubbleImageViewFrame = CGRectMake(0, 0, bubbleViewWidth, bubbleViewHeight);
    
    CGFloat avatarWidth = self.avatarSize;
    CGFloat avatarHeight = self.avatarSize;
    self.avatarImageViewFrame = self.isOutgoing ? CGRectMake(self.width - 8 - avatarWidth, 8, avatarWidth, avatarHeight) : CGRectMake(8, 8, avatarWidth, avatarHeight);
    
    self.height = bubbleViewHeight;
}

@end

@implementation MMTextMessageCellLayout (MMStyle)

+ (UIImage *)outgoingBubbleImage
{
    static UIImage *_outgoingBubbleImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _outgoingBubbleImage = [UIImage imageNamed:@"MMBubbleOutgoing"];
    });
    return _outgoingBubbleImage;
}

+ (UIImage *)highlightOutgoingBubbleImage
{
    static UIImage *_highlightOutgoingBubbleImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _highlightOutgoingBubbleImage = [UIImage imageNamed:@"MMBubbleOutgoingHL"];
    });
    return _highlightOutgoingBubbleImage;
}

+ (UIImage *)incomingBubbleImage
{
    static UIImage *_incomingBubbleImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _incomingBubbleImage = [UIImage imageNamed:@"MMBubbleIncoming"];
    });
    return _incomingBubbleImage;
}

+ (UIImage *)highlightIncomingBubbleImage
{
    static UIImage *_highlightIncomingBubbleImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _highlightIncomingBubbleImage = [UIImage imageNamed:@"MMBubbleIncomingHL"];
    });
    return _highlightIncomingBubbleImage;
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
    return [UIColor blueColor];
}

@end

@implementation MMTextLinePositionModifier

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
    MMTextLinePositionModifier *one = [self.class new];
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

