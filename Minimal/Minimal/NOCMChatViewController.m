//
//  NOCMChatViewController.m
//  NoChat-Example
//
//  Created by little2s on 2016/12/25.
//  Copyright © 2016年 little2s. All rights reserved.
//

#import "NOCMChatViewController.h"
#import "NOCMMessage.h"

@interface NOCMChatViewController ()

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleContentSizeCategoryDidChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleContentSizeCategoryDidChanged:(NSNotification *)notification
{
    if (self.layouts.count == 0) {
        return;
    }
    [self.collectionView.collectionViewLayout invalidateLayout];
    [self updateChatItemsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.layouts.count)]];
}

#pragma mark - NOCMChatInputViewDelegate

- (void)chatInputView:(NOCMChatInputView *)chatInputView didSendText:(NSString *)text
{
    NOCMMessage *message = [[NOCMMessage alloc] init];
    message.text = text;
    message.senderDisplayName = @"Outgoing";
    message.dateString = @"Dec 26 17:01";
    
    [self appendMessage:message];
}

- (void)appendMessage:(NOCMMessage *)message
{
    [self appendChatItems:@[message]];
    [self scrollToBottom:YES];
}

#pragma mark - NOCMTextMessageCellDelegate

- (void)cell:(NOCMTextMessageCell *)cell didTapLink:(NSURL *)linkURL
{
    [self.chatInputView endInputting:YES];
}

@end
