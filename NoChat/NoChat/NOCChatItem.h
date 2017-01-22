//
//  NOCChatItem.h
//  NoChat-Example
//
//  Created by little2s on 2016/12/24.
//  Copyright © 2016年 little2s. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NOCChatItem <NSObject>

@property (nonatomic, readonly, copy) NSString *uniqueIdentifier;
@property (nonatomic, readonly, copy) NSString *type;

@end

NS_ASSUME_NONNULL_END
