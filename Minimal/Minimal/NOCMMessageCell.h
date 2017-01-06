//
//  NOCMMessageCell.h
//  NoChat-Example
//
//  Created by little2s on 2016/12/25.
//  Copyright © 2016年 little2s. All rights reserved.
//

#import <NoChat/NoChat.h>
#import "NOCMMessageCellLayout.h"

@class NOCMMessageCell;

@interface NOCMMessageHeadView : UIView

@property (nonatomic, strong) UILabel *senderDisplayNameLabel;
@property (nonatomic, strong) UILabel *dateLabel;

@end

@interface NOCMMessageContentView : UIView

- (void)setLayout:(id<NOCMMessageContentViewLayout>)layout;

@end

@interface NOCMMessageView : UIView

@property (nonatomic, strong) NOCMMessageCellLayout *layout;
@property (nonatomic, weak) NOCMMessageCell *cell;

@property (nonatomic, strong) NOCMMessageHeadView *headView;
@property (nonatomic, strong) NOCMMessageContentView *contentView;

- (instancetype)initWithCell:(NOCMMessageCell *)cell;

@end

@interface NOCMMessageCell : NOCChatItemCell

@property (nonatomic, strong) NOCMMessageView *messageView;

+ (Class)messageContentViewClass;

@end

// Text Message
@interface NOCMTextMessageContentView : NOCMMessageContentView

@property (nonatomic, strong) UILabel *textLabel;

@end

@interface NOCMTextMessageCell : NOCMMessageCell

@end
