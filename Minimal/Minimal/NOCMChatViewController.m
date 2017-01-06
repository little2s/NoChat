//
//  NOCMChatViewController.m
//  NoChat-Example
//
//  Created by little2s on 2016/12/25.
//  Copyright © 2016年 little2s. All rights reserved.
//

#import "NOCMChatViewController.h"
#import "NOCMMessageCell.h"
#import "NOCMChatInputView.h"
#import "NOCMMessage.h"

@interface NOCMChatViewController () <NOCMChatInputViewDelegate>

@end

@implementation NOCMChatViewController

+ (Class)cellLayoutClassForItemType:(NSString *)type
{
    if ([type isEqualToString:@"Text"]) {
        return [NOCMMessageCellLayout class];
    }
    return nil;
}

+ (Class)chatInputViewClass
{
    return [NOCMChatInputView class];
}

- (void)registerChatItemCells
{
    [self.collectionView registerClass:[NOCMTextMessageCell class] forCellWithReuseIdentifier:[NOCMTextMessageCell reuseIdentifier]];
}

#pragma mark - NOCMChatInputViewDelegate

- (void)chatInputView:(NOCMChatInputView *)chatInputView didSendText:(NSString *)text
{
    NOCMMessage *message = [[NOCMMessage alloc] init];
    message.text = text;
    message.senderDisplayName = @"Outgoing";
    message.dateString = @"Dec 26 17:01";
    [self addChatItems:@[message]];
}

@end
