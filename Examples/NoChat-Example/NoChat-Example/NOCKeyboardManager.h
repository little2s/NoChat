//
//  NOCKeyboardManager.h
//  NoChat-Example
//
//  Created by little2s on 2016/12/25.
//  Copyright © 2016年 little2s. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NOCKeyboardInfo;
@class NOCKeyboardManager;

typedef void(^NOCKeyboardAppearHandler)(NSInteger appearPostIndex, CGFloat keyboardHeight, CGFloat keyboardHeightIncrement);
typedef void(^NOCKeyboardDisappearHandler)(CGFloat keyboardHeight);
typedef void(^NOCKeyboardInfoHandler)(NOCKeyboardManager *manager, NOCKeyboardInfo *keyboardInfo);

typedef NS_ENUM(NSUInteger, NOCKeyboardAction) {
    NOCKeyboardShow,
    NOCKeyboardHide
};

@interface NOCKeyboardInfo : NSObject

@property (nonatomic, assign) NSTimeInterval animationDuration;
@property (nonatomic, assign) NSUInteger animationCurve;
@property (nonatomic, assign) CGRect frameBegin;
@property (nonatomic, assign) CGRect frameEnd;
@property (nonatomic, assign, readonly) CGFloat height;
@property (nonatomic, assign) CGFloat heightIncrement;
@property (nonatomic, assign) NOCKeyboardAction action;
@property (nonatomic, assign, getter=isSameAction) BOOL sameAction;

@end

@interface NOCKeyboardManager : NSObject

@property (nonatomic, assign, getter=isKeyboardObserveEnabled) BOOL keyboardObserveEnabled;

@property (nonatomic, copy) NOCKeyboardAppearHandler animateWhenKeyboardAppear;
@property (nonatomic, copy) NOCKeyboardDisappearHandler animateWhenKeyboardDisappear;
@property (nonatomic, copy) NOCKeyboardInfoHandler postKeyboardInfo;

@end
