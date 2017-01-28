//
//  TGTextMessageCell.m
//  NoChat-Example
//
//  Created by little2s on 2017/1/21.
//  Copyright © 2017年 little2s. All rights reserved.
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
