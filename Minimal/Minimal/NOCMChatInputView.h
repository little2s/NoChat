//
//  NOCMChatInputView.h
//  NoChat-Example
//
//  Created by little2s on 2016/12/25.
//  Copyright © 2016年 little2s. All rights reserved.
//

#import <NoChat/NoChat.h>

@class NOCMChatInputView;
@class NOCMGrowingTextView;

@protocol NOCMChatInputViewDelegate <NOCChatInputViewDelegate>

@optional
- (void)chatInputView:(NOCMChatInputView *)chatInputView didSendText:(NSString *)text;

@end

@interface NOCMChatInputView : NOCChatInputView

@property (nonatomic, strong) UIView *inputBar;
@property (nonatomic, strong) UIToolbar *barBackgroundView;
@property (nonatomic, strong) NOCMGrowingTextView *textView;
@property (nonatomic, strong) UIButton *sendButton;

@property (nonatomic, strong) NSLayoutConstraint *textViewTopConstraint;
@property (nonatomic, strong) NSLayoutConstraint *textViewLeadingConstraint;
@property (nonatomic, strong) NSLayoutConstraint *textViewBottomConstraint;
@property (nonatomic, strong) NSLayoutConstraint *textViewTrailingConstraint;
@property (nonatomic, strong) NSLayoutConstraint *textViewHeightConstraint;

@property (nonatomic, assign) CGFloat textViewHeight;
@property (nonatomic, assign, readonly) CGFloat inputBarHeight;
@property (nonatomic, assign) CGFloat height;

@property (nonatomic, strong) NSString *sendButtonTitle;
@property (nonatomic, strong) NSString *textPlaceholder;

- (void)toggleSendButtonEnabled;
- (void)clearInputText;

@end

@interface NOCMChatInputView (NOCMStyle)

+ (NSTimeInterval)animationDuration;
+ (UIFont *)textViewFont;
+ (UIFont *)sendButtonFont;

@end
