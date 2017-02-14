//
//  TGChatInputTextPanel.m
//  NoChat-Example
//
//  Copyright (c) 2016-present, little2s.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "TGChatInputTextPanel.h"
#import "UIFont+NoChat.h"
#import <HPGrowingTextView/HPGrowingTextView.h>

#define TGRetinaPixel 0.5

@interface TGChatInputTextPanel () <HPGrowingTextViewDelegate>

@property (nonatomic, assign) CGFloat sendButtonWidth;
@property (nonatomic, assign) UIEdgeInsets inputFieldInsets;
@property (nonatomic, assign) UIEdgeInsets inputFieldInternalEdgeInsets;
@property (nonatomic, assign) CGFloat baseHeight;

@property (nonatomic, assign) CGSize parentSize;

@property (nonatomic, assign) CGSize messageAreaSize;
@property (nonatomic, assign) CGFloat keyboardHeight;

@end

@implementation TGChatInputTextPanel

#pragma mark - Overrides

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _baseHeight = 45;
        _inputFieldInsets = UIEdgeInsetsMake(9, 41, 8, 0);
        _inputFieldInternalEdgeInsets = UIEdgeInsetsMake(-3 - TGRetinaPixel, 0, 0, 0);
        
        _sendButtonWidth = MIN(150, [NSLocalizedString(@"Send", @"") sizeWithAttributes:@{NSFontAttributeName:[UIFont noc_mediumSystemFontOfSize:17]}].width + 8);
        
        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:0.98];
        [self addSubview:_backgroundView];
        
        _stripeLayer = [[CALayer alloc] init];
        _stripeLayer.backgroundColor = [UIColor colorWithRed:179/255.0 green:170/255.0 blue:178/255.0 alpha:0.4].CGColor;
        [self.layer addSublayer:_stripeLayer];
        
        UIImage *filedBackgroundImage = [UIImage imageNamed:@"TGInputFieldBackground"];
        _fieldBackground = [[UIImageView alloc] initWithImage:filedBackgroundImage];
        _fieldBackground.frame = CGRectMake(41, 9, frame.size.width - 41 - _sendButtonWidth - 1, 28);
        [self addSubview:_fieldBackground];
        
        CGRect inputFieldClippingFrame = _fieldBackground.frame;
        _inputFieldClippingContainer = [[UIView alloc] initWithFrame:inputFieldClippingFrame];
        _inputFieldClippingContainer.clipsToBounds = YES;
        [self addSubview:_inputFieldClippingContainer];
        
        UIEdgeInsets inputFieldInternalEdgeInsets = _inputFieldInternalEdgeInsets;
        
        _inputField = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(inputFieldInternalEdgeInsets.left, inputFieldInternalEdgeInsets.top, inputFieldClippingFrame.size.width - inputFieldInternalEdgeInsets.left, inputFieldClippingFrame.size.height)];
        _inputField.placeholder = NSLocalizedString(@"Message", @"");
        _inputField.animateHeightChange = NO;
        _inputField.animationDuration = 0;
        _inputField.font = [UIFont systemFontOfSize:16];
        _inputField.backgroundColor = [UIColor clearColor];
        _inputField.opaque = NO;
        _inputField.clipsToBounds = YES;
        _inputField.internalTextView.backgroundColor = [UIColor clearColor];
        _inputField.internalTextView.opaque = NO;
        _inputField.internalTextView.contentMode = UIViewContentModeLeft;
        _inputField.maxNumberOfLines = [self maxNumberOfLinesForSize:_parentSize];
        _inputField.delegate = self;
        
        _inputField.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(-inputFieldInternalEdgeInsets.top, 0, 5 - TGRetinaPixel, 0);
        
        [_inputFieldClippingContainer addSubview:_inputField];
        
        _sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _sendButton.exclusiveTouch = YES;
        [_sendButton setTitle:NSLocalizedString(@"Send", @"") forState:UIControlStateNormal];
        [_sendButton setTitleColor:[UIColor colorWithRed:0/255.0 green:126/255.0 blue:229/255.0 alpha:1] forState:UIControlStateNormal];
        [_sendButton setTitleColor:[UIColor colorWithRed:142/255.0 green:142/255.0 blue:147/255.0 alpha:1] forState:UIControlStateDisabled];
        _sendButton.titleLabel.font = [UIFont noc_mediumSystemFontOfSize:17];
        _sendButton.enabled = NO;
        _sendButton.hidden= YES;
        [_sendButton addTarget:self action:@selector(didTapSendButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_sendButton];
        
        _attachButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _attachButton.exclusiveTouch = YES;
        [_attachButton setImage:[UIImage imageNamed:@"TGAttachButton"] forState:UIControlStateNormal];
        [self addSubview:_attachButton];
        
        _micButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _micButton.exclusiveTouch = YES;
        [_micButton setImage:[UIImage imageNamed:@"TGMicButton"] forState:UIControlStateNormal];
        [self addSubview:_micButton];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    CGFloat baseHeight = self.baseHeight;
    CGFloat sendButtonWidth = self.sendButtonWidth;
    
    self.backgroundView.frame = bounds;
    
    self.stripeLayer.frame = CGRectMake(0, -TGRetinaPixel, bounds.size.width, TGRetinaPixel);
    
    UIEdgeInsets inputFieldInsets = self.inputFieldInsets;
    self.fieldBackground.frame = CGRectMake(inputFieldInsets.left, inputFieldInsets.top, bounds.size.width - inputFieldInsets.left - inputFieldInsets.right - sendButtonWidth - 1, bounds.size.height - inputFieldInsets.top - inputFieldInsets.bottom);
    
    CGRect inputFieldClippingFrame = self.fieldBackground.frame;
    self.inputFieldClippingContainer.frame = inputFieldClippingFrame;
    
    self.sendButton.frame = CGRectMake(bounds.size.width - sendButtonWidth, bounds.size.height - baseHeight, sendButtonWidth, baseHeight);

    self.attachButton.frame = CGRectMake(0, bounds.size.height - baseHeight, 40, baseHeight);

    self.micButton.frame = CGRectMake(bounds.size.width - sendButtonWidth, bounds.size.height - baseHeight, sendButtonWidth, baseHeight);
}

