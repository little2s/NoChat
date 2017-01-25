//
//  NOCUser.h
//  NoChat-Example
//
//  Created by little2s on 2017/1/25.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NOCUser : NSObject

@property (nonatomic, strong) NSString *userId;

+ (instancetype)currentUser;

@end
