//
//  NOCMMessage.m
//  NoChat-Example
//
//  Created by little2s on 2016/12/25.
//  Copyright © 2016年 little2s. All rights reserved.
//

#import "NOCMMessage.h"

@implementation NOCMMessage

- (instancetype)init
{
    self = [super init];
    if (self) {
        _uniqueIdentifier = [[NSUUID alloc] init].UUIDString;
        _type = @"Text";
    }
    return self;
}

@end
