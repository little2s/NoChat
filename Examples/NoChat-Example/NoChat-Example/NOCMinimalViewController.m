//
//  NOCMinimalViewController.m
//  NoChat-Example
//
//  Created by little2s on 2016/12/24.
//  Copyright © 2016年 little2s. All rights reserved.
//

#import "NOCMinimalViewController.h"
#import "NOCChatItemsFactory.h"

@interface NOCMinimalViewController ()

@end

@implementation NOCMinimalViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.autoLoadAboveChatItemsEnable = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Minimal";
    [self loadChatItems];
}

- (void)loadChatItems
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *chatItems = [NOCChatItemsFactory fetchMinimalChatItemsWithNumber:20];
        [self reloadChatItems:chatItems];
    });
}

- (void)loadAboveChatItems
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *chatItems = [NOCChatItemsFactory fetchMinimalChatItemsWithNumber:20];
        [self insertChatItems:chatItems atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 20)]];
    });
}

@end
