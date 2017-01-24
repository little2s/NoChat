//
//  MMBaseMessageCellLayout.h
//  NoChat-Example
//
//  Created by little2s on 2017/1/22.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import <NoChat/NoChat.h>

@class NOCMessage;

@interface MMBaseMessageCellLayout : NSObject <NOCChatItemCellLayout>

@property (nonatomic, strong) NSString *reuseIdentifier;
@property (nonatomic, strong) id<NOCChatItem> chatItem;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

@property (nonatomic, strong, readonly) NOCMessage *message;
@property (nonatomic, assign, readonly) BOOL isOutgoing;

@property (nonatomic, assign) UIEdgeInsets bubbleViewMargin;
@property (nonatomic, assign) CGRect bubbleViewFrame;
@property (nonatomic, assign) CGFloat avatarSize;
@property (nonatomic, assign) CGRect avatarImageViewFrame;
@property (nonatomic, strong) UIImage *avatarImage;

- (instancetype)initWithChatItem:(id<NOCChatItem>)chatItem cellWidth:(CGFloat)width;
- (void)calculateLayout;

@end

@interface MMBaseMessageCellLayout (MMStyle)

+ (UIImage *)outgoingAvatarImage;
+ (UIImage *)incomingAvatarImage;

@end
