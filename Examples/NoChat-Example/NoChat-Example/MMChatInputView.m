//
//  MMChatInputView.m
//  NoChat-Example
//
//  Created by little2s on 2017/1/22.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import "MMChatInputView.h"
#import "NOCGrowingTextView.h"
#import "NOCKeyboardManager.h"
#import "UIFont+NOChat.h"

#define kAnimationDuration 0.3

@interface MMChatInputView () <NOCGrowingTextViewDelegate>

@property (nonatomic, strong) NOCKeyboardManager *keyboardManager;

@end

@implementation MMChatInputView

- (void)dealloc
{
    [self stopKeyboardManager];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _textViewHeight = 35;
        _height = 50;
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

#pragma mark - MMGrowingTextViewDelegate

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

- (void)growingTextView:(NOCGrowingTextView *)textView didSendText:(NSString *)text
{
    if ([self.delegate respondsToSelector:@selector(chatInputView:didSendText:)]) {
        [((id<MMChatInputViewDelegate>)self.delegate) chatInputView:self didSendText:text];
    }
}

- (void)growingTextViewDidBeginEditing:(NOCGrowingTextView *)textView
{
    if ([self.delegate respondsToSelector:@selector(didChatInputViewStartInputting:)]) {
        [((id<MMChatInputViewDelegate>)self.delegate) didChatInputViewStartInputting:self];
    }
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
    textView.font = [MMChatInputView textViewFont];
    textView.textInsets = UIEdgeInsetsMake(8, 6, 5, 6);
    textView.minimumHeight = 35;
    textView.enablesReturnKeyAutomatically = YES;
    textView.returnKeyType = UIReturnKeySend;
    [self.inputBar addSubview:textView];
    self.textView = textView;
    
    UIButton *micButton = [UIButton buttonWithType:UIButtonTypeSystem];
    micButton.translatesAutoresizingMaskIntoConstraints = NO;
    [micButton setImage:[UIImage imageNamed:@"MMVoice"] forState:UIControlStateNormal];
    [micButton setImage:[UIImage imageNamed:@"MMVoiceHL"] forState:UIControlStateHighlighted];
    [self.inputBar addSubview:micButton];
    self.micButton = micButton;
    
    UIButton *faceButton = [UIButton buttonWithType:UIButtonTypeSystem];
    faceButton.translatesAutoresizingMaskIntoConstraints = NO;
    [faceButton setImage:[UIImage imageNamed:@"MMEmotion"] forState:UIControlStateNormal];
    [faceButton setImage:[UIImage imageNamed:@"MMEmotionHL"] forState:UIControlStateHighlighted];
    [self.inputBar addSubview:faceButton];
    self.faceButton = faceButton;
    
    UIButton *attachButton = [UIButton buttonWithType:UIButtonTypeSystem];
    attachButton.translatesAutoresizingMaskIntoConstraints = NO;
    [attachButton setImage:[UIImage imageNamed:@"MMAttach"] forState:UIControlStateNormal];
    [attachButton setImage:[UIImage imageNamed:@"MMAttachHL"] forState:UIControlStateHighlighted];
    [self.inputBar addSubview:attachButton];
    self.attachButton = attachButton;
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
    
    self.textViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.inputBar attribute:NSLayoutAttributeTop multiplier:1 constant:7.5];
    self.textViewLeadingConstraint = [NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.inputBar attribute:NSLayoutAttributeLeading multiplier:1 constant:40];
    self.textViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.inputBar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.textView attribute:NSLayoutAttributeBottom multiplier:1 constant:7.5];
    self.textViewTrailingConstraint = [NSLayoutConstraint constraintWithItem:self.inputBar attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.textView attribute:NSLayoutAttributeTrailing multiplier:1 constant:80];
    self.textViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:35];
    [self.inputBar addConstraints:@[self.textViewTopConstraint, self.textViewLeadingConstraint, self.textViewBottomConstraint, self.textViewTrailingConstraint, self.textViewHeightConstraint]];
    
    [self.inputBar addConstraint:[NSLayoutConstraint constraintWithItem:self.micButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.inputBar attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self.inputBar addConstraint:[NSLayoutConstraint constraintWithItem:self.micButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.inputBar attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self.inputBar addConstraint:[NSLayoutConstraint constraintWithItem:self.micButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:40]];
    [self.inputBar addConstraint:[NSLayoutConstraint constraintWithItem:self.micButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:50]];
    
    [self.inputBar addConstraint:[NSLayoutConstraint constraintWithItem:self.faceButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.inputBar attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self.inputBar addConstraint:[NSLayoutConstraint constraintWithItem:self.faceButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.attachButton attribute:NSLayoutAttributeLeading multiplier:1 constant:4]];
    [self.inputBar addConstraint:[NSLayoutConstraint constraintWithItem:self.faceButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:40]];
    [self.inputBar addConstraint:[NSLayoutConstraint constraintWithItem:self.faceButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:50]];
    
    [self.inputBar addConstraint:[NSLayoutConstraint constraintWithItem:self.attachButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.inputBar attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self.inputBar addConstraint:[NSLayoutConstraint constraintWithItem:self.attachButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.inputBar attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    [self.inputBar addConstraint:[NSLayoutConstraint constraintWithItem:self.attachButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:40]];
    [self.inputBar addConstraint:[NSLayoutConstraint constraintWithItem:self.attachButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:50]];
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

@end

@implementation MMChatInputView (MMStyle)

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
