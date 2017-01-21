//
//  TGTextMessageCell.m
//  NoChat-Example
//
//  Created by little2s on 2017/1/21.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import "TGTextMessageCell.h"
#import "TGTextMessageCellLayout.h"

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
        _textLabel = [[YYLabel alloc] init];
        _textLabel.displaysAsynchronously = YES;
        _textLabel.ignoreCommonProperties = YES;
        _textLabel.highlightTapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [text enumerateAttribute:YYTextHighlightAttributeName inRange:range options:0 usingBlock:^(YYTextHighlight *textHighlight, NSRange range, BOOL *stop) {
                if (textHighlight && textHighlight.userInfo) {
                    NSURL *linkURL = textHighlight.userInfo[@"url"];
                    if (linkURL) {
                        id<TGTextMessageCellDelegate> delegate = (id<TGTextMessageCellDelegate>) strongSelf.delegate;
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
    self.textLabel.frame = ((TGTextMessageCellLayout *)layout).textLabelFrame;
    self.textLabel.textLayout = ((TGTextMessageCellLayout *)layout).textLayout;
}

@end
