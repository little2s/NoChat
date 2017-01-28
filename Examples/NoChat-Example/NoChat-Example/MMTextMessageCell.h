//
//  MMTextMessageCell.h
//  NoChat-Example
//
//  Created by little2s on 2017/1/22.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import "MMBaseMessageCell.h"

@class YYLabel;

@interface MMTextMessageCell : MMBaseMessageCell

@property (nonatomic, strong) UIImageView *bubbleImageView;
@property (nonatomic, strong) YYLabel *textLabel;

@end

@protocol MMTextMessageCellDelegate <NOCChatItemCellDelegate>

@optional
- (void)cell:(MMTextMessageCell *)cell didTapLink:(NSDictionary *)linkInfo;

@end
