//
//  UIFont+NOCMinimal.h
//  NoChat-Example
//
//  Created by little2s on 2016/12/26.
//  Copyright © 2016年 little2s. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIFont (NOCMinimal)

+ (UIFont *)nocm_mediumSystemFontOfSize:(CGFloat)fontSize;

- (nullable CTFontRef)nocm_CTFontRef CF_RETURNS_RETAINED;

@end

NS_ASSUME_NONNULL_END
