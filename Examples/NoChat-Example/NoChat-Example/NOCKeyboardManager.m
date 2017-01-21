//
//  NOCKeyboardManager.m
//  NoChat-Example
//
//  Created by little2s on 2016/12/25.
//  Copyright © 2016年 little2s. All rights reserved.
//

#import "NOCKeyboardManager.h"

@implementation NOCKeyboardInfo

- (CGFloat)height
{
    return self.frameEnd.size.height;
}

@end

@interface NOCKeyboardManager ()

@property (nonatomic, strong) NSNotificationCenter *keyboardObserver;

@property (nonatomic, assign) NSInteger appearPostIndex;
@property (nonatomic, strong) NOCKeyboardInfo *keyboardInfo;


@end

@implementation NOCKeyboardManager

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setKeyboardObserver:(NSNotificationCenter *)keyboardObserver
{
    if (_keyboardObserver) {
        [_keyboardObserver removeObserver:self];
    }
    
    [keyboardObserver addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [keyboardObserver addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [keyboardObserver addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [keyboardObserver addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)setKeyboardObserveEnabled:(BOOL)keyboardObserveEnabled
{
    if (keyboardObserveEnabled != _keyboardObserveEnabled) {
        self.keyboardObserver = keyboardObserveEnabled ? [NSNotificationCenter defaultCenter] : nil;
    }
    _keyboardObserveEnabled = keyboardObserveEnabled;
}

- (void)setKeyboardInfo:(NOCKeyboardInfo *)keyboardInfo
{
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        return;
    }
    
    if (!keyboardInfo.isSameAction || keyboardInfo.heightIncrement != 0) {
        NSTimeInterval duration = keyboardInfo.animationDuration;
        NSUInteger curve = keyboardInfo.animationCurve;
        UIViewAnimationOptions options = curve << 16 | UIViewAnimationOptionBeginFromCurrentState;
        [UIView animateWithDuration:duration delay:0 options:options animations:^{
            switch (keyboardInfo.action) {
                case NOCKeyboardShow: {
                    if (self.animateWhenKeyboardAppear) {
                        self.animateWhenKeyboardAppear(self.appearPostIndex, keyboardInfo.height, keyboardInfo.heightIncrement);
                        self.appearPostIndex += 1;
                    }
                    break;
                }
                case NOCKeyboardHide: {
                    if (self.animateWhenKeyboardDisappear) {
                        self.animateWhenKeyboardDisappear(keyboardInfo.height);
                    }
                    break;
                }
            }
        } completion:nil];
        
        if (self.postKeyboardInfo) {
            self.postKeyboardInfo(self, keyboardInfo);
        }
    }
    
    _keyboardInfo = keyboardInfo;
}

- (void)setAnimateWhenKeyboardAppear:(NOCKeyboardAppearHandler)animateWhenKeyboardAppear
{
    _animateWhenKeyboardAppear = [animateWhenKeyboardAppear copy];
    self.keyboardObserveEnabled = YES;
}

- (void)setAnimateWhenKeyboardDisappear:(NOCKeyboardDisappearHandler)animateWhenKeyboardDisappear
{
    _animateWhenKeyboardDisappear = [animateWhenKeyboardDisappear copy];
    self.keyboardObserveEnabled = YES;
}

- (void)setPostKeyboardInfo:(NOCKeyboardInfoHandler)postKeyboardInfo
{
    _postKeyboardInfo = [postKeyboardInfo copy];
    self.keyboardObserveEnabled = YES;
}

#pragma mark - Private

- (void)keyboardWillShow:(NSNotification *)notification
{
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        return;
    }
    [self handleKeyboard:notification action:NOCKeyboardShow];
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        return;
    }
    if (self.keyboardInfo && self.keyboardInfo.action == NOCKeyboardShow) {
        [self handleKeyboard:notification action:NOCKeyboardShow];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        return;
    }
    [self handleKeyboard:notification action:NOCKeyboardHide];
}

- (void)keyboardDidHide:(NSNotification *)notification
{
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        return;
    }
    self.keyboardInfo = nil;
}

- (void)handleKeyboard:(NSNotification *)notification action:(NOCKeyboardAction)action
{
    NSDictionary *userInfo = notification.userInfo;
    if (!userInfo) {
        return;
    }
    
    NSTimeInterval animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSUInteger animationCurve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    CGRect frameBegin = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect frameEnd = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat currentHeight = frameEnd.size.height;
    CGFloat previousHeight = self.keyboardInfo ? self.keyboardInfo.height : 0;
    CGFloat heightIncrement = currentHeight - previousHeight;
    
    BOOL sameAction;
    if (self.keyboardInfo) {
        sameAction = (action == self.keyboardInfo.action);;
    } else {
        sameAction = NO;
    }
    
    NOCKeyboardInfo *keyboardInfo = [[NOCKeyboardInfo alloc] init];
    keyboardInfo.animationDuration = animationDuration;
    keyboardInfo.animationCurve = animationCurve;
    keyboardInfo.frameBegin = frameBegin;
    keyboardInfo.frameEnd = frameEnd;
    keyboardInfo.heightIncrement = heightIncrement;
    keyboardInfo.action = action;
    keyboardInfo.sameAction = sameAction;
    
    self.keyboardInfo = keyboardInfo;
}

@end
