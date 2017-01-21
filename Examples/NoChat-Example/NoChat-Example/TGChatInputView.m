//
//  TGChatInputView.m
//  NoChat-Example
//
//  Created by little2s on 2016/12/25.
//  Copyright © 2016年 little2s. All rights reserved.
//

#import "TGChatInputView.h"
#import "NOCGrowingTextView.h"
#import "NOCKeyboardManager.h"
#import "UIFont+NOChat.h"

#define kAnimationDuration 0.3

@interface TGChatInputView () <NOCGrowingTextViewDelegate>

@property (nonatomic, strong) NOCKeyboardManager *keyboardManager;

@end

@implementation TGChatInputView

- (void)dealloc
{
    [self stopKeyboardManager];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _textViewHeight = [NOCGrowingTextView minimumHeight];
        _height = 45;
        _keyboardManager = [[NOCKeyboardManager alloc] init];
        [self setupSubviews];
        [self startKeyboardManager];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    [self setupLayoutConstraints];
}

- (void)endInputting:(BOOL)animated
{
    [self endEditing:animated];
}

- (void)toggleSendButtonEnabled
{
    self.sendButton.enabled = self.textView.hasText;
}

- (void)clearInputText
{
    [self.textView clear];
    [self toggleSendButtonEnabled];
}

- (CGFloat)inputBarHeight
{
    return self.textViewHeight + self.textViewTopConstraint.constant + self.textViewBottomConstraint.constant;
}

#pragma mark - TGGrowingTextViewDelegate

- (void)growingTextView:(NOCGrowingTextView *)textView didUpdateHeight:(CGFloat)height
{
    CGFloat oldHeight = self.height;
    CGFloat newHeight = self.height + (height - self.textViewHeight);
    self.textViewHeight = height;
    self.height = newHeight;
    
    self.textViewHeightConstraint.constant = height;
    [self setNeedsLayout];
    [UIView animateWithDuration:kAnimationDuration animations:^{
        if ([self.delegate respondsToSelector:@selector(chatInputView:didUpdateHeight:oldHeight:)]) {
            [self.delegate chatInputView:self didUpdateHeight:newHeight oldHeight:oldHeight];
        }
    }];
    
    [self toggleSendButtonEnabled];
}

#pragma mark - Private

- (void)setupSubviews
{
    UIView *inputBar = [[UIView alloc] init];
    inputBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:inputBar];
    self.inputBar = inputBar;
    
    UIToolbar *barBackgroundView = [[UIToolbar alloc] init];
    barBackgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.inputBar addSubview:barBackgroundView];
    self.barBackgroundView = barBackgroundView;
    
    NOCGrowingTextView *textView = [[NOCGrowingTextView alloc] init];
    textView.translatesAutoresizingMaskIntoConstraints = NO;
    textView.growingDelegate = self;
    textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    textView.layer.borderWidth = 0.5;
    textView.layer.cornerRadius = 5;
    textView.layer.masksToBounds = YES;
    textView.font = [TGChatInputView textViewFont];
    textView.placeholder = self.textPlaceholder ?: @"Message";
    textView.placeholderColor = [UIColor lightGrayColor];
    textView.plcaeholderFont = [TGChatInputView textViewFont];;
    [self.inputBar addSubview:textView];
    self.textView = textView;
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    sendButton.translatesAutoresizingMaskIntoConstraints = NO;
    [sendButton setTitle:(self.sendButtonTitle ?: @"Send") forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(didTapSendButton:) forControlEvents:UIControlEventTouchUpInside];
    sendButton.titleLabel.font = [TGChatInputView sendButtonFont];
    sendButton.enabled = NO;
    [self.inputBar addSubview:sendButton];
    self.sendButton = sendButton;
}

