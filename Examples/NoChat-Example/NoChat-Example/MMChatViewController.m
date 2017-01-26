//
//  MMChatViewController.m
//  NoChat-Example
//
//  Created by little2s on 2017/1/21.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import "MMChatViewController.h"

#import "MMTextMessageCell.h"
#import "MMTextMessageCellLayout.h"
#import "MMChatInputView.h"

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
    } else {
        return nil;
    }
}

+ (Class)chatInputViewClass
{
    return [MMChatInputView class];
}

- (void)registerChatItemCells
{
    [self.collectionView registerClass:[MMTextMessageCell class] forCellWithReuseIdentifier:[MMTextMessageCell reuseIdentifier]];
}

- (instancetype)initWithChat:(NOCChat *)chat
{
    self = [super init];
    if (self) {
        self.chat = chat;
        self.messageManager = [NOCMessageManager manager];
        self.inverted = NO;
        self.chatInputContainerViewDefaultHeight = 50;
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
    self.backgroundView.image = [UIImage imageNamed:@"MMWallpaper"];
    self.navigationController.delegate = self;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"MMUserInfo"] style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.title = self.chat.title;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleContentSizeCategoryDidChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    [self.messageManager addDelegate:self];
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
    [super scrollViewDidScroll:scrollView];
    
    if (scrollView == self.collectionView && scrollView.isTracking) {
        [self.chatInputView endInputting:YES];
    }
}

#pragma mark - MMChatInputViewDelegate

- (void)didChatInputViewStartInputting:(MMChatInputView *)chatInputView
{
    if (self.layouts.count) {
        [self scrollToBottom:YES];
    }
}

- (void)chatInputView:(MMChatInputView *)chatInputView didSendText:(NSString *)text
{
    NOCMessage *message = [[NOCMessage alloc] init];
    message.text = text;
    [self sendMessage:message];
}

#pragma mark - MMTextMessageCellDelegate

- (void)cell:(MMTextMessageCell *)cell didTapLink:(NSURL *)linkURL
{
    [self.chatInputView endInputting:YES];
    NSLog(@"did tap link: %@", linkURL);
}

- (void)cell:(MMTextMessageCell *)cell didLongPressLink:(NSURL *)linkURL
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

#pragma mark - NOCMessageManagerDelegate

- (void)didReceiveMessages:(NSArray *)messages chatId:(NSString *)chatId
{
    if ([chatId isEqualToString:self.chat.chatId]) {
        [self appendChatItems:messages];
        if (self.layouts.count) {
            [self scrollToBottom:YES];
        }
    }
}

#pragma mark - Private

- (void)loadMessages
{
    __weak typeof(self) weakSelf = self;
    [self.messageManager fetchMessagesWithChatId:self.chat.chatId handler:^(NSArray *messages) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf reloadChatItems:messages];
        if (!strongSelf.collectionView.isTracking && strongSelf.layouts.count) {
            [strongSelf scrollToBottom:YES];
        }
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
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.layouts.count-1 inSection:0]]];
            if (self.layouts.count) {
                [self scrollToBottom:YES];
            }
        });
    });
    
    [self.messageManager sendMessage:message toChat:self.chat];
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
