//
//  MMSystemMessageCell.m
//  NoChat-Example
//
//  Created by little2s on 2017/1/26.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import "MMSystemMessageCell.h"
#import "MMSystemMessageCellLayout.h"

@implementation MMSystemMessageCell

+ (NSString *)reuseIdentifier
{
    return @"MMSystemMessageCell";
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _messageView = [[UIView alloc] init];
        [self.contentView addSubview:_messageView];
        
        _backgroundImageView = [[UIImageView alloc] init];
        [_messageView addSubview:_backgroundImageView];
        
        _textLabel = [[UILabel alloc] init];
        _textLabel.numberOfLines = 0;
        [_messageView addSubview:_textLabel];
    }
    return self;
}

- (void)setLayout:(id<NOCChatItemCellLayout>)layout
{
    [super setLayout:layout];
    
    MMSystemMessageCellLayout *cellLayout = (MMSystemMessageCellLayout *)layout;
    self.messageView.frame = CGRectMake(0, 0, cellLayout.width, cellLayout.height);
    self.backgroundImageView.frame = cellLayout.backgroundImageViewFrame;
    self.backgroundImageView.image = cellLayout.backgroundImage;
    self.textLabel.frame = cellLayout.textLabelFrame;
    self.textLabel.attributedText = cellLayout.attributedText;
}

@end
