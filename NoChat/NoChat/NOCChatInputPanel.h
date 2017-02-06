//
//  NOCChatInputPanel.h
//  NoChat
//
//  Created by little2s on 2017/2/1.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NOCChatInputPanel;

NS_ASSUME_NONNULL_BEGIN

@protocol NOCChatInputPanelDelegate <NSObject>

@required
- (void)inputPanel:(NOCChatInputPanel *)inputPanel willChangeHeight:(CGFloat)height duration:(NSTimeInterval)duration animationCurve:(int)animationCurve;

@end

@interface NOCChatInputPanel : UIView

@property (nullable, nonatomic, weak) id<NOCChatInputPanelDelegate> delegate;

- (void)endInputting:(BOOL)animated;
- (void)adjustForSize:(CGSize)size keyboardHeight:(CGFloat)keyboardHeight duration:(NSTimeInterval)duration animationCurve:(int)animationCurve;
- (void)changeToSize:(CGSize)size keyboardHeight:(CGFloat)keyboardHeight duration:(NSTimeInterval)duration;

@end

NS_ASSUME_NONNULL_END
