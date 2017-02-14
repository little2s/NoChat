//
//  NOCChatsViewController.m
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
