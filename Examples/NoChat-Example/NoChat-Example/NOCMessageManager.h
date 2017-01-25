//
//  NOCMessageManager.h
//  NoChat-Example
//
//  Created by little2s on 2017/1/25.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NOCMessageManager;

@protocol NOCMessageManagerDelegate <NSObject>

@optional
- (void)didReceiveMessages:(NSArray *)messages chatId:(NSString *)chatId;

@end

@class NOCChat;
@class NOCMessage;

@interface NOCMessageManager : NSObject

+ (instancetype)manager;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (void)fetchMessagesWithChatId:(NSString *)chatId handler:(void (^)(NSArray *messages))handler;
- (void)sendMessage:(NOCMessage *)message;

- (void)addDelegate:(id<NOCMessageManagerDelegate>)delegate;
- (void)removeDelegate:(id<NOCMessageManagerDelegate>)delegate;

@end
