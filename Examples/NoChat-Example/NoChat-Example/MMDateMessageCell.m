//
//  MMDateMessageCell.m
//  NoChat-Example
//
//  Created by little2s on 2017/1/26.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import "MMDateMessageCell.h"
#import "MMDateMessageCellLayout.h"

@implementation MMDateMessageCell

+ (NSString *)reuseIdentifier
{
    return @"MMDateMessageCell";
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _messageView = [[UIView alloc] init];
        [self.contentView addSubview:_messageView];
        
        _backgroundImageView = [[UIImageView alloc] init];
        [_messageView addSubview:_backgroundImageView];
        
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.numberOfLines = 0;
        [_messageView addSubview:_dateLabel];
    }
    return self;
}

- (void)setLayout:(id<NOCChatItemCellLayout>)layout
{
    [super setLayout:layout];
    
    MMDateMessageCellLayout *cellLayout = (MMDateMessageCellLayout *)layout;
    self.messageView.frame = CGRectMake(0, 0, cellLayout.width, cellLayout.height);
    self.backgroundImageView.frame = cellLayout.backgroundImageViewFrame;
    self.backgroundImageView.image = cellLayout.backgroundImage;
    self.dateLabel.frame = cellLayout.dateLabelFrame;
    self.dateLabel.attributedText = cellLayout.attributedDate;
}

@end
