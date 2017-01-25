//
//  NOCMessageManager.m
//  NoChat-Example
//
//  Created by little2s on 2017/1/25.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import "NOCMessageManager.h"

#import "NOCUser.h"
#import "NOCChat.h"
#import "NOCMessage.h"

@interface NOCMessageManager ()

@property (nonatomic, strong) NSHashTable *delegates;

@end

@implementation NOCMessageManager

+ (instancetype)manager
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)_init
{
    self = [super init];
    if (self) {
        _delegates = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

- (void)fetchMessagesWithChatId:(NSString *)chatId handler:(void (^)(NSArray *messages))handler
{
    
}

- (void)sendMessage:(NOCMessage *)message
{

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

@end
