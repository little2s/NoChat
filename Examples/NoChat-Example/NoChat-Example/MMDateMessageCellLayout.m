//
//  MMDateMessageCellLayout.m
//  NoChat-Example
//
//  Created by little2s on 2017/1/26.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import "MMDateMessageCellLayout.h"
#import "MMSystemMessageCellLayout.h"
#import "NOCMessage.h"
#import "UIFont+NoChat.h"
#import "NSAttributedString+NoChat.h"

@implementation MMDateMessageCellLayout {
    UIEdgeInsets _dateLabelInsets;
}

- (instancetype)initWithChatItem:(id<NOCChatItem>)chatItem cellWidth:(CGFloat)width
{
    self = [super init];
    if (self) {
        _reuseIdentifier = @"MMDateMessageCell";
        _chatItem = chatItem;
        _width = width;
        _dateLabelInsets = UIEdgeInsetsMake(4, 6, 4, 6);
        [self setupBackgroundImage];
        [self setupAttributedDate];
        [self calculateLayout];
    }
    return self;
}

- (void)setupBackgroundImage
{
    _backgroundImage = [MMSystemMessageCellLayout systemMessageBackground];
}

- (void)setupAttributedDate
{
    NSString *dateString = [[MMDateMessageCellLayout dateFormatter] stringFromDate:self.message.date];
    NSAttributedString *one = [[NSAttributedString alloc] initWithString:dateString attributes:@{ NSFontAttributeName: [MMDateMessageCellLayout dateFont], NSForegroundColorAttributeName: [MMDateMessageCellLayout dateColor] }];
    _attributedDate = one;
}

- (void)calculateLayout
{
    self.height = 0;
    self.backgroundImageViewFrame = CGRectZero;
    self.dateLabelFrame = CGRectZero;
    
    if (self.attributedDate.length == 0) {
        return;
    }
    
    CGSize limitSize = CGSizeMake(ceil(self.width * 0.75), CGFLOAT_MAX);
    CGSize textLabelSize = [self.attributedDate noc_sizeThatFits:limitSize];
    
    CGFloat vPadding = 4;
    
    self.dateLabelFrame = CGRectMake(self.width/2 - textLabelSize.width/2, vPadding, textLabelSize.width, textLabelSize.height);
    self.backgroundImageViewFrame = CGRectMake(self.dateLabelFrame.origin.x - _dateLabelInsets.left, self.dateLabelFrame.origin.y - _dateLabelInsets.top, self.dateLabelFrame.size.width + _dateLabelInsets.left + _dateLabelInsets.right, self.dateLabelFrame.size.height + _dateLabelInsets.top + _dateLabelInsets.bottom);
    
    self.height = vPadding * 2 + self.backgroundImageViewFrame.size.height;
}

- (NOCMessage *)message
{
    return (NOCMessage *)self.chatItem;
}

@end

@implementation MMDateMessageCellLayout (MMStyle)

+ (UIFont *)dateFont
{
    static UIFont *_dateFont = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dateFont = [UIFont systemFontOfSize:12];
    });
    return _dateFont;
}

+ (UIColor *)dateColor
{
    return [UIColor whiteColor];
}

+ (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *_dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        _dateFormatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    });
    return _dateFormatter;
}

@end
