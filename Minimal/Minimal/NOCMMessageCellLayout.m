//
//  NOCMMessageCellLayout.m
//  NoChat-Example
//
//  Created by little2s on 2016/12/25.
//  Copyright © 2016年 little2s. All rights reserved.
//

#import "NOCMMessageCellLayout.h"
#import "NOCMMessage.h"
#import "UIFont+NOCMinimal.h"

id nocm_contentViewLayout(NSString *type)
{
    if ([type isEqualToString:@"Text"]) {
        return [[NOCMTextMessageContentViewLayout alloc] init];
    } else {
        return nil;
    }
}

NSString *nocm_reuseIdentifier(NSString *type)
{
    if ([type isEqualToString:@"Text"]) {
        return @"NOCMTextMessageCell";
    } else {
        return nil;
    }
}

CGSize nocm_sizeForAttributedString(NSAttributedString *attributedString, CGFloat width)
{
    CGRect rect = [attributedString boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
    return CGRectIntegral(rect).size;
}

@implementation NOCMMessageCellLayout

- (instancetype)initWithChatItem:(id<NOCChatItem>)chatItem cellWidth:(CGFloat)width
{
    self = [super init];
    if (self) {
        NSString *type = ((NOCMMessage *)chatItem).type;
        _reuseIdentifier = nocm_reuseIdentifier(type);
        _chatItem = chatItem;
        _width = width;
        _messageContentViewLayout = nocm_contentViewLayout(type);
        _messageContentViewLayout.cellLayout = self;
        [self calculateLayout];
    }
    return self;
}

- (void)calculateLayout
{
    CGFloat topMargin = 8;
    CGFloat leftMargin = 16;
    CGFloat bottomMargin = 8;
    CGFloat rightMargin = 16;
    
    CGFloat headViewWidth = self.width - leftMargin - rightMargin;
    CGFloat headViewHeight = 25;
    self.headViewFrame = CGRectMake(leftMargin, topMargin, headViewWidth, headViewHeight);
    CGSize senderDisplayNameSize = nocm_sizeForAttributedString([self senderDisplayNameAttributedString], headViewWidth);
    CGSize dateSize = nocm_sizeForAttributedString([self dateAttributedString], headViewWidth);
    
    CGFloat padding = 8;
    CGFloat senderDisplayNameWidth = 0;
    if (senderDisplayNameSize.width + padding + dateSize.width > headViewWidth) {
        senderDisplayNameWidth = headViewWidth - dateSize.width - padding;
    } else {
        senderDisplayNameWidth = senderDisplayNameSize.width;
    }
    self.senderDisplayNameLabelFrame = CGRectMake(0, headViewHeight/2-senderDisplayNameSize.height/2, senderDisplayNameWidth, senderDisplayNameSize.height);
    self.dateLabelFrame = CGRectMake(senderDisplayNameWidth+padding, headViewHeight/2-dateSize.height/2+1, dateSize.width, dateSize.height);
    
    CGFloat contentViewWidth = self.width - leftMargin - rightMargin;
    self.messageContentViewLayout.width = contentViewWidth;
    [self.messageContentViewLayout calculateLayout];
    CGFloat contentViewHeight = self.messageContentViewLayout.height;
    self.contentViewFrame = CGRectMake(leftMargin, topMargin+headViewHeight, contentViewWidth, contentViewHeight);
    
    self.height = topMargin + headViewHeight + contentViewHeight + bottomMargin;
}

- (NSAttributedString *)senderDisplayNameAttributedString
{
    NSString *text = ((NOCMMessage *)self.chatItem).senderDisplayName;
    NSAttributedString *result = [[NSAttributedString alloc] initWithString:text attributes:@{
        NSFontAttributeName: [NOCMMessageCellLayout senderDisplayNameFont]
    }];
    return result;
}

- (NSAttributedString *)dateAttributedString
{
    NSString *text = ((NOCMMessage *)self.chatItem).dateString;
    NSAttributedString *result = [[NSAttributedString alloc] initWithString:text attributes:@{
        NSFontAttributeName: [NOCMMessageCellLayout dateFont]
    }];
    return result;
}

@end

@implementation NOCMMessageCellLayout (NOCMStyle)

+ (UIFont *)senderDisplayNameFont
{
    static id _senderDisplayNameFont = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _senderDisplayNameFont = [UIFont nocm_mediumSystemFontOfSize:16];
    });
    return _senderDisplayNameFont;
}

