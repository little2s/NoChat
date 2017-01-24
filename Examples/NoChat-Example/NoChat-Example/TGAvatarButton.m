//
//  TGAvatarButton.m
//  NoChat-Example
//
//  Created by little2s on 2017/1/24.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import "TGAvatarButton.h"

@implementation TGAvatarButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setImage:[UIImage imageNamed:@"TGUserInfo"] forState:UIControlStateNormal];
        [self regularLayout];
    }
    return self;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    if (self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact) {
        [self compactLayout];
    } else {
        [self regularLayout];
    }
}

- (void)regularLayout
{
    self.frame = CGRectMake(0, 0, 37, 37);
}

- (void)compactLayout
{
    self.frame = CGRectMake(0, 0, 28, 28);
}

@end
