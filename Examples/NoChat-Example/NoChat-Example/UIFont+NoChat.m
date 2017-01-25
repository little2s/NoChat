//
//  UIFont+NOCMinimal.m
//  NoChat-Example
//
//  Created by little2s on 2016/12/26.
//  Copyright © 2016年 little2s. All rights reserved.
//

#import "UIFont+NoChat.h"

@implementation UIFont (NoChat)

+ (UIFont *)noc_mediumSystemFontOfSize:(CGFloat)fontSize
{
    UIFont *font;
    if ([NSProcessInfo.processInfo isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){8,2,0}]) {
        font = [UIFont systemFontOfSize:fontSize weight:UIFontWeightMedium];
    } else {
        font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:fontSize];
    }
    return font;
}

@end