+ (UIFont *)dateFont
{
    static id _dateFont = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dateFont = [UIFont systemFontOfSize:13];
    });
    return _dateFont;
}

+ (UIColor *)senderDisplayNameColor
{
    return [UIColor blackColor];
}

+ (UIColor *)dateColor
{
    return [UIColor lightGrayColor];
}

@end

// Text Message
@implementation NOCMTextMessageContentViewLayout

- (void)calculateLayout
{
    self.textLabelFrame = CGRectZero;
    self.textLayout = nil;
    
    NSAttributedString *text = [self attributedString];
    if (text.length == 0) {
        return;
    }
    
    NOCMTextLinePositionModifier *modifier = [[NOCMTextLinePositionModifier alloc] init];
    modifier.font = [NOCMTextMessageContentViewLayout textFont];
    modifier.paddingTop = 2;
    modifier.paddingBottom = 2;
    
    NOCMTextContainer *container = [[NOCMTextContainer alloc] init];
    container.size = CGSizeMake(self.width, CGFLOAT_MAX);
    container.linePositionModifier = modifier;
    
    self.textLayout = [NOCMTextLayout layoutWithContainer:container text:text];
    if (!self.textLayout) {
        return;
    }
    
    self.height = [modifier heightForLineCount:self.textLayout.rowCount];
    self.textLabelFrame = CGRectMake(0, 0, self.width, self.height);
}

- (NSAttributedString *)attributedString
{
    NSString *text = ((NOCMMessage *)self.cellLayout.chatItem).text;
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:text attributes:@{ NSFontAttributeName: [NOCMTextMessageContentViewLayout textFont], NSForegroundColorAttributeName: [NOCMTextMessageContentViewLayout textColor] }];
    
    NOCMTextBorder *highlightBorder = [NOCMTextBorder new];
    highlightBorder.insets = UIEdgeInsetsZero;
    highlightBorder.cornerRadius = 3;
    highlightBorder.fillColor = [UIColor colorWithWhite:0.85 alpha:1];

    NSDataDetector *detecor = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray *linkResults = [detecor matchesInString:attrString.string options:kNilOptions range:NSMakeRange(0, attrString.length)];
    for (NSTextCheckingResult *linkResult in linkResults) {
        if (linkResult.range.location == NSNotFound && linkResult.range.length <= 1) {
            continue;
        }
        if ([attrString attribute:NOCMTextHighlightAttributeName atIndex:linkResult.range.length effectiveRange:NULL] == nil) {
            [attrString addAttributes:@{ NSForegroundColorAttributeName: [NOCMTextMessageContentViewLayout linkColor], NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle), NSUnderlineColorAttributeName: [NOCMTextMessageContentViewLayout linkColor] } range:linkResult.range];
            
            NOCMTextHighlight *highlight = [NOCMTextHighlight new];
            [highlight setBackgroundBorder:highlightBorder];
            highlight.userInfo = @{ @"url": [attrString.string substringWithRange:linkResult.range] };
            [attrString addAttribute:NOCMTextHighlightAttributeName value:highlight range:linkResult.range];
        }
    }
    
    return attrString;
}

@end

@implementation NOCMTextMessageContentViewLayout (NOCMStyle)

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

@implementation NOCMTextLinePositionModifier

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

- (void)modifyLines:(NSArray *)lines fromText:(NSAttributedString *)text inContainer:(NOCMTextContainer *)container
{
    CGFloat ascent = _font.pointSize * 0.86;
    
    CGFloat lineHeight = _font.pointSize * _lineHeightMultiple;
    for (NOCMTextLine *line in lines) {
        CGPoint position = line.position;
        position.y = _paddingTop + ascent + line.row  * lineHeight;
        line.position = position;
    }
}

- (id)copyWithZone:(NSZone *)zone
{
    NOCMTextLinePositionModifier *one = [self.class new];
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