- (void)endInputting:(BOOL)animated
{
    if (self.inputField.internalTextView.isFirstResponder) {
        [self.inputField.internalTextView resignFirstResponder];
    }
}

- (void)adjustForSize:(CGSize)size keyboardHeight:(CGFloat)keyboardHeight duration:(NSTimeInterval)duration animationCurve:(int)animationCurve
{
    CGSize previousSize = self.parentSize;
    self.parentSize = size;
    
    if (ABS(size.width - previousSize.width) > FLT_EPSILON) {
        [self changeToSize:size keyboardHeight:keyboardHeight duration:0];
    }

    [self adjustForSize:size keyboardHeight:keyboardHeight duration:duration inputFieldHeight:self.inputField.frame.size.height animationCurve:animationCurve];
}

- (void)changeToSize:(CGSize)size keyboardHeight:(CGFloat)keyboardHeight duration:(NSTimeInterval)duration
{
    self.parentSize = size;
    
    CGSize messageAreaSize = size;
    self.messageAreaSize = messageAreaSize;
    self.keyboardHeight = keyboardHeight;
    
    UIView *inputFieldSnapshotView = nil;
    if (duration > DBL_EPSILON) {
        inputFieldSnapshotView = [self.inputField.internalTextView snapshotViewAfterScreenUpdates:NO];
        inputFieldSnapshotView.frame = CGRectOffset(self.inputField.frame, self.inputFieldClippingContainer.frame.origin.x, self.inputFieldClippingContainer.frame.origin.y);
        [self addSubview:inputFieldSnapshotView];
    }
    
    [UIView performWithoutAnimation:^{
        [self updateInputFieldLayout];
    }];
    
    CGFloat inputContainerHeight = [self heightForInputFieldHeight:self.inputField.frame.size.height];
    CGRect newInputContainerFrame = CGRectMake(0, messageAreaSize.height - keyboardHeight - inputContainerHeight, messageAreaSize.width, inputContainerHeight);
    
    if (duration > DBL_EPSILON) {
        if (inputFieldSnapshotView != nil) {
            self.inputField.alpha = 0;
        }
        
        [UIView animateWithDuration:duration animations:^{
            self.frame = newInputContainerFrame;
            [self layoutSubviews];

            if (inputFieldSnapshotView != nil) {
                self.inputField.alpha = 1;
                inputFieldSnapshotView.frame = CGRectOffset(self.inputField.frame, self.inputFieldClippingContainer.frame.origin.x, self.inputFieldClippingContainer.frame.origin.y);
                inputFieldSnapshotView.alpha = 0;
            }
        } completion:^(BOOL finished) {
            [inputFieldSnapshotView removeFromSuperview];
        }];
    } else {
        self.frame = newInputContainerFrame;
    }
}

#pragma mark - Public

