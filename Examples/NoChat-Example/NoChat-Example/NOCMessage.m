//
//  NOCMessage.m
//  NoChat-Example
//
//  Created by little2s on 2017/1/21.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import "NOCMessage.h"

@implementation NOCMessage

- (instancetype)init
{
    self = [super init];
    if (self) {
        _uniqueIdentifier = [NSUUID new].UUIDString;
        _type = @"Text";
    }
    return self;
}

@end
