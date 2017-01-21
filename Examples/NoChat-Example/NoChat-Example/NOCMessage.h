//
//  NOCMessage.h
//  NoChat-Example
//
//  Created by little2s on 2017/1/21.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NoChat/NoChat.h>

@interface NOCMessage : NSObject <NOCChatItem>

@property (nonatomic, copy) NSString *uniqueIdentifier;
@property (nonatomic, copy) NSString *type;

@property (nonatomic, copy) NSString *senderId;
@property (nonatomic, copy) NSString *senderDisplayName;
@property (nonatomic, copy) NSDate *date;
@property (nonatomic, copy) NSString *text;

@end
