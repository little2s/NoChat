//
//  NOCGrowingTextView.h
//  NoChat-Example
//
//  Created by little2s on 2016/12/25.
//  Copyright © 2016年 little2s. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NOCGrowingTextView;

@protocol NOCGrowingTextViewDelegate <NSObject>

@optional
- (void)growingTextViewDidBeginEditing:(NOCGrowingTextView *)textView;
- (void)growingTextView:(NOCGrowingTextView *)textView didUpdateHeight:(CGFloat)height;

@end

@interface NOCGrowingTextView : UITextView

@property (nonatomic, weak) id<NOCGrowingTextViewDelegate> growingDelegate;

@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) UIColor *placeholderColor;
@property (nonatomic, strong) UIFont *plcaeholderFont;

- (void)resetContentSizeAndOffset;
- (void)clear;

@end

@interface NOCGrowingTextView (NOCStyle)

+ (UIEdgeInsets)textInsets;
+ (CGFloat)maximumHeight;
+ (CGFloat)minimumHeight;

@end
