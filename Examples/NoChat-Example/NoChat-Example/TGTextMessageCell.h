//
//  TGTextMessageCell.h
//  NoChat-Example
//
//  Created by little2s on 2017/1/21.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import "TGBaseMessageCell.h"

@class YYLabel;

@interface TGTextMessageCell : TGBaseMessageCell

@property (nonatomic, strong) YYLabel *textLabel;

@end

@protocol TGTextMessageCellDelegate <NOCChatItemCellDelegate>

@optional
- (void)cell:(TGTextMessageCell *)cell didTapLink:(NSURL *)linkURL;
- (void)cell:(TGTextMessageCell *)cell didLongPressLink:(NSURL *)linkURL;

@end
