//
//  TGChatViewController.m
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

#import "TGChatViewController.h"

#import "TGTextMessageCell.h"
#import "TGTextMessageCellLayout.h"
#import "TGDateMessageCell.h"
#import "TGDateMessageCellLayout.h"
#import "TGSystemMessageCell.h"
#import "TGSystemMessageCellLayout.h"

#import "TGChatInputTextPanel.h"

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

+ (Class)inputPanelClass
{
    return [TGChatInputTextPanel class];
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
        [self.messageManager addDelegate:self];
        [self registerContentSizeCategoryDidChangeNotification];
        [self setupNavigationItems];
    }
    return self;
}

- (void)dealloc
{
    [self unregisterContentSizeCategoryDidChangeNotification];
    [self.messageManager removeDelegate:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.backgroundView.image = [UIImage imageNamed:@"TGWallpaper"];
    self.navigationController.delegate = self;
    [self loadMessages];
}

#pragma mark - TGChatInputTextPanelDelegate

- (void)inputTextPanel:(TGChatInputTextPanel *)inputTextPanel requestSendText:(NSString *)text
{
    NOCMessage *message = [[NOCMessage alloc] init];
    message.text = text;
    [self sendMessage:message];
}

#pragma mark - TGTextMessageCellDelegate

- (void)cell:(TGTextMessageCell *)cell didTapLink:(NSDictionary *)linkInfo
{
    [self.inputPanel endInputting:YES];
    
    NSString *command = linkInfo[@"command"];
    if (!command) {
        return;
    }
    
    NOCMessage *message = [[NOCMessage alloc] init];
    message.text = command;
    [self sendMessage:message];
}

#pragma mark - NOCMessageManagerDelegate

- (void)didReceiveMessages:(NSArray *)messages chatId:(NSString *)chatId
{
    if (!self.isViewLoaded) {
        return;
    }
    
    if ([chatId isEqualToString:self.chat.chatId]) {
        [self appendChatItems:messages completion:nil];
    }
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self == navigationController.topViewController) {
        return;
    }
    
    self.isInControllerTransition = YES;
    
    __weak typeof(self) weakSelf = self;
    id<UIViewControllerTransitionCoordinator> transitionCoordinator = navigationController.topViewController.transitionCoordinator;
    [transitionCoordinator notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        if ([context isCancelled] && weakSelf) {
            weakSelf.isInControllerTransition = NO;
        }
    }];
}

#pragma mark - Private

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

- (void)registerContentSizeCategoryDidChangeNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleContentSizeCategoryDidChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)unregisterContentSizeCategoryDidChangeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)handleContentSizeCategoryDidChanged:(NSNotification *)notification
{
    if (!self.isViewLoaded) {
        return;
    }
    
    if (self.layouts.count == 0) {
        return;
    }
    
    [self.collectionView.collectionViewLayout invalidateLayout];
    [self reloadChatItemsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.layouts.count)] completion:nil];
    
    // fix navigation items display
    [self setupNavigationItems];
}

@end
