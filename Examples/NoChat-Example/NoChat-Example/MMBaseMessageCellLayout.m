//
//  MMBaseMessageCellLayout.m
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
