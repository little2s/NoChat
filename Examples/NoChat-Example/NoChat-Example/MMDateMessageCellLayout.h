//
//  MMDateMessageCellLayout.h
//  NoChat-Example
//
//  Created by little2s on 2017/1/26.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import <NoChat/NoChat.h>

@class NOCMessage;

@interface MMDateMessageCellLayout : NSObject <NOCChatItemCellLayout>

@property (nonatomic, strong) NSString *reuseIdentifier;
@property (nonatomic, strong) id<NOCChatItem> chatItem;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

@property (nonatomic, strong, readonly) NOCMessage *message;

@property (nonatomic, assign) CGRect backgroundImageViewFrame;
@property (nonatomic, assign) UIImage *backgroundImage;
@property (nonatomic, assign) CGRect dateLabelFrame;
@property (nonatomic, strong) NSAttributedString *attributedDate;

- (instancetype)initWithChatItem:(id<NOCChatItem>)chatItem cellWidth:(CGFloat)width;
- (void)calculateLayout;

@end

@interface MMDateMessageCellLayout (MMStyle)

+ (UIFont *)dateFont;
+ (UIColor *)dateColor;
+ (NSDateFormatter *)dateFormatter;

@end
