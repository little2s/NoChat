//
//  TGSystemMessageCell.h
//  NoChat-Example
//
//  Created by little2s on 2017/1/26.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import <NoChat/NoChat.h>

@interface TGSystemMessageCell : NOCChatItemCell

@property (nonatomic, strong) UIView *messageView;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UILabel *textLabel;

@end
