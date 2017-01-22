//
//  MMBaseMessageCellLayout.h
//  NoChat-Example
//
//  Created by little2s on 2017/1/22.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import <NoChat/NoChat.h>

@interface MMBaseMessageCellLayout : NSObject <NOCChatItemCellLayout>

@property (nonatomic, strong) NSString *reuseIdentifier;
@property (nonatomic, strong) id<NOCChatItem> chatItem;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

@property (nonatomic, assign) UIEdgeInsets bubbleViewMargin;
@property (nonatomic, assign) CGRect bubbleViewFrame;

- (instancetype)initWithChatItem:(id<NOCChatItem>)chatItem cellWidth:(CGFloat)width;
- (void)calculateLayout;

@end
