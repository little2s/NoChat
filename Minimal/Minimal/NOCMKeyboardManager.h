//
//  NOCMKeyboardManager.h
//  NoChat-Example
//
//  Created by little2s on 2016/12/25.
//  Copyright © 2016年 little2s. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NOCMKeyboardInfo;
@class NOCMKeyboardManager;

typedef void(^NOCMKeyboardAppearHandler)(NSInteger appearPostIndex, CGFloat keyboardHeight, CGFloat keyboardHeightIncrement);
typedef void(^NOCMKeyboardDisappearHandler)(CGFloat keyboardHeight);
typedef void(^NOCMKeyboardInfoHandler)(NOCMKeyboardManager *manager, NOCMKeyboardInfo *keyboardInfo);

typedef NS_ENUM(NSUInteger, NOCMKeyboardAction) {
    NOCMKeyboardShow,
    NOCMKeyboardHide
};

@interface NOCMKeyboardInfo : NSObject

@property (nonatomic, assign) NSTimeInterval animationDuration;
@property (nonatomic, assign) NSUInteger animationCurve;
@property (nonatomic, assign) CGRect frameBegin;
@property (nonatomic, assign) CGRect frameEnd;
@property (nonatomic, assign, readonly) CGFloat height;
@property (nonatomic, assign) CGFloat heightIncrement;
@property (nonatomic, assign) NOCMKeyboardAction action;
@property (nonatomic, assign, getter=isSameAction) BOOL sameAction;

@end

@interface NOCMKeyboardManager : NSObject

@property (nonatomic, assign, getter=isKeyboardObserveEnabled) BOOL keyboardObserveEnabled;

@property (nonatomic, copy) NOCMKeyboardAppearHandler animateWhenKeyboardAppear;
@property (nonatomic, copy) NOCMKeyboardDisappearHandler animateWhenKeyboardDisappear;
@property (nonatomic, copy) NOCMKeyboardInfoHandler postKeyboardInfo;

@end
