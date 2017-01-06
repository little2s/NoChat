//
//  NOCChatsViewController.m
//  NoChat-Example
//
//  Created by little2s on 2016/12/24.
//  Copyright © 2016年 little2s. All rights reserved.
//

#import "NOCChatsViewController.h"

@interface NOCChatsViewController ()

@end

@implementation NOCChatsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *className = nil;
    NSInteger row = indexPath.row;
    switch (row) {
        case 0:
            className = @"NOCMinimalViewController";
            break;
            
        case 1:
            className = @"NOCTelegramViewController";
            break;
            
        case 2:
            className = @"NOCWeChatViewController";
            break;
            
        default:
            abort();
            break;
    }
    Class clz = NSClassFromString(className);
    UIViewController *nextViewController = [[clz alloc] init];
    nextViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:nextViewController animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
