//
//  NOCClient.m
//  NOCProtoKit
//
//  Created by little2s on 2017/1/25.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import "NOCClient.h"
#import "NOCDispatcher.h"

@implementation NOCClient {
    NSString *_userId;
}

- (instancetype)initWithUserId:(NSString *)userId
{
    self = [super init];
    if (self) {
        _userId = userId;
    }
    return self;
}

- (void)open
{
    [[NOCDispatcher shared] registerClient:self withUserId:_userId];
    
    if ([self.delegate respondsToSelector:@selector(clientDidOpen:)]) {
        [self.delegate clientDidOpen:self];
    }
}

- (void)close;
{
    [[NOCDispatcher shared] unregisterClientWithUserId:_userId];
    
    if ([self.delegate respondsToSelector:@selector(clientDidCloseWithCode:reason:)]) {
        [self.delegate clientDidCloseWithCode:0 reason:nil];
    }
}

- (void)sendMessage:(NSDictionary *)message
{
    [[NOCDispatcher shared] pushMessage:message];
}

@end
