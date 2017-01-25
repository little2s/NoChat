//
//  NOCUser.m
//  NoChat-Example
//
//  Created by little2s on 2017/1/25.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import "NOCUser.h"

@implementation NOCUser

+ (instancetype)currentUser
{
    static NOCUser *_currentUser = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _currentUser = [[NOCUser alloc] init];
        _currentUser.userId = @"23333";
    });
    return _currentUser;
}

@end
