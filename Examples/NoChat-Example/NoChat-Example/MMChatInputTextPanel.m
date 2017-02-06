//
//  MMChatInputTextPanel.m
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

#import "MMChatInputTextPanel.h"
#import "UIFont+NoChat.h"
#import <HPGrowingTextView/HPGrowingTextView.h>

#define MMRetinaPixel 0.5

@interface MMChatInputTextPanel () <HPGrowingTextViewDelegate>

@property (nonatomic, assign) UIEdgeInsets inputFieldInsets;
@property (nonatomic, assign) UIEdgeInsets inputFieldInternalEdgeInsets;
@property (nonatomic, assign) CGFloat baseHeight;

@property (nonatomic, assign) CGSize parentSize;

@property (nonatomic, assign) CGSize messageAreaSize;
@property (nonatomic, assign) CGFloat keyboardHeight;

@end

@implementation MMChatInputTextPanel

#pragma mark - Overrides

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _baseHeight = 50;
        _inputFieldInsets = UIEdgeInsetsMake(7.5, 40, 7.5, 80);
        _inputFieldInternalEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0);
        
        _backgroundView = [[UIToolbar alloc] init];
        [self addSubview:_backgroundView];
        
        _fieldBackground = [[UIView alloc] init];
        _fieldBackground.frame = CGRectMake(40, 7.5, frame.size.width - 120, 35);
        _fieldBackground.backgroundColor = [UIColor whiteColor];
        _fieldBackground.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _fieldBackground.layer.borderWidth = 0.5;
        _fieldBackground.layer.cornerRadius = 5;
        _fieldBackground.layer.masksToBounds = YES;
        [self addSubview:_fieldBackground];
        
        CGRect inputFieldClippingFrame = _fieldBackground.frame;
        _inputFieldClippingContainer = [[UIView alloc] initWithFrame:inputFieldClippingFrame];
        _inputFieldClippingContainer.clipsToBounds = YES;
        [self addSubview:_inputFieldClippingContainer];
        
        UIEdgeInsets inputFieldInternalEdgeInsets = _inputFieldInternalEdgeInsets;
        
        _inputField = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(inputFieldInternalEdgeInsets.left, inputFieldInternalEdgeInsets.top, inputFieldClippingFrame.size.width - inputFieldInternalEdgeInsets.left, inputFieldClippingFrame.size.height)];
        _inputField.animateHeightChange = NO;
        _inputField.animationDuration = 0;
        _inputField.font = [UIFont systemFontOfSize:16];
        _inputField.backgroundColor = [UIColor clearColor];
        _inputField.opaque = NO;
        _inputField.clipsToBounds = YES;
        _inputField.internalTextView.backgroundColor = [UIColor clearColor];
        _inputField.internalTextView.opaque = NO;
        _inputField.internalTextView.contentMode = UIViewContentModeLeft;
        _inputField.internalTextView.enablesReturnKeyAutomatically = YES;
        _inputField.internalTextView.returnKeyType = UIReturnKeySend;
        _inputField.maxNumberOfLines = [self maxNumberOfLinesForSize:_parentSize];
        _inputField.delegate = self;
        
        _inputField.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(-inputFieldInternalEdgeInsets.top, 0, 5 - MMRetinaPixel, 0);
        
        [_inputFieldClippingContainer addSubview:_inputField];
        
        _micButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _micButton.exclusiveTouch = YES;
        [_micButton setImage:[UIImage imageNamed:@"MMVoice"] forState:UIControlStateNormal];
        [_micButton setImage:[UIImage imageNamed:@"MMVoiceHL"] forState:UIControlStateHighlighted];
        [self addSubview:_micButton];
        
        _faceButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _faceButton.exclusiveTouch = YES;
        [_faceButton setImage:[UIImage imageNamed:@"MMEmotion"] forState:UIControlStateNormal];
        [_faceButton setImage:[UIImage imageNamed:@"MMEmotionHL"] forState:UIControlStateHighlighted];
        [self addSubview:_faceButton];
        
        _attachButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _attachButton.exclusiveTouch = YES;
        [_attachButton setImage:[UIImage imageNamed:@"MMAttach"] forState:UIControlStateNormal];
        [_attachButton setImage:[UIImage imageNamed:@"MMAttachHL"] forState:UIControlStateHighlighted];
        [self addSubview:_attachButton];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    CGFloat baseHeight = self.baseHeight;
    
    self.backgroundView.frame = bounds;
    
    UIEdgeInsets inputFieldInsets = self.inputFieldInsets;
    self.fieldBackground.frame = CGRectMake(inputFieldInsets.left, inputFieldInsets.top, bounds.size.width - inputFieldInsets.left - inputFieldInsets.right, bounds.size.height - inputFieldInsets.top - inputFieldInsets.bottom);
    
    CGRect inputFieldClippingFrame = self.fieldBackground.frame;
    self.inputFieldClippingContainer.frame = inputFieldClippingFrame;
    
    self.micButton.frame = CGRectMake(0, bounds.size.height - baseHeight, 40, baseHeight);
    
    self.faceButton.frame = CGRectMake(bounds.size.width - 80, bounds.size.height - baseHeight, 40, baseHeight);
    
    self.attachButton.frame = CGRectMake(bounds.size.width - 40, bounds.size.height - baseHeight, 40, baseHeight);
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

- (void)clearInputField
{
    self.inputField.internalTextView.text = nil;
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
    
    id<MMChatInputTextPanelDelegate> delegate = (id<MMChatInputTextPanelDelegate>)self.delegate;
    if ([delegate respondsToSelector:@selector(inputPanel:willChangeHeight:duration:animationCurve:)]) {
        [delegate inputPanel:self willChangeHeight:inputContainerHeight duration:0.3 animationCurve:0];
    }
}

- (void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView
{
    id<MMChatInputTextPanelDelegate> delegate = (id<MMChatInputTextPanelDelegate>)self.delegate;
    if ([delegate respondsToSelector:@selector(didInputTextPanelStartInputting:)]) {
        [delegate didInputTextPanelStartInputting:self];
    }
}

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (growingTextView != self.inputField) {
        return YES;
    }
    
    if ([text isEqualToString:@"\n"]) {
        NSString *str = [self.inputField.internalTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (str.length > 0) {
            id<MMChatInputTextPanelDelegate> delegate = (id<MMChatInputTextPanelDelegate>)self.delegate;
            if ([delegate respondsToSelector:@selector(inputTextPanel:requestSendText:)]) {
                [delegate inputTextPanel:self requestSendText:str];
            }
            [self clearInputField];
        }
        return NO;
    }
    
    return YES;
}

#pragma mark - Private

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
    
    CGRect inputFieldClippingFrame = CGRectMake(inputFieldInsets.left, inputFieldInsets.top, self.parentSize.width - inputFieldInsets.left - inputFieldInsets.right, 0);
    
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
