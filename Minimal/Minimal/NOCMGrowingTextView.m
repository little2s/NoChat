//
//  NOCMGrowingTextView.m
//  NoChat-Example
//
//  Created by little2s on 2016/12/25.
//  Copyright © 2016年 little2s. All rights reserved.
//

#import "NOCMGrowingTextView.h"

@interface NOCMGrowingTextView () <UITextViewDelegate>

@property (nonatomic, strong) UITextView *placeholderView;

@end

@implementation NOCMGrowingTextView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.textContainerInset = [NOCMGrowingTextView textInsets];
        self.textContainer.lineFragmentPadding = 0;
        self.layoutManager.allowsNonContiguousLayout = false;
        self.scrollsToTop = false;
        self.delegate = self;
        [self configurePlaceholder];
        [self updatePlaceholderVisibility];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.placeholderView.frame = self.bounds;
}

- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated
{
    
}

#pragma mark - Public

- (void)setPlaceholder:(NSString *)placeholder
{
    self.placeholderView.text = placeholder;
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor
{
    self.placeholderView.textColor = placeholderColor;
}

- (void)setPlcaeholderFont:(UIFont *)plcaeholderFont
{
    self.placeholderView.font = plcaeholderFont;
}

- (void)resetContentSizeAndOffset
{
    [self layoutIfNeeded];
    CGFloat textViewHeight = MAX(MIN(self.contentSize.height, [NOCMGrowingTextView maximumHeight]), [NOCMGrowingTextView minimumHeight]);
    if ([self.growingDelegate respondsToSelector:@selector(growingTextView:didUpdateHeight:)]) {
        [self.growingDelegate growingTextView:self didUpdateHeight:textViewHeight];
    }
    
    if (self.selectedTextRange) {
        CGRect caretRect = [self caretRectForPosition:self.selectedTextRange.end];
        CGFloat caretHeight = self.textContainerInset.bottom + caretRect.size.height;
        [self letRectVisible:CGRectMake(caretRect.origin.x, caretRect.origin.y, caretRect.size.width, caretHeight)];
    }
}

- (void)clear
{
    self.text = nil;
    [self resetContentSizeAndOffset];
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self resetContentSizeAndOffset];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self hidePlaceholder];
    if ([self.growingDelegate respondsToSelector:@selector(growingTextViewDidBeginEditing:)]) {
        [self.growingDelegate growingTextViewDidBeginEditing:self];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self updatePlaceholderVisibility];
}

#pragma mark - Private

- (void)configurePlaceholder
{
    self.placeholderView = [[UITextView alloc] init];
    self.placeholderView.translatesAutoresizingMaskIntoConstraints = NO;
    self.placeholderView.editable = NO;
    self.placeholderView.selectable = NO;
    self.placeholderView.userInteractionEnabled = NO;
    self.placeholderView.textContainerInset = self.textContainerInset;
    self.placeholderView.textContainer.lineFragmentPadding = 0;
    self.placeholderView.layoutManager.allowsNonContiguousLayout = NO;
    self.placeholderView.scrollsToTop = NO;
    self.placeholderView.backgroundColor = [UIColor clearColor];
}

- (void)updatePlaceholderVisibility
{
    if (!self.hasText) {
        [self showPlaceholder];
    } else {
        [self hidePlaceholder];
    }
}

- (void)showPlaceholder
{
    [self addSubview:self.placeholderView];
}

- (void)hidePlaceholder
{
    [self.placeholderView removeFromSuperview];
}

- (void)letRectVisible:(CGRect)rect
{
    if (self.contentSize.height < [NOCMGrowingTextView maximumHeight]) {
        return;
    }
    [super scrollRectToVisible:rect animated:YES];
}

@end

@implementation NOCMGrowingTextView (NOCMStyle)

+ (UIEdgeInsets)textInsets
{
    return UIEdgeInsetsMake(4.5, 8, 3.5, 8);
}

+ (CGFloat)maximumHeight
{
    return 100;
}

+ (CGFloat)minimumHeight
{
    return 28;
}

@end
