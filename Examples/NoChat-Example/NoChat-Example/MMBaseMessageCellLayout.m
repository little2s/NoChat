//
//  MMBaseMessageCellLayout.m
//  NoChat-Example
//
//  Created by little2s on 2017/1/22.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import "MMBaseMessageCellLayout.h"
#import "NOCMessage.h"

@implementation MMBaseMessageCellLayout

- (instancetype)initWithChatItem:(id<NOCChatItem>)chatItem cellWidth:(CGFloat)width
{
    self = [super init];
    if (self) {
        _reuseIdentifier = @"MMBaseMessageCell";
        _chatItem = chatItem;
        _width = width;
        _bubbleViewMargin = UIEdgeInsetsMake(8, 52, 8, 52);
        _avatarSize = 40;
        _avatarImage = self.isOutgoing ? [MMBaseMessageCellLayout outgoingAvatarImage] : [MMBaseMessageCellLayout incomingAvatarImage];
    }
    return self;
}

- (void)calculateLayout
{
    CGFloat avatarWidth = self.avatarSize;
    CGFloat avatarHeight = self.avatarSize;
    self.avatarImageViewFrame = self.isOutgoing ? CGRectMake(self.width - 8 - avatarWidth, 11, avatarWidth, avatarHeight) : CGRectMake(8, 11, avatarWidth, avatarHeight);
}

- (NOCMessage *)message
{
    return (NOCMessage *)self.chatItem;
}

- (BOOL)isOutgoing
{
    return self.message.isOutgoing;
}

@end

@implementation MMBaseMessageCellLayout (MMStyle)

+ (UIImage *)outgoingAvatarImage
{
    static UIImage *_outgoingAvatarImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _outgoingAvatarImage = [UIImage imageNamed:@"MMAvatarOutgoing"];
    });
    return _outgoingAvatarImage;
}

+ (UIImage *)incomingAvatarImage
{
    static UIImage *_incomingAvatarImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _incomingAvatarImage = [UIImage imageNamed:@"MMAvatarIncoming"];
    });
    return _incomingAvatarImage;
}

@end
