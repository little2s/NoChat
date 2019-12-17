//
//  NOCDispatcher.m
//  NOCProtoKit
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

#import "NOCDispatcher.h"
#import "NOCClient.h"

@implementation NOCDispatcher
{
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
            NOCClient *client = [self->_table objectForKey:targetId];
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