- (void)toggleSendButtonEnabled
{
    BOOL hasText = self.inputField.internalTextView.hasText;
    self.sendButton.enabled = hasText;
    self.sendButton.hidden = !hasText;
    self.micButton.hidden = hasText;
}

- (void)clearInputField
{
    self.inputField.internalTextView.text = nil;
    [self.inputField refreshHeight];
    
    [self toggleSendButtonEnabled];
}

#pragma mark - HPGrowingTextViewDelegate

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    CGFloat inputContainerHeight = [self heightForInputFieldHeight:height];
    CGRect newInputContainerFrame = CGRectMake(0, self.messageAreaSize.height - self.keyboardHeight - inputContainerHeight, self.messageAreaSize.width, inputContainerHeight);
    
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = newInputContainerFrame;
        [self layoutSubviews];
    }];

    id<TGChatInputTextPanelDelegate> delegate = (id<TGChatInputTextPanelDelegate>)self.delegate;
    if ([delegate respondsToSelector:@selector(inputPanel:willChangeHeight:duration:animationCurve:)]) {
        [delegate inputPanel:self willChangeHeight:inputContainerHeight duration:0.3 animationCurve:0];
    }
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView
{
    [self toggleSendButtonEnabled];
}

#pragma mark - Private

- (void)didTapSendButton:(UIButton *)sender
{
    NSString *text = self.inputField.internalTextView.text;
    if (!text) {
        return;
    }
    
    NSString *str = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (str.length > 0) {
        id<TGChatInputTextPanelDelegate> delegate = (id<TGChatInputTextPanelDelegate>)self.delegate;
        if ([delegate respondsToSelector:@selector(inputTextPanel:requestSendText:)]) {
            [delegate inputTextPanel:self requestSendText:str];
        }
        [self clearInputField];
    }
}

- (void)adjustForSize:(CGSize)size keyboardHeight:(CGFloat)keyboardHeight duration:(NSTimeInterval)duration inputFieldHeight:(CGFloat)inputFieldHeight animationCurve:(int)animationCurve
{
    dispatch_block_t block = ^{
        CGSize messageAreaSize = size;
        
        self.messageAreaSize = messageAreaSize;
        self.keyboardHeight = keyboardHeight;
        
        CGFloat inputContainerHeight = [self heightForInputFieldHeight:inputFieldHeight];
        self.frame = CGRectMake(0, messageAreaSize.height - keyboardHeight - inputContainerHeight, messageAreaSize.width, inputContainerHeight);
        [self layoutSubviews];
    };
    
    if (duration > DBL_EPSILON) {
        [UIView animateWithDuration:duration delay:0 options:animationCurve << 16 animations:block completion:nil];
    } else {
        block();
    }
}

- (CGFloat)heightForInputFieldHeight:(CGFloat)inputFieldHeight
{
    UIEdgeInsets inputFieldInsets = [self inputFieldInsets];
    CGFloat height = MAX([self baseHeight], inputFieldHeight - 8 + inputFieldInsets.top + inputFieldInsets.bottom);
    return height;
}

- (void)updateInputFieldLayout
{
    NSRange range = self.inputField.internalTextView.selectedRange;
    
    self.inputField.delegate = nil;
    
    UIEdgeInsets inputFieldInsets = [self inputFieldInsets];
    UIEdgeInsets inputFieldInternalEdgeInsets = [self inputFieldInternalEdgeInsets];
    
    CGRect inputFieldClippingFrame = CGRectMake(inputFieldInsets.left, inputFieldInsets.top, self.parentSize.width - inputFieldInsets.left - inputFieldInsets.right - self.sendButtonWidth - 1, 0);
    
    CGRect inputFieldFrame = CGRectMake(inputFieldInternalEdgeInsets.left, inputFieldInternalEdgeInsets.top, inputFieldClippingFrame.size.width - inputFieldInternalEdgeInsets.left, 0);
    
    self.inputField.frame = inputFieldFrame;
    self.inputField.internalTextView.frame = CGRectMake(0, 0, inputFieldFrame.size.width, inputFieldFrame.size.height);
    
    [self.inputField setMaxNumberOfLines:[self maxNumberOfLinesForSize:_parentSize]];
    [self.inputField refreshHeight];
    
    self.inputField.internalTextView.selectedRange = range;
    
    self.inputField.delegate = self;
}

- (int)maxNumberOfLinesForSize:(CGSize)size
{
    if (size.height <= 320.0f - FLT_EPSILON) {
        return 3;
    } else if (size.height <= 480.0f - FLT_EPSILON) {
        return 5;
    } else {
        return 7;
    }
}

@end
