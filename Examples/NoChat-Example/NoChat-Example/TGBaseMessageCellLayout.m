//
//  TGBaseMessageCellLayout.m
//  NoChat-Example
//
//  Created by little2s on 2017/1/22.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import "TGBaseMessageCellLayout.h"
#import "NOCMessage.h"

@implementation TGBaseMessageCellLayout

- (instancetype)initWithChatItem:(id<NOCChatItem>)chatItem cellWidth:(CGFloat)width
{
    self = [super init];
    if (self) {
        _reuseIdentifier = @"TGBaseMessageCell";
        _chatItem = chatItem;
        _width = width;
        _bubbleViewMargin = UIEdgeInsetsMake(4, 2, 4, 2);
    }
    return self;
}

- (void)calculateLayout
{
    
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
