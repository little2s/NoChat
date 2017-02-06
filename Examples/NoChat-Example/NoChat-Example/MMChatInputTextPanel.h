//
//  MMChatInputTextPanel.h
//  NoChat-Example
//
//  Created by little2s on 2017/2/5.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import <NoChat/NoChat.h>

@class MMChatInputTextPanel;
@class HPGrowingTextView;

@protocol MMChatInputTextPanelDelegate <NOCChatInputPanelDelegate>

@optional
- (void)didInputTextPanelStartInputting:(MMChatInputTextPanel *)inputTextPanel;
- (void)inputTextPanel:(MMChatInputTextPanel *)inputTextPanel requestSendText:(NSString *)text;

@end

@interface MMChatInputTextPanel : NOCChatInputPanel

@property (nonatomic, strong) UIToolbar *backgroundView;

@property (nonatomic, strong) HPGrowingTextView *inputField;
@property (nonatomic, strong) UIView *inputFieldClippingContainer;
@property (nonatomic, strong) UIView *fieldBackground;

@property (nonatomic, strong) UIButton *micButton;
@property (nonatomic, strong) UIButton *faceButton;
@property (nonatomic, strong) UIButton *attachButton;

- (void)clearInputField;

@end
