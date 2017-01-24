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
    }
    return self;
}

- (void)calculateLayout
{
    NSAssert(NO, @"Impl in subclass");
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
