//
//  MMTextMessageCellLayout.m
//  NoChat-Example
//
//  Created by little2s on 2017/1/22.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import "MMTextMessageCellLayout.h"
#import "NOCMessage.h"

@implementation MMTextMessageCellLayout

- (instancetype)initWithChatItem:(id<NOCChatItem>)chatItem cellWidth:(CGFloat)width
{
    self = [super initWithChatItem:chatItem cellWidth:width];
    if (self) {
        self.reuseIdentifier = @"MMTextMessageCell";
    }
    return self;
}

- (void)calculateLayout
{
    self.height = 0;
    self.bubbleViewFrame = CGRectZero;
    self.textLabelFrame = CGRectZero;
    self.textLayout = nil;
    
    NSAttributedString *text = [self attributedString];
    if (text.length == 0) {
        return;
    }
    
    UIEdgeInsets margin = self.bubbleViewMargin;
    CGFloat bubbleViewWidth = self.width - margin.left - margin.right;
    CGFloat textLabelWidth = bubbleViewWidth;
    
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
    
    CGFloat textLabelHeight = [modifier heightForLineCount:self.textLayout.rowCount];
    self.textLabelFrame = CGRectMake(0, 0, textLabelWidth, textLabelHeight);
    
    CGFloat bubbleViewHeight = textLabelHeight;
    self.bubbleViewFrame = CGRectMake(margin.left, margin.top, bubbleViewWidth, bubbleViewHeight);
    
    self.height = bubbleViewHeight + margin.top + margin.bottom;
}

- (NSAttributedString *)attributedString
{
    NSString *text = ((NOCMessage *)self.chatItem).text;
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
    
    return attrString;
}

@end

@implementation MMTextMessageCellLayout (MMStyle)

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

