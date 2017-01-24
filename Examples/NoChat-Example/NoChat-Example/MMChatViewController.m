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

#import "NOCMessage.h"
#import "NOCMessageFactory.h"

@interface MMChatViewController () <UINavigationControllerDelegate>

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

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.inverted = NO;
        self.chatInputContainerViewDefaultHeight = 50;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.backgroundView.image = [UIImage imageNamed:@"MMWallpaper"];
    self.navigationController.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleContentSizeCategoryDidChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    [self loadChatItems];
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
    [self scrollToBottom:YES];
}

- (void)chatInputView:(MMChatInputView *)chatInputView didSendText:(NSString *)text
{
    NOCMessage *message = [[NOCMessage alloc] init];
    message.text = text;
    message.date = [NSDate date];
    message.deliveryStatus = NOCMessageDeliveryStatusRead;
    message.outgoing = YES;
    [self appendMessage:message];
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
    dispatch_async(self.serialQueue, ^{
        Class layoutClass = [[self class] cellLayoutClassForItemType:message.type];
        id<NOCChatItemCellLayout> layout = [[layoutClass alloc] initWithChatItem:message cellWidth:self.cellWidth];
        [self.layouts addObject:layout];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.layouts.count-1 inSection:0]]];
            [self scrollToBottom:YES];
        });
    });
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
