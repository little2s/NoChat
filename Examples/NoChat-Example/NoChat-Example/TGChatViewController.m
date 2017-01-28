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
#import "TGDateMessageCell.h"
#import "TGDateMessageCellLayout.h"
#import "TGSystemMessageCell.h"
#import "TGSystemMessageCellLayout.h"
#import "TGChatInputView.h"

#import "TGTitleView.h"
#import "TGAvatarButton.h"

#import "NOCUser.h"
#import "NOCChat.h"
#import "NOCMessage.h"

#import "NOCMessageManager.h"

@interface TGChatViewController () <UINavigationControllerDelegate, NOCMessageManagerDelegate>

@property (nonatomic, strong) TGTitleView *titleView;
@property (nonatomic, strong) TGAvatarButton *avatarButton;

@property (nonatomic, strong) NOCMessageManager *messageManager;

@end

@implementation TGChatViewController

#pragma mark - Overrides

+ (Class)cellLayoutClassForItemType:(NSString *)type
{
    if ([type isEqualToString:@"Text"]) {
        return [TGTextMessageCellLayout class];
    } else if ([type isEqualToString:@"Date"]) {
        return [TGDateMessageCellLayout class];
    } else if ([type isEqualToString:@"System"]) {
        return [TGSystemMessageCellLayout class];
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
    [self.collectionView registerClass:[TGDateMessageCell class] forCellWithReuseIdentifier:[TGDateMessageCell reuseIdentifier]];
    [self.collectionView registerClass:[TGSystemMessageCell class] forCellWithReuseIdentifier:[TGSystemMessageCell reuseIdentifier]];
}

- (instancetype)initWithChat:(NOCChat *)chat
{
    self = [super init];
    if (self) {
        self.chat = chat;
        self.messageManager = [NOCMessageManager manager];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.messageManager removeDelegate:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.backgroundView.image = [UIImage imageNamed:@"TGWallpaper"];
    self.navigationController.delegate = self;
    [self setupNavigationItems];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleContentSizeCategoryDidChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    [self.messageManager addDelegate:self];
    [self loadMessages];
}

#pragma mark - TGChatInputViewDelegate

- (void)chatInputView:(TGChatInputView *)chatInputView didSendText:(NSString *)text
{
    NOCMessage *message = [[NOCMessage alloc] init];
    message.text = text;
    [self sendMessage:message];
}

#pragma mark - TGTextMessageCellDelegate

- (void)cell:(TGTextMessageCell *)cell didTapLink:(NSDictionary *)linkInfo
{
    [self.chatInputView endInputting:YES];
    
    NSLog(@"did tap link: %@", linkInfo);
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

#pragma mark - NOCMessageManagerDelegate

- (void)didReceiveMessages:(NSArray *)messages chatId:(NSString *)chatId
{
    if ([chatId isEqualToString:self.chat.chatId]) {
        [self appendChatItems:messages completion:nil];
    }
}

#pragma mark - Private

- (void)loadMessages
{
    __weak typeof(self) weakSelf = self;
    [self.messageManager fetchMessagesWithChatId:self.chat.chatId handler:^(NSArray *messages) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf loadChatItems:messages completion:^(BOOL finished) {
            if (!strongSelf.collectionView.isTracking && strongSelf.layouts.count) {
                [strongSelf scrollToBottom:YES];
            }
        }];
    }];
}

- (void)sendMessage:(NOCMessage *)message
{
    message.senderId = [NOCUser currentUser].userId;
    message.outgoing = YES;
    message.date = [NSDate date];
    message.deliveryStatus = NOCMessageDeliveryStatusRead;
    
    __weak typeof(self) weakSelf = self;
    [self appendChatItems:@[message] completion:^(BOOL finished) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.layouts.count) {
            [strongSelf scrollToBottom:YES];
        }
        [strongSelf.messageManager sendMessage:message toChat:strongSelf.chat];
    }];
}

- (void)setupNavigationItems
{
    self.titleView = [[TGTitleView alloc] init];
    self.titleView.title = self.chat.title;
    self.titleView.detail = self.chat.detail;
    self.navigationItem.titleView = self.titleView;
    
    UIBarButtonItem *spacerItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spacerItem.width = -12;
    
    self.avatarButton = [[TGAvatarButton alloc] init];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:self.avatarButton];
    self.navigationItem.rightBarButtonItems = @[spacerItem, rightItem];
}

- (void)handleContentSizeCategoryDidChanged:(NSNotification *)notification
{
    if (self.layouts.count == 0) {
        return;
    }
    [self.collectionView.collectionViewLayout invalidateLayout];
    [self reloadChatItemsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.layouts.count)] completion:nil];
}

@end
