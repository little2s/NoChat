//
//  TGTextMessageCell.m
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

#import "TGTextMessageCell.h"
#import "TGTextMessageCellLayout.h"
#import "NOCMessage.h"

@implementation TGTextMessageCell

+ (NSString *)reuseIdentifier
{
    return @"TGTextMessageCell";
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        __weak typeof(self) weakSelf = self;
        
        _bubbleImageView = [[UIImageView alloc] init];
        [self.bubbleView addSubview:_bubbleImageView];
        
        _textLabel = [[YYLabel alloc] init];
        _textLabel.textVerticalAlignment = YYTextVerticalAlignmentTop;
        _textLabel.displaysAsynchronously = YES;
        _textLabel.ignoreCommonProperties = YES;
        _textLabel.fadeOnAsynchronouslyDisplay = NO;
        _textLabel.fadeOnHighlight = NO;
        _textLabel.highlightTapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
            if (range.location >= text.length) return;
            YYTextHighlight *highlight = [text yy_attribute:YYTextHighlightAttributeName atIndex:range.location];
            NSDictionary *info = highlight.userInfo;
            if (info.count == 0) return;
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            id<TGTextMessageCellDelegate> delegate = (id<TGTextMessageCellDelegate>) strongSelf.delegate;
            if ([delegate respondsToSelector:@selector(cell:didTapLink:)]) {
                [delegate cell:strongSelf didTapLink:info];
            }
        };
        [self.bubbleView addSubview:_textLabel];
        
        _timeLabel = [[UILabel alloc] init];
        [self.bubbleView addSubview:_timeLabel];
        
        _deliveryStatusView = [[TGDeliveryStatusView alloc] init];
        [self.bubbleView addSubview:_deliveryStatusView];
    }
    return self;
}

- (void)setLayout:(id<NOCChatItemCellLayout>)layout
{
    [super setLayout:layout];
    
    TGTextMessageCellLayout *cellLayout = (TGTextMessageCellLayout *)layout;
    
    self.bubbleImageView.frame = cellLayout.bubbleImageViewFrame;
    self.bubbleImageView.image = self.isHighlight ? cellLayout.highlightBubbleImage : cellLayout.bubbleImage;
    
    self.textLabel.frame = cellLayout.textLabelFrame;
    self.textLabel.textLayout = cellLayout.textLayout;
    
    self.timeLabel.frame = cellLayout.timeLabelFrame;
    self.timeLabel.attributedText = cellLayout.attributedTime;
    
    self.deliveryStatusView.frame = cellLayout.deliveryStatusViewFrame;
    self.deliveryStatusView.deliveryStatus = cellLayout.message.deliveryStatus;
}

@end
