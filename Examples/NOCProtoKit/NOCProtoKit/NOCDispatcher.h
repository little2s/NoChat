//
//  NOCDispatcher.h
//  NOCProtoKit
//
//  Created by little2s on 2017/1/25.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NOCClient;

@interface NOCDispatcher : NSObject

+ (instancetype)shared;

- (void)registerClient:(NOCClient *)client withUserId:(NSString *)userId;
- (void)unregisterClientWithUserId:(NSString *)userId;

- (void)pushMessage:(NSDictionary *)message;

@end
