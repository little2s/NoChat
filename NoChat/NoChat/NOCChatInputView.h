//
//  NOCChatInputView.h
//  NoChat-Example
//
//  Created by little2s on 2016/12/24.
//  Copyright © 2016年 little2s. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NOCChatInputView;

NS_ASSUME_NONNULL_BEGIN

@protocol NOCChatInputViewDelegate <NSObject>

@required
- (void)chatInputView:(NOCChatInputView *)chatInputView didUpdateHeight:(CGFloat)newHeight oldHeight:(CGFloat)oldHeight;

@end

@interface NOCChatInputView : UIView

@property (nullable, nonatomic, weak) id<NOCChatInputViewDelegate> delegate;

- (void)endInputting:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
