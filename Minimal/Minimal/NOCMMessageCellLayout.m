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
    CGSize size = nocm_sizeForAttributedString([self attributedString], self.width);
    self.height = size.height;
    self.textLabelFrame = CGRectMake(0, 0, self.width, self.height);
}

- (NSAttributedString *)attributedString
{
    NSString *text = ((NOCMMessage *)self.cellLayout.chatItem).text;
    NSAttributedString *result = [[NSAttributedString alloc] initWithString:text attributes:@{
        NSFontAttributeName: [NOCMTextMessageContentViewLayout textFont]
    }];
    return result;
}

@end

@implementation NOCMTextMessageContentViewLayout (NOCMStyle)

+ (UIFont *)textFont
{
    static id _textFont = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _textFont = [UIFont systemFontOfSize:16];
    });
    return _textFont;
}

+ (UIColor *)textColor
{
    return [UIColor blackColor];
}

@end
