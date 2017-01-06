//
//  NOCMGrowingTextView.h
//  NoChat-Example
//
//  Created by little2s on 2016/12/25.
//  Copyright © 2016年 little2s. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NOCMGrowingTextView;

@protocol NOCMGrowingTextViewDelegate <NSObject>

@optional
- (void)growingTextViewDidBeginEditing:(NOCMGrowingTextView *)textView;
- (void)growingTextView:(NOCMGrowingTextView *)textView didUpdateHeight:(CGFloat)height;

@end

@interface NOCMGrowingTextView : UITextView

@property (nonatomic, weak) id<NOCMGrowingTextViewDelegate> growingDelegate;

@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) UIColor *placeholderColor;
@property (nonatomic, strong) UIFont *plcaeholderFont;

- (void)resetContentSizeAndOffset;
- (void)clear;

@end

@interface NOCMGrowingTextView (NOCMStyle)

+ (UIEdgeInsets)textInsets;
+ (CGFloat)maximumHeight;
+ (CGFloat)minimumHeight;

@end
