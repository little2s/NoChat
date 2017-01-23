//
//  TGDeliveryStatusView.h
//  NoChat-Example
//
//  Created by little2s on 2017/1/23.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TGClockProgressView.h"
#import "NOCMessage.h"

@interface TGDeliveryStatusView : UIView

@property (nonatomic, strong) TGClockProgressView *clockView;
@property (nonatomic, strong) UIImageView *checkmark1ImageView;
@property (nonatomic, strong) UIImageView *checkmark2ImageView;

@property (nonatomic, assign) NOCMessageDeliveryStatus deliveryStatus;

@end
