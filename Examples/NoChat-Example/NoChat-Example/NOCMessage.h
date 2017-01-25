//
//  NOCMessage.h
//  NoChat-Example
//
//  Created by little2s on 2017/1/21.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NoChat/NoChat.h>

typedef NS_ENUM(NSUInteger, NOCMessageDeliveryStatus) {
    NOCMessageDeliveryStatusIdle = 0,
    NOCMessageDeliveryStatusDelivering = 1,
    NOCMessageDeliveryStatusDelivered = 2,
    NOCMessageDeliveryStatusFailure = 3,
    NOCMessageDeliveryStatusRead = 4
};

@interface NOCMessage : NSObject <NOCChatItem>

@property (nonatomic, strong) NSString *msgId;
@property (nonatomic, strong) NSString *type;

@property (nonatomic, strong) NSString *senderId;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *text;

@property (nonatomic, assign, getter=isOutgoing) BOOL outgoing;
@property (nonatomic, assign) NOCMessageDeliveryStatus deliveryStatus;

@end
