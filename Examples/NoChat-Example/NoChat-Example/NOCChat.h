//
//  NOCChat.h
//  NoChat-Example
//
//  Created by little2s on 2017/1/25.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NOCChat : NSObject

@property (nonatomic, strong) NSString *chatId;
@property (nonatomic, strong) NSString *type;

@property (nonatomic, strong) NSString *targetId;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *detail;

@end
