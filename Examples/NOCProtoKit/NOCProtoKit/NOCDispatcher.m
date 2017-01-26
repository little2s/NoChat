//
//  NOCDispatcher.m
//  NOCProtoKit
//
//  Created by little2s on 2017/1/25.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import "NOCDispatcher.h"
#import "NOCClient.h"

@implementation NOCDispatcher {
    NSMapTable *_table;
    dispatch_queue_t _queue;
}

+ (instancetype)shared
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _table = [NSMapTable strongToWeakObjectsMapTable];
        dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT, QOS_CLASS_DEFAULT, 0);
        _queue = dispatch_queue_create("com.little2s.nocprotokit.dispatcher", attr);
    }
    return self;
}

- (void)registerClient:(NOCClient *)client withUserId:(NSString *)userId
{
    if (client && userId) {
        [_table setObject:client forKey:userId];
    }
}

- (void)unregisterClientWithUserId:(NSString *)userId
{
    if (userId) {
        [_table removeObjectForKey:userId];
    }
}

- (void)pushMessage:(NSDictionary *)message
{
    dispatch_async(_queue, ^{
        NSLog(@"msg: %@", message);
        
        NSString *chatType = message[@"ctype"];
        NSString *targetId = message[@"to"];
        if ([chatType isEqualToString:@"bot"] && targetId) {
            NOCClient *client = [_table objectForKey:targetId];
            if (client) {
                id<NOCClientDelegate> delegate = client.delegate;
                if ([delegate respondsToSelector:@selector(clientDidReceiveMessage:)]) {
                    [delegate clientDidReceiveMessage:message];
                }
            }
        }
    });
}

@end
