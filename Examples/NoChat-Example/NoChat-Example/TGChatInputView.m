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
        _textViewHeight = 28;
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
    BOOL hasText = self.textView.hasText;
    self.sendButton.enabled = hasText;
    self.sendButton.hidden = !hasText;
    self.micButton.hidden = hasText;
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
    textView.plcaeholderFont = [TGChatInputView textViewFont];
    textView.textInsets = UIEdgeInsetsMake(4.5, 4, 3.5, 4);
    [self.inputBar addSubview:textView];
    self.textView = textView;
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    sendButton.translatesAutoresizingMaskIntoConstraints = NO;
    [sendButton setTitle:(self.sendButtonTitle ?: @"Send") forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(didTapSendButton:) forControlEvents:UIControlEventTouchUpInside];
    sendButton.titleLabel.font = [TGChatInputView sendButtonFont];
    sendButton.enabled = NO;
    sendButton.hidden= YES;
    [self.inputBar addSubview:sendButton];
    self.sendButton = sendButton;
    
    UIButton *micButton = [UIButton buttonWithType:UIButtonTypeSystem];
    micButton.translatesAutoresizingMaskIntoConstraints = NO;
    [micButton setImage:[UIImage imageNamed:@"TGMicButton"] forState:UIControlStateNormal];
    [self.inputBar addSubview:micButton];
    self.micButton = micButton;
    
    UIButton *attachButton = [UIButton buttonWithType:UIButtonTypeSystem];
    attachButton.translatesAutoresizingMaskIntoConstraints = NO;
    [attachButton setImage:[UIImage imageNamed:@"TGAttachButton"] forState:UIControlStateNormal];
    [self.inputBar addSubview:attachButton];
    self.attachButton = attachButton;
}

- (void)setupLayoutConstraints
{
    [NSLayoutConstraint constraintWithItem:self.inputBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0].active = YES;;
    [NSLayoutConstraint constraintWithItem:self.inputBar attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.inputBar attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:0].active = YES;
    
    [self.barBackgroundView setContentHuggingPriority:240 forAxis:UILayoutConstraintAxisVertical];
    [self.barBackgroundView setContentCompressionResistancePriority:240 forAxis:UILayoutConstraintAxisVertical];

    [NSLayoutConstraint constraintWithItem:self.barBackgroundView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.inputBar attribute:NSLayoutAttributeTop multiplier:1 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.barBackgroundView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.inputBar attribute:NSLayoutAttributeLeading multiplier:1 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.barBackgroundView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.inputBar attribute:NSLayoutAttributeBottom multiplier:1 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.barBackgroundView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.inputBar attribute:NSLayoutAttributeTrailing multiplier:1 constant:0].active = YES;
    
    self.textViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.inputBar attribute:NSLayoutAttributeTop multiplier:1 constant:9];
    self.textViewLeadingConstraint = [NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.inputBar attribute:NSLayoutAttributeLeading multiplier:1 constant:40];
    self.textViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.inputBar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.textView attribute:NSLayoutAttributeBottom multiplier:1 constant:8];
    self.textViewTrailingConstraint = [NSLayoutConstraint constraintWithItem:self.inputBar attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.textView attribute:NSLayoutAttributeTrailing multiplier:1 constant:50];
    self.textViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:28];
    [NSLayoutConstraint activateConstraints:@[self.textViewTopConstraint, self.textViewLeadingConstraint, self.textViewBottomConstraint, self.textViewTrailingConstraint, self.textViewHeightConstraint]];
    
    [NSLayoutConstraint constraintWithItem:self.sendButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.inputBar attribute:NSLayoutAttributeBottom multiplier:1 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.sendButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.inputBar attribute:NSLayoutAttributeTrailing multiplier:1 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.sendButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:50].active = YES;
    [NSLayoutConstraint constraintWithItem:self.sendButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:45].active = YES;
    
    [NSLayoutConstraint constraintWithItem:self.micButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.inputBar attribute:NSLayoutAttributeBottom multiplier:1 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.micButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.inputBar attribute:NSLayoutAttributeTrailing multiplier:1 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.micButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:50].active = YES;
    [NSLayoutConstraint constraintWithItem:self.micButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:45].active = YES;
    
    [NSLayoutConstraint constraintWithItem:self.attachButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.inputBar attribute:NSLayoutAttributeBottom multiplier:1 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.attachButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.inputBar attribute:NSLayoutAttributeLeading multiplier:1 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.attachButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:40].active = YES;
    [NSLayoutConstraint constraintWithItem:self.attachButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:45].active = YES;
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
                [((id<TGChatInputViewDelegate>)self.delegate) chatInputView:self didSendText:str];
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
