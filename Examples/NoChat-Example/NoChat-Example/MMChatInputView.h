//
//  MMChatInputView.h
//  NoChat-Example
//
//  Created by little2s on 2017/1/22.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import <NoChat/NoChat.h>

@class MMChatInputView;
@class NOCGrowingTextView;

@protocol MMChatInputViewDelegate <NOCChatInputViewDelegate>

@optional
- (void)didChatInputViewStartInputting:(MMChatInputView *)chatInputView;
- (void)chatInputView:(MMChatInputView *)chatInputView didSendText:(NSString *)text;

@end

@interface MMChatInputView : NOCChatInputView

@property (nonatomic, strong) UIView *inputBar;
@property (nonatomic, strong) UIToolbar *barBackgroundView;
@property (nonatomic, strong) NOCGrowingTextView *textView;
@property (nonatomic, strong) UIButton *micButton;
@property (nonatomic, strong) UIButton *faceButton;
@property (nonatomic, strong) UIButton *attachButton;

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

@interface MMChatInputView (MMStyle)

+ (UIFont *)textViewFont;
+ (UIFont *)sendButtonFont;

@end
