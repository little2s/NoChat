//
//  MMBaseMessageCell.h
//  NoChat-Example
//
//  Created by little2s on 2017/1/22.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import <NoChat/NoChat.h>

@interface MMBaseMessageCell : NOCChatItemCell

@property (nonatomic, strong) UIView *messageView;
@property (nonatomic, strong) UIView *bubbleView;
@property (nonatomic, strong) UIImageView *avatarImageView;

@property (nonatomic, assign, getter=isHighlight) BOOL hightlight;

@end
