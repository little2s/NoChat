//
//  MMBaseMessageCell.m
//  NoChat-Example
//
//  Created by little2s on 2017/1/22.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import "MMBaseMessageCell.h"
#import "MMBaseMessageCellLayout.h"

@implementation MMBaseMessageCell

+ (NSString *)reuseIdentifier
{
    return @"MMBaseMessageCell";
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _messageView = [[UIView alloc] init];
        [self.contentView addSubview:_messageView];
        
        _avatarImageView = [[UIImageView alloc] init];
        [_messageView addSubview:_avatarImageView];
        
        _bubbleView = [[UIView alloc] init];
        [_messageView addSubview:_bubbleView];
    }
    return self;
}

- (void)setLayout:(id<NOCChatItemCellLayout>)layout
{
    [super setLayout:layout];
    self.messageView.frame = CGRectMake(0, 0, layout.width, layout.height);
    
    MMBaseMessageCellLayout *cellLayout = (MMBaseMessageCellLayout *)layout;
    self.bubbleView.frame = cellLayout.bubbleViewFrame;
    self.avatarImageView.frame = cellLayout.avatarImageViewFrame;
    self.avatarImageView.image = cellLayout.avatarImage;
}

@end
