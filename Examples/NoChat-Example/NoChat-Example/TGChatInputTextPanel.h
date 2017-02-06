//
//  TGChatInputTextPanel.h
//  NoChat-Example
//
//  Created by little2s on 2017/2/2.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import <NoChat/NoChat.h>

@class TGChatInputTextPanel;
@class HPGrowingTextView;

@protocol TGChatInputTextPanelDelegate <NOCChatInputPanelDelegate>

@optional
- (void)inputTextPanel:(TGChatInputTextPanel *)inputTextPanel requestSendText:(NSString *)text;

@end

@interface TGChatInputTextPanel : NOCChatInputPanel

@property (nonatomic, strong) CALayer *stripeLayer;
@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, strong) HPGrowingTextView *inputField;
@property (nonatomic, strong) UIView *inputFieldClippingContainer;
@property (nonatomic, strong) UIImageView *fieldBackground;

@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UIButton *attachButton;
@property (nonatomic, strong) UIButton *micButton;

- (void)toggleSendButtonEnabled;
- (void)clearInputField;

@end
