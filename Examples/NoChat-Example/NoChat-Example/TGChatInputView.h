//
//  TGChatInputView.h
//  NoChat-Example
//
//  Created by little2s on 2016/12/25.
//  Copyright © 2016年 little2s. All rights reserved.
//

#import <NoChat/NoChat.h>

@class TGChatInputView;
@class NOCGrowingTextView;

@protocol TGChatInputViewDelegate <NOCChatInputViewDelegate>

@optional
- (void)chatInputView:(TGChatInputView *)chatInputView didSendText:(NSString *)text;

@end

@interface TGChatInputView : NOCChatInputView

@property (nonatomic, strong) UIView *inputBar;
@property (nonatomic, strong) UIToolbar *barBackgroundView;
@property (nonatomic, strong) NOCGrowingTextView *textView;
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

@interface TGChatInputView (TGStyle)

+ (UIFont *)textViewFont;
+ (UIFont *)sendButtonFont;

@end
