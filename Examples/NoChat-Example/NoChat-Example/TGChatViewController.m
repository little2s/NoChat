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
#import "NOCSoundManager.h"

@interface TGChatViewController () <UINavigationControllerDelegate, NOCMessageManagerDelegate>

@property (nonatomic, strong) TGTitleView *titleView;
@property (nonatomic, strong) TGAvatarButton *avatarButton;

@property (nonatomic, strong) NOCMessageManager *messageManager;
@property (nonatomic, strong) dispatch_queue_t layoutQueue;

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
        dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_DEFAULT, 0);
        _layoutQueue = dispatch_queue_create("com.little2s.nochat-example.tg.layout", attr);
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
        [self addMessages:messages scrollToBottom:YES animated:YES];
        
        [[NOCSoundManager manager] playSound:@"notification.caf" vibrate:NO];
    }
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (![viewController isKindOfClass:NSClassFromString(@"NOCChatsViewController")]) {
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
    [self.layouts removeAllObjects];
    
    __weak typeof(self) weakSelf = self;
    [self.messageManager fetchMessagesWithChatId:self.chat.chatId handler:^(NSArray *messages) {
        if (weakSelf) {
            [weakSelf addMessages:messages scrollToBottom:YES animated:NO];
        }
    }];
}

- (void)sendMessage:(NOCMessage *)message
{
    message.senderId = [NOCUser currentUser].userId;
    message.outgoing = YES;
    message.date = [NSDate date];
    message.deliveryStatus = NOCMessageDeliveryStatusRead;
    
    [self addMessages:@[message] scrollToBottom:YES animated:YES];
    
    [self.messageManager sendMessage:message toChat:self.chat];
    
    [[NOCSoundManager manager] playSound:@"sent.caf" vibrate:NO];
}

- (void)addMessages:(NSArray *)messages scrollToBottom:(BOOL)scrollToBottom animated:(BOOL)animated
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.layoutQueue, ^{
        __strong typeof(weakSelf) strongSelf = self;
        
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, messages.count)];
        
        NSMutableArray *layouts = [[NSMutableArray alloc] init];
        
        [messages enumerateObjectsUsingBlock:^(NOCMessage *message, NSUInteger idx, BOOL *stop) {
            id<NOCChatItemCellLayout> layout = [strongSelf createLayoutWithItem:message];
            [layouts insertObject:layout atIndex:0];
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf insertLayouts:layouts atIndexes:indexes animated:animated];
            if (scrollToBottom) {
                [strongSelf scrollToBottomAnimated:animated];
            }
        });
    });
}

#pragma mark - Dynamic font support

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
    
    CGSize collectionViewSize = self.containerView.bounds.size;
    
    CGFloat maxOriginY = self.collectionView.contentOffset.y + self.collectionView.contentInset.top;
    CGRect previousCollectionFrame = self.collectionView.frame;
    
    NSInteger anchorItemIndex = -1;
    CGFloat anchorItemOriginY = 0;
    CGFloat anchorItemRelativeOffset = 0;
    CGFloat anchorItemHeight = 0;
    
    NSArray *previousLayoutAttributes = [self.collectionLayout layoutAttributesForLayouts:self.layouts containerWidth:previousCollectionFrame.size.width maxHeight:CGFLOAT_MAX contentHeight:NULL];
    
    NSInteger chatItemsCount = self.layouts.count;
    for (NSInteger i = 0; i < chatItemsCount; i++) {
        UICollectionViewLayoutAttributes *attributes = previousLayoutAttributes[i];
        CGRect itemFrame = attributes.frame;
        
        if (itemFrame.origin.y < maxOriginY) {
            anchorItemHeight = itemFrame.size.height;
            anchorItemIndex = i;
            anchorItemOriginY = itemFrame.origin.y;
        }
    }
    
    if (anchorItemIndex != -1) {
        if (anchorItemHeight > 1.0f) {
            anchorItemRelativeOffset = (anchorItemOriginY - maxOriginY) / anchorItemHeight;
        }
    }
    
    for (id<NOCChatItemCellLayout> layout in self.layouts) {
        [layout calculateLayout];
    }
    
    [self.collectionLayout invalidateLayout];
    
    CGFloat newContentHeight = 0;
    NSArray *newLayoutAttributes = [self.collectionLayout layoutAttributesForLayouts:self.layouts containerWidth:collectionViewSize.width maxHeight:CGFLOAT_MAX contentHeight:&newContentHeight];
    
    CGPoint newContentOffset = CGPointZero;
    newContentOffset.y = -self.collectionView.contentInset.top;
    if (anchorItemIndex >= 0 && anchorItemIndex < newLayoutAttributes.count) {
        UICollectionViewLayoutAttributes *attributes = newLayoutAttributes[anchorItemIndex];
        newContentOffset.y += attributes.frame.origin.y - floor(anchorItemRelativeOffset * attributes.frame.size.height);
    }
    newContentOffset.y = MIN(newContentOffset.y, newContentHeight + self.collectionView.contentInset.bottom - self.collectionView.frame.size.height);
    newContentOffset.y = MAX(newContentOffset.y, -self.collectionView.contentInset.top);
    
    [self.collectionView reloadData];
    
    self.collectionView.contentOffset = newContentOffset;
    
    // fix navigation items display
    [self setupNavigationItems];
}

@end
