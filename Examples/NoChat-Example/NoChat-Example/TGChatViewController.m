//
//  TGChatViewController.m
//  NoChat-Example
//
//  Created by little2s on 2017/1/21.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import "TGChatViewController.h"

#import "TGTextMessageCell.h"
#import "TGTextMessageCellLayout.h"
#import "TGChatInputView.h"

#import "NOCMessage.h"
#import "NOCMessageFactory.h"

@interface TGChatViewController () <UINavigationControllerDelegate>

@end

@implementation TGChatViewController

#pragma mark - Overrides

+ (Class)cellLayoutClassForItemType:(NSString *)type
{
    if ([type isEqualToString:@"Text"]) {
        return [TGTextMessageCellLayout class];
    } else {
        return nil;
    }
}

+ (Class)chatInputViewClass
{
    return [TGChatInputView class];
}

- (void)registerChatItemCells
{
    [self.collectionView registerClass:[TGTextMessageCell class] forCellWithReuseIdentifier:[TGTextMessageCell reuseIdentifier]];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.backgroundView.image = [UIImage imageNamed:@"TGWallpaper"];
    self.navigationController.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleContentSizeCategoryDidChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    [self loadChatItems];
}

#pragma mark - TGChatInputViewDelegate

- (void)chatInputView:(TGChatInputView *)chatInputView didSendText:(NSString *)text
{
    NOCMessage *message = [[NOCMessage alloc] init];
    message.text = text;
    message.outgoing = YES;
    message.date = [NSDate date];
    message.deliveryStatus = NOCMessageDeliveryStatusRead;
    [self appendMessage:message];
}

- (void)chatInputView:(TGChatInputView *)chatInputView didTapAttachButton:(UIButton *)attachButton
{
    NSLog(@"did tap attach button");
}

#pragma mark - TGTextMessageCellDelegate

- (void)cell:(TGTextMessageCell *)cell didTapLink:(NSURL *)linkURL
{
    [self.chatInputView endInputting:YES];
    NSLog(@"did tap link: %@", linkURL);
}

- (void)cell:(TGTextMessageCell *)cell didLongPressLink:(NSURL *)linkURL
{
    NSLog(@"did long press link: %@", linkURL);
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self == navigationController.topViewController) {
        return;
    }
    
    self.chatInputView.delegate = nil;
    
    __weak typeof(self) weakSelf = self;
    id<UIViewControllerTransitionCoordinator> transitionCoordinator = navigationController.topViewController.transitionCoordinator;
    [transitionCoordinator notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        if ([context isCancelled] && weakSelf) {
            weakSelf.chatInputView.delegate = weakSelf;
        }
    }];
}

#pragma mark - Private

- (void)loadChatItems
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *chatItems = [NOCMessageFactory fetchMessagesWithNumber:20];
        [self reloadChatItems:chatItems];
    });
}

- (void)appendMessage:(NOCMessage *)message
{
    [self appendChatItems:@[message]];
    [self scrollToBottom:YES];
}

- (void)handleContentSizeCategoryDidChanged:(NSNotification *)notification
{
    if (self.layouts.count == 0) {
        return;
    }
    [self.collectionView.collectionViewLayout invalidateLayout];
    [self updateChatItemsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.layouts.count)]];
}

@end
