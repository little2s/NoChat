//
//  TGChatViewController.h
//  NoChat-Example
//
//  Created by little2s on 2017/1/21.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import <NoChat/NoChat.h>

@class NOCChat;

@interface TGChatViewController : NOCChatViewController

@property (nonatomic, strong) NOCChat *chat;

- (instancetype)initWithChat:(NOCChat *)chat;

@end
