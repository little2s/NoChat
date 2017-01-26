//
//  TGSystemMessageCellLayout.h
//  NoChat-Example
//
//  Created by little2s on 2017/1/26.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import <NoChat/NoChat.h>

@class NOCMessage;

@interface TGSystemMessageCellLayout : NSObject <NOCChatItemCellLayout>

@property (nonatomic, strong) NSString *reuseIdentifier;
@property (nonatomic, strong) id<NOCChatItem> chatItem;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

@property (nonatomic, strong, readonly) NOCMessage *message;

@property (nonatomic, assign) CGRect backgroundImageViewFrame;
@property (nonatomic, assign) UIImage *backgroundImage;
@property (nonatomic, assign) CGRect textLabelFrame;
@property (nonatomic, strong) NSAttributedString *attributedText;

- (instancetype)initWithChatItem:(id<NOCChatItem>)chatItem cellWidth:(CGFloat)width;
- (void)calculateLayout;

@end

@interface TGSystemMessageCellLayout (TGStyle)

+ (UIFont *)textFont;
+ (UIColor *)textColor;
+ (UIImage *)systemMessageBackground;

@end
