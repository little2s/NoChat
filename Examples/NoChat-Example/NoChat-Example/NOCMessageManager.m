//
//  NOCMessageManager.m
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

#import "NOCMessageManager.h"

#import "NOCUser.h"
#import "NOCChat.h"
#import "NOCMessage.h"

#import <NOCProtoKit/NOCProtoKit.h>

@interface NOCMessageManager () <NOCClientDelegate>

@property (nonatomic, strong) NSHashTable *delegates;
@property (nonatomic, strong) NOCClient *client;

@property (nonatomic, strong) NSMutableDictionary *messages;

@end

@implementation NOCMessageManager

+ (instancetype)manager
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] _init];
    });
    return instance;
}

- (instancetype)_init
{
    self = [super init];
    if (self) {
        _delegates = [NSHashTable weakObjectsHashTable];
        _client = [[NOCClient alloc] initWithUserId:[NOCUser currentUser].userId];
        _client.delegate = self;
        _messages = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)play
{
    [self.client open];
}

- (void)fetchMessagesWithChatId:(NSString *)chatId handler:(void (^)(NSArray *messages))handler
{
    NSArray *msgs = self.messages[chatId];
    if (msgs.count) {
        handler(msgs);
    } else {
        NSMutableArray *arr = [NSMutableArray new];
        
        NOCMessage *msg = [[NOCMessage alloc] init];
        msg.date = [NSDate date];
        msg.type = @"Date";
        [arr addObject:msg];
        
        if ([chatId isEqualToString:@"bot_89757"]) {
            NOCMessage *msg1 = [[NOCMessage alloc] init];
            msg1.date = [NSDate date];
            msg1.text = @"Welcome to Gothons From Planet Percal #25! Please input `/start` to play!";
            msg1.type = @"System";
            [arr addObject:msg1];
            
        }

        [self saveMessages:arr chatId:chatId];
        
        handler(arr);
    }
}

- (void)sendMessage:(NOCMessage *)message toChat:(NOCChat *)chat
{
    NSString *chatId = chat.chatId;
    [self saveMessages:@[message] chatId:chatId];
    
    NSDictionary *dict = @{
        @"from": message.senderId,
        @"to": chat.targetId,
        @"type": message.type,
        @"text": message.text,
        @"ctype": chat.type
    };
    
    [self.client sendMessage:dict];
}

- (void)addDelegate:(id<NOCMessageManagerDelegate>)delegate
{
    if (delegate) {
        [self.delegates addObject:delegate];
    }
}

- (void)removeDelegate:(id<NOCMessageManagerDelegate>)delegate
{
    if (delegate) {
        [self.delegates removeObject:delegate];
    }
}

- (void)clientDidReceiveMessage:(NSDictionary *)message
{
    NSString *senderId = message[@"from"];
    NSString *type = message[@"type"];
    NSString *text = message[@"text"];
    NSString *chatType = message[@"ctype"];
    
    if (![type isEqualToString:@"Text"] || ![chatType isEqualToString:@"bot"]) {
        return;
    }
    
    NOCMessage *msg = [[NOCMessage alloc] init];
    msg.senderId = senderId;
    msg.type = type;
    msg.text = text;
    msg.outgoing = NO;
    msg.date = [NSDate date];
    
    NSString *chatId = [NSString stringWithFormat:@"%@_%@", chatType, senderId];
    
    [self saveMessages:@[msg] chatId:chatId];
    
    for (id<NOCMessageManagerDelegate> delegate in self.delegates.allObjects) {
        if ([delegate respondsToSelector:@selector(didReceiveMessages:chatId:)]) {
            [delegate didReceiveMessages:@[msg] chatId:chatId];
        }
    }
}

- (void)saveMessages:(NSArray *)messages chatId:(NSString *)chatId
{
    NSMutableArray *msgs = self.messages[chatId];
    if (!msgs) {
        msgs = [[NSMutableArray alloc] init];
        self.messages[chatId] = msgs;
    }
    [msgs addObjectsFromArray:messages];
}

@end
