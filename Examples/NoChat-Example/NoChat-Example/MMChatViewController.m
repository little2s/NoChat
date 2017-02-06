//
//  MMChatViewController.m
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
#import "MMChatViewController.h"

#import "MMTextMessageCell.h"
#import "MMTextMessageCellLayout.h"
#import "MMDateMessageCell.h"
#import "MMDateMessageCellLayout.h"
#import "MMSystemMessageCell.h"
#import "MMSystemMessageCellLayout.h"

#import "MMChatInputTextPanel.h"

#import "NOCUser.h"
#import "NOCChat.h"
#import "NOCMessage.h"

#import "NOCMessageManager.h"

@interface MMChatViewController () <UINavigationControllerDelegate, NOCMessageManagerDelegate>

@property (nonatomic, strong) NOCMessageManager *messageManager;

@end

@implementation MMChatViewController

#pragma mark - Overrides

+ (Class)cellLayoutClassForItemType:(NSString *)type
{
    if ([type isEqualToString:@"Text"]) {
        return [MMTextMessageCellLayout class];
    } else if ([type isEqualToString:@"Date"]) {
        return [MMDateMessageCellLayout class];
    } else if ([type isEqualToString:@"System"]) {
        return [MMSystemMessageCellLayout class];
    } else {
        return nil;
    }
}

+ (Class)inputPanelClass
{
    return [MMChatInputTextPanel class];
}

- (void)registerChatItemCells
{
    [self.collectionView registerClass:[MMTextMessageCell class] forCellWithReuseIdentifier:[MMTextMessageCell reuseIdentifier]];
    [self.collectionView registerClass:[MMDateMessageCell class] forCellWithReuseIdentifier:[MMDateMessageCell reuseIdentifier]];
    [self.collectionView registerClass:[MMSystemMessageCell class] forCellWithReuseIdentifier:[MMSystemMessageCell reuseIdentifier]];
}

- (instancetype)initWithChat:(NOCChat *)chat
{
    self = [super init];
    if (self) {
        self.chat = chat;
        self.messageManager = [NOCMessageManager manager];
        [self.messageManager addDelegate:self];
        self.inverted = NO;
        self.chatInputContainerViewDefaultHeight = 50;
    }
    return self;
}

- (void)dealloc
{
    [self.messageManager removeDelegate:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.backgroundView.image = [UIImage imageNamed:@"MMWallpaper"];
    self.navigationController.delegate = self;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"MMUserInfo"] style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.title = self.chat.title;
    
    [self loadMessages];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithWhite:0.1 alpha:0.9];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.barTintColor = nil;
    self.navigationController.navigationBar.tintColor = nil;
    [super viewWillDisappear:animated];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{    
    if (scrollView == self.collectionView && scrollView.isTracking) {
        [self.inputPanel endInputting:YES];
    }
}

#pragma mark - MMChatInputTextPanelDelegate

- (void)didInputTextPanelStartInputting:(MMChatInputTextPanel *)inputTextPanel
{
    if (![self isScrolledAtBottom]) {
        [self scrollToBottom:YES];
    }
}

- (void)inputTextPanel:(MMChatInputTextPanel *)inputTextPanel requestSendText:(NSString *)text
{
    NOCMessage *message = [[NOCMessage alloc] init];
    message.text = text;
    [self sendMessage:message];
}

#pragma mark - MMTextMessageCellDelegate

- (void)cell:(MMTextMessageCell *)cell didTapLink:(NSDictionary *)linkInfo
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

#pragma mark - NOCMessageManagerDelegate

- (void)didReceiveMessages:(NSArray *)messages chatId:(NSString *)chatId
{
    if (!self.isViewLoaded) {
        return;
    }
    
    if ([chatId isEqualToString:self.chat.chatId]) {
        [self appendChatItems:messages completion:^(BOOL finished) {
            if (self.layouts.count) {
                [self scrollToBottom:YES];
            }
        }];
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
                [strongSelf scrollToBottom:NO];
            }
        }];
    }];
}

- (void)sendMessage:(NOCMessage *)message
{
    message.senderId = [NOCUser currentUser].userId;
    message.date = [NSDate date];
    message.deliveryStatus = NOCMessageDeliveryStatusRead;
    message.outgoing = YES;
    
    dispatch_async(self.serialQueue, ^{
        Class layoutClass = [[self class] cellLayoutClassForItemType:message.type];
        id<NOCChatItemCellLayout> layout = [[layoutClass alloc] initWithChatItem:message cellWidth:self.cellWidth];
        [self.layouts addObject:layout];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.layouts.count-1 inSection:0]]];
            if (self.layouts.count) {
                [self scrollToBottom:YES];
            }
            [self.messageManager sendMessage:message toChat:self.chat];
        });
    });
}

@end
