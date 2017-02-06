//
//  NOCChatView.m
//  NoChat
//
//  Created by little2s on 2017/2/1.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import "NOCChatContainerView.h"

@implementation NOCChatContainerView {
    CGSize _validSize;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil) {
        _validSize = frame.size;
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    if (!CGSizeEqualToSize(_validSize, frame.size)) {
        _validSize = frame.size;
        if (_layoutForSize) {
            _layoutForSize(frame.size);
        }
    }
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    
    if (!CGSizeEqualToSize(_validSize, bounds.size)) {
        _validSize = bounds.size;
        if (_layoutForSize) {
            _layoutForSize(bounds.size);
        }
    }
}

@end
