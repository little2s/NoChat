//
//  NOCChatsViewController.m
//  NoChat-Example
//
//  Created by little2s on 2016/12/24.
//  Copyright © 2016年 little2s. All rights reserved.
//

#import "NOCChatsViewController.h"
#import "NOCChat.h"

#import "TGChatViewController.h"
#import "MMChatViewController.h"

@interface NOCChatsViewController ()

@end

@implementation NOCChatsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NOCChatCell" forIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Telegram";
        cell.imageView.image = [UIImage imageNamed:@"TGIcon"];
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"WeChat";
        cell.imageView.image = [UIImage imageNamed:@"MMIcon"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NOCChat *chat = [self botChat];
    UIViewController *chatVC = nil;
    if (indexPath.row == 0) {
        chatVC = [[TGChatViewController alloc] initWithChat:chat];
    } else if (indexPath.row == 1) {
        chatVC = [[MMChatViewController alloc] initWithChat:chat];
    }
    if (chatVC) {
        [self.navigationController pushViewController:chatVC animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NOCChat *)botChat
{
    static NOCChat *_botChat = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _botChat = [[NOCChat alloc] init];
        _botChat.type = @"bot";
        _botChat.targetId = @"89757";
        _botChat.chatId = [NSString stringWithFormat:@"%@_%@", _botChat.type, _botChat.targetId];
        _botChat.title = @"Gothons From Planet Percal #25";
        _botChat.detail = @"bot";
    });
    return _botChat;
}

@end
