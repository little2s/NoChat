//
//  NSAttributedString+NoChat.m
//  NoChat-Example
//
//  Created by little2s on 2017/1/26.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import "NSAttributedString+NoChat.h"

@implementation NSAttributedString (NoChat)

- (CGSize)noc_sizeThatFits:(CGSize)size
{
    CGRect rect = [self boundingRectWithSize:size options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
    return CGRectIntegral(rect).size;
}

@end
