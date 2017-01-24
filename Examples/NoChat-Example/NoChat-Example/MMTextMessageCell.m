//
//  MMTextMessageCell.m
//  NoChat-Example
//
//  Created by little2s on 2017/1/22.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import "MMTextMessageCell.h"
#import "MMTextMessageCellLayout.h"

@implementation MMTextMessageCell

+ (NSString *)reuseIdentifier
{
    return @"MMTextMessageCell";
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        __weak typeof(self) weakSelf = self;
        
        _bubbleImageView = [[UIImageView alloc] init];
        [self.bubbleView addSubview:_bubbleImageView];
        
        _textLabel = [[YYLabel alloc] init];
        _textLabel.displaysAsynchronously = YES;
        _textLabel.ignoreCommonProperties = YES;
        _textLabel.highlightTapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [text enumerateAttribute:YYTextHighlightAttributeName inRange:range options:0 usingBlock:^(YYTextHighlight *textHighlight, NSRange range, BOOL *stop) {
                if (textHighlight && textHighlight.userInfo) {
                    NSURL *linkURL = textHighlight.userInfo[@"url"];
                    if (linkURL) {
                        id<MMTextMessageCellDelegate> delegate = (id<MMTextMessageCellDelegate>) strongSelf.delegate;
                        if (delegate && [delegate respondsToSelector:@selector(cell:didTapLink:)]) {
                            [delegate cell:strongSelf didTapLink:linkURL];
                        }
                    }
                }
            }];
        };
        [self.bubbleView addSubview:_textLabel];
    }
    return self;
}

- (void)setLayout:(id<NOCChatItemCellLayout>)layout
{
    [super setLayout:layout];

    MMTextMessageCellLayout *cellLayout = (MMTextMessageCellLayout *)layout;
    
    self.bubbleImageView.frame = cellLayout.bubbleImageViewFrame;
    self.bubbleImageView.image = self.isHighlight ? cellLayout.highlightBubbleImage : cellLayout.bubbleImage;
    
    self.textLabel.frame = cellLayout.textLabelFrame;
    self.textLabel.textLayout = cellLayout.textLayout;
}

@end

