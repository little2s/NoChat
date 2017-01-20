//
//  NOCMMessageCellLayout.h
//  NoChat-Example
//
//  Created by little2s on 2016/12/25.
//  Copyright © 2016年 little2s. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NoChat/NoChat.h>
#import "NOCMTextKit.h"

@class NOCMMessageCellLayout;

@protocol NOCMMessageContentViewLayout <NSObject>

@property (nonatomic, weak) NOCMMessageCellLayout *cellLayout;

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

- (void)calculateLayout;

@end

@interface NOCMMessageCellLayout : NSObject <NOCChatItemCellLayout>

@property (nonatomic, strong) NSString *reuseIdentifier;

@property (nonatomic, strong) id<NOCChatItem> chatItem;
@property (nonatomic, strong) id<NOCMMessageContentViewLayout> messageContentViewLayout;

@property (nonatomic, assign) CGRect headViewFrame;
@property (nonatomic, assign) CGRect senderDisplayNameLabelFrame;
@property (nonatomic, assign) CGRect dateLabelFrame;

@property (nonatomic, assign) CGRect contentViewFrame;

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

- (instancetype)initWithChatItem:(id<NOCChatItem>)chatItem cellWidth:(CGFloat)width;
- (void)calculateLayout;

@end

@interface NOCMMessageCellLayout (NOCMStyle)

+ (UIFont *)senderDisplayNameFont;
+ (UIFont *)dateFont;

+ (UIColor *)senderDisplayNameColor;
+ (UIColor *)dateColor;

@end

// Text Message
@interface NOCMTextMessageContentViewLayout : NSObject <NOCMMessageContentViewLayout>

@property (nonatomic, weak) NOCMMessageCellLayout *cellLayout;
@property (nonatomic, assign) CGRect textLabelFrame;
@property (nonatomic, strong) NOCMTextLayout *textLayout;

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

- (void)calculateLayout;

@end

@interface NOCMTextMessageContentViewLayout (NOCMStyle)

+ (UIFont *)textFont;
+ (UIColor *)textColor;
+ (UIColor *)linkColor;

@end

@interface NOCMTextLinePositionModifier : NSObject <NOCMTextLinePositionModifier>

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, assign) CGFloat paddingTop;
@property (nonatomic, assign) CGFloat paddingBottom;
@property (nonatomic, assign) CGFloat lineHeightMultiple;

- (CGFloat)heightForLineCount:(NSUInteger)lineCount;

@end
