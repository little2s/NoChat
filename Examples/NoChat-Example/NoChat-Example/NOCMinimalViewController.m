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
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *chatItems = [NOCChatItemsFactory fetchMinimalChatItemsWithNumber:20];
        [self reloadChatItems:chatItems];
    });
}

@end
