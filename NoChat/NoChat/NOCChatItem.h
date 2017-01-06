//
//  NOCChatItem.h
//  NoChat-Example
//
//  Created by little2s on 2016/12/24.
//  Copyright © 2016年 little2s. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NOCChatItem <NSObject>

@property (nonatomic, copy, readonly) NSString *uniqueIdentifier;
@property (nonatomic, copy, readonly) NSString *type;

@end
