//
//  AppDelegate.m
//  NoChat-Example
//
//  Created by little2s on 2016/12/24.
//  Copyright © 2016年 little2s. All rights reserved.
//

#import "NOCAppDelegate.h"
#import "NOCMessageManager.h"

#import <NOCProtoKit/NOCProtoKit.h>

@interface NOCAppDelegate ()

@end

@implementation NOCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[NOCMessageManager manager] play];
    [[NOCEngine shared] play];
    
    return YES;
}

@end
