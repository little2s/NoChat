//
//  TGTextMessageCell.h
//  NoChat-Example
//
//  Created by little2s on 2017/1/21.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import "TGBaseMessageCell.h"
#import "TGDeliveryStatusView.h"

@class YYLabel;

@interface TGTextMessageCell : TGBaseMessageCell

@property (nonatomic, strong) UIImageView *bubbleImageView;
@property (nonatomic, strong) YYLabel *textLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) TGDeliveryStatusView *deliveryStatusView;

@end

@protocol TGTextMessageCellDelegate <NOCChatItemCellDelegate>

@optional
- (void)cell:(TGTextMessageCell *)cell didTapLink:(NSDictionary *)linkInfo;

@end

