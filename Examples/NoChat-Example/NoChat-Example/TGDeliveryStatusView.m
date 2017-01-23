//
//  TGDeliveryStatusView.m
//  NoChat-Example
//
//  Created by little2s on 2017/1/23.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import "TGDeliveryStatusView.h"

@implementation TGDeliveryStatusView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _clockView = [[TGClockProgressView alloc] init];
        [self addSubview:_clockView];
        
        _checkmark1ImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TGMessageCheckmark1"]];
        [self addSubview:_checkmark1ImageView];
        
        _checkmark2ImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TGMessageCheckmark2"]];
        [self addSubview:_checkmark2ImageView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.clockView.frame = self.bounds;
    self.checkmark1ImageView.frame = CGRectMake(0, 2, 12, 11);
    self.checkmark2ImageView.frame = CGRectMake(3, 2, 12, 11);
}

- (void)setDeliveryStatus:(NOCMessageDeliveryStatus)deliveryStatus
{
    if (deliveryStatus == NOCMessageDeliveryStatusDelivering) {
        self.clockView.hidden = NO;
        [self.clockView startAnimating];
        self.checkmark1ImageView.hidden = YES;
        self.checkmark2ImageView.hidden = YES;
    } else if (deliveryStatus == NOCMessageDeliveryStatusDelivered) {
        [self.clockView stopAnimating];
        self.clockView.hidden = YES;
        self.checkmark1ImageView.hidden = NO;
        self.checkmark2ImageView.hidden = YES;
    } else if (deliveryStatus == NOCMessageDeliveryStatusRead) {
        [self.clockView stopAnimating];
        self.clockView.hidden = YES;
        self.checkmark1ImageView.hidden = NO;
        self.checkmark2ImageView.hidden = NO;
    } else {
        [self.clockView stopAnimating];
        self.clockView.hidden = YES;
        self.checkmark1ImageView.hidden = YES;
        self.checkmark2ImageView.hidden = YES;
    }
}

@end
