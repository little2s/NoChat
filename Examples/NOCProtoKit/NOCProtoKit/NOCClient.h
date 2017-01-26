//
//  NOCClient.h
//  NOCProtoKit
//
//  Created by little2s on 2017/1/25.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NOCClient;

NS_ASSUME_NONNULL_BEGIN

@protocol NOCClientDelegate <NSObject>
@optional
- (void)clientDidOpen:(NOCClient *)client;
- (void)clientDidReceiveMessage:(NSDictionary *)message;
- (void)clientDidFailWithError:(NSError *)error;
- (void)clientDidCloseWithCode:(NSInteger)code reason:(nullable NSString *)reason;
@end

@interface NOCClient : NSObject
@property (nullable, nonatomic, weak) id<NOCClientDelegate> delegate;
- (instancetype)initWithUserId:(NSString *)userId;
- (void)open;
- (void)close;
- (void)sendMessage:(NSDictionary *)message;
@end

NS_ASSUME_NONNULL_END
