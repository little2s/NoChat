//
//  NOCSoundManager.h
//  NoChat-Example
//
//  Created by little2s on 2017/2/7.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NOCSoundManager : NSObject

+ (instancetype)manager;

- (void)playSound:(NSString *)name vibrate:(BOOL)vibrate;

@end
