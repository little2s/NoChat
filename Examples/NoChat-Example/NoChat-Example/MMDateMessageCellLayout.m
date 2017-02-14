//
//  MMDateMessageCellLayout.m
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
