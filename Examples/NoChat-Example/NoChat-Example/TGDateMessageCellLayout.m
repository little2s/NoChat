//
//  TGDateMessageCellLayout.m
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

#import "TGDateMessageCellLayout.h"
#import "TGSystemMessageCellLayout.h"
#import "NOCMessage.h"
#import "UIFont+NoChat.h"
#import "NSAttributedString+NoChat.h"

@implementation TGDateMessageCellLayout {
    UIEdgeInsets _dateLabelInsets;
}

- (instancetype)initWithChatItem:(id<NOCChatItem>)chatItem cellWidth:(CGFloat)width
{
    self = [super init];
    if (self) {
        _reuseIdentifier = @"TGDateMessageCell";
        _chatItem = chatItem;
        _width = width;
        _dateLabelInsets = UIEdgeInsetsMake(2, 10, 2, 10);
        [self setupBackgroundImage];
        [self setupAttributedDate];
        [self calculateLayout];
    }
    return self;
}

- (void)setupBackgroundImage
{
    _backgroundImage = [TGSystemMessageCellLayout systemMessageBackground];
}

- (void)setupAttributedDate
{
    NSString *dateString = [[TGDateMessageCellLayout dateFormatter] stringFromDate:self.message.date];
    NSAttributedString *one = [[NSAttributedString alloc] initWithString:dateString attributes:@{ NSFontAttributeName: [TGDateMessageCellLayout dateFont], NSForegroundColorAttributeName: [TGDateMessageCellLayout dateColor] }];
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

@implementation TGDateMessageCellLayout (TGStyle)

+ (UIFont *)dateFont
{
    static UIFont *_dateFont = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dateFont = [UIFont noc_mediumSystemFontOfSize:13];
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
        _dateFormatter.dateFormat = @"MMMM dd";
    });
    return _dateFormatter;
}

@end