- (void)setupLayoutConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.inputBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.inputBar attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.inputBar attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    
    [self.barBackgroundView setContentHuggingPriority:240 forAxis:UILayoutConstraintAxisVertical];
    [self.barBackgroundView setContentCompressionResistancePriority:240 forAxis:UILayoutConstraintAxisVertical];

    [self.inputBar addConstraint:[NSLayoutConstraint constraintWithItem:self.barBackgroundView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.inputBar attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.inputBar addConstraint:[NSLayoutConstraint constraintWithItem:self.barBackgroundView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.inputBar attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self.inputBar addConstraint:[NSLayoutConstraint constraintWithItem:self.barBackgroundView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.inputBar attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self.inputBar addConstraint:[NSLayoutConstraint constraintWithItem:self.barBackgroundView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.inputBar attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    
    self.textViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.inputBar attribute:NSLayoutAttributeTop multiplier:1 constant:9];
    self.textViewLeadingConstraint = [NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.inputBar attribute:NSLayoutAttributeLeading multiplier:1 constant:16];
    self.textViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.inputBar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.textView attribute:NSLayoutAttributeBottom multiplier:1 constant:8];
    self.textViewTrailingConstraint = [NSLayoutConstraint constraintWithItem:self.inputBar attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.textView attribute:NSLayoutAttributeTrailing multiplier:1 constant:55];
    self.textViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:28];
    [self.inputBar addConstraints:@[self.textViewTopConstraint, self.textViewLeadingConstraint, self.textViewBottomConstraint, self.textViewTrailingConstraint, self.textViewHeightConstraint]];
    
    [self.inputBar addConstraint:[NSLayoutConstraint constraintWithItem:self.sendButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.inputBar attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self.inputBar addConstraint:[NSLayoutConstraint constraintWithItem:self.sendButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.inputBar attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    [self.inputBar addConstraint:[NSLayoutConstraint constraintWithItem:self.sendButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:55]];
    [self.inputBar addConstraint:[NSLayoutConstraint constraintWithItem:self.sendButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:45]];
}

- (void)startKeyboardManager
{
    [self setupKeyboardAnimation];
    self.keyboardManager.keyboardObserveEnabled = YES;
}

- (void)stopKeyboardManager
{
    self.keyboardManager.keyboardObserveEnabled = NO;
}

- (void)setupKeyboardAnimation
{
    __weak typeof(self) weakSelf = self;
    self.keyboardManager.postKeyboardInfo = ^(NOCKeyboardManager *manager, NOCKeyboardInfo *keyboardInfo) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        CGFloat oldHeight = strongSelf.height;
        CGFloat newHeight = (keyboardInfo.action == NOCKeyboardHide) ? strongSelf.inputBarHeight : (strongSelf.inputBarHeight + keyboardInfo.height);
        
        NSTimeInterval duration = keyboardInfo.animationDuration;
        NSUInteger curve = keyboardInfo.animationCurve;
        UIViewAnimationOptions options = curve << 16 | UIViewAnimationOptionBeginFromCurrentState;
        [UIView animateWithDuration:duration delay:0 options:options animations:^{
            if ([strongSelf.delegate respondsToSelector:@selector(chatInputView:didUpdateHeight:oldHeight:)]) {
                [strongSelf.delegate chatInputView:strongSelf didUpdateHeight:newHeight oldHeight:oldHeight];
            }
        } completion:nil];
        
        strongSelf.height = newHeight;
    };
}

- (void)didTapSendButton:(UIButton *)button
{
    NSString *text = self.textView.text;
    if (text) {
        NSString *str = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (str.length > 0) {
            if ([self.delegate respondsToSelector:@selector(chatInputView:didSendText:)]) {
                [(id<TGChatInputViewDelegate>)self.delegate chatInputView:self didSendText:str];
            }
            [self clearInputText];
        }
    }
}

@end

@implementation TGChatInputView (TGStyle)

+ (UIFont *)textViewFont
{
    static id _textViewFont = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _textViewFont = [UIFont systemFontOfSize:16];
    });
    return _textViewFont;
}

+ (UIFont *)sendButtonFont
{
    static id _sendButtonFont = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sendButtonFont = [UIFont noc_mediumSystemFontOfSize:17];
    });
    return _sendButtonFont;
}

@end
