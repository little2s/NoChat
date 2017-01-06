//
//  NOCMTextLabel.h
//  NoChat-Example
//
//  Created by little2s on 2016/12/25.
//  Copyright © 2016年 little2s. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NOCMTextLayout;
@class NOCMTextContainer;
@class NOCMTextRange;
@class NOCMTextAttachment;

typedef void(^NOCMTextAction)(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect);

@interface NOCMTextLabel : UIView

@property (nonatomic, strong) NOCMTextLayout *textLayout;

@property (nonatomic, copy) NOCMTextAction tapAction;
@property (nonatomic, copy) NOCMTextAction longPressAction;

@end

@interface NOCMTextLayout : NSObject <NSCopying>

@property (nonatomic, strong) NOCMTextContainer *container;
@property (nonatomic, strong, readonly) NSAttributedString *text;
@property (nonatomic, strong, readonly) NSArray<NOCMTextAttachment *> *attachments;
@property (nonatomic, strong, readonly) NSSet *attachmentContentsSet;
@property (nonatomic, readonly) CGSize textBoundingSize;

+ (instancetype)layoutWithContainer:(NOCMTextContainer *)container text:(NSAttributedString *)text;

- (NOCMTextRange *)textRangeAtPoint:(CGPoint)point;
- (CGRect)rectForRange:(NOCMTextRange *)range;

- (void)drawInContext:(CGContextRef)context size:(CGSize)size point:(CGPoint)point view:(UIView *)view layer:(CALayer *)layer cancel:(BOOL (^)(void))cancel;

@end

@protocol NOCMTextLinePositionModifier <NSObject, NSCopying>

@end

@interface NOCMTextContainer : NSObject <NSCopying>

@property (nonatomic, assign) CGSize size;
@property (nonatomic, copy) id<NOCMTextLinePositionModifier> linePositionModifier;

+ (instancetype)containerWithSize:(CGSize)size;

@end

@interface NOCMTextLinePositionModifier : NSObject <NOCMTextLinePositionModifier>

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, assign) CGFloat paddingTop;
@property (nonatomic, assign) CGFloat paddingBottom;
@property (nonatomic, assign) CGFloat lineHeightMultiple;

- (CGFloat)heightForLineCount:(NSUInteger)lineCount;

@end

@interface NOCMTextHighlight : NSObject

@end

typedef NS_ENUM(NSInteger, NOCMTextAffinity) {
    NOCMTextAffinityForward  = 0,
    NOCMTextAffinityBackward = 1
};

@interface NOCMTextPosition : NSObject

+ (instancetype)positionWithOffset:(NSInteger)offset;
+ (instancetype)positionWithOffset:(NSInteger)offset affinity:(NOCMTextAffinity)affinity;

@end

@interface NOCMTextRange : NSObject

+ (instancetype)rangeWithStart:(NOCMTextPosition *)start end:(NOCMTextPosition *)end;

- (NSRange)asRange;

@end

@interface NOCMTextAttachment : NSObject

@property (nonnull, strong) id content;

@end
