//
//  NOCMTextLabel.h
//  NoChat-Example
//
//  Created by little2s on 2016/12/25.
//  Copyright © 2016年 little2s. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NOCMTextKit.h"

@class NOCMTextLayout;

NS_ASSUME_NONNULL_BEGIN

@interface NOCMTextLabel : UIView

@property (nullable, nonatomic, strong) NOCMTextLayout *textLayout;

@property (nullable, nonatomic, copy) NOCMTextAction textTapAction;
@property (nullable, nonatomic, copy) NOCMTextAction textLongPressAction;

@property (nullable, nonatomic, copy) NOCMTextAction highlightTapAction;
@property (nullable, nonatomic, copy) NOCMTextAction highlightLongPressAction;

@end

NS_ASSUME_NONNULL_END
