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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Minimal";
    
    __weak typeof(self) weakSelf = self;
    
    self.loadPreviousChatItems = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *chatItems = [NOCChatItemsFactory fetchMinimalChatItemsWithNumber:20];
            [strongSelf insertChatItems:chatItems atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 20)]];
        });
    };
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *chatItems = [NOCChatItemsFactory fetchMinimalChatItemsWithNumber:20];
        [self reloadWithChatItems:chatItems];
    });
}

@end
