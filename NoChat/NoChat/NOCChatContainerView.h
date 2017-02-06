//
//  NOCChatView.h
//  NoChat
//
//  Created by little2s on 2017/2/1.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NOCChatContainerView : UIView

@property (nullable, nonatomic, copy) void (^layoutForSize)(CGSize size);

@end

NS_ASSUME_NONNULL_END
