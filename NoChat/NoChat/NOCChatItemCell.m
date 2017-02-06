//
//  NOCChatItemCell.m
//  NoChat-Example
//
//  Created by little2s on 2016/12/24.
//  Copyright © 2016年 little2s. All rights reserved.
//

#import "NOCChatItemCell.h"

@implementation NOCChatItemCell

+ (NSString *)reuseIdentifier
{
    return @"NOCChatItemCell";
}

- (UIView *)snapshotViewAfterScreenUpdates:(BOOL)afterUpdates
{
    UIGraphicsBeginImageContext(self.bounds.size);
    
    [self drawRect:self.bounds];
    
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    UIImageView *view = [[UIImageView alloc] initWithFrame:self.bounds];
    view.image = snapshotImage;
    
    return view;
}

@end
