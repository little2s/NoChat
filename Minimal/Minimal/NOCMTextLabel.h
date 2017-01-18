//
//  NOCMTextLabel.h
//  NoChat-Example
//
//  Created by little2s on 2016/12/25.
//  Copyright © 2016年 little2s. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>

@class NOCMTextLayout;

NS_ASSUME_NONNULL_BEGIN

typedef void(^NOCMTextAction)(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect);

@interface NOCMTextLabel : UIView

@property (nullable, nonatomic, strong) NOCMTextLayout *textLayout;

@property (nullable, nonatomic, copy) NOCMTextAction tapAction;
@property (nullable, nonatomic, copy) NOCMTextAction longPressAction;

@end

@protocol NOCMTextLinePositionModifier;

extern const CGSize NOCMTextContainerMaxSize;

typedef NS_ENUM(NSUInteger, NOCMTextTruncationType) {
    NOCMTextTruncationTypeNone = 0,
    NOCMTextTruncationTypeStart = 1,
    NOCMTextTruncationTypeEnd = 0,
    NOCMTextTruncationTypeMiddle = 3
};

@interface NOCMTextContainer : NSObject <NSCopying>

@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) UIEdgeInsets insets;
@property (nullable, nonatomic, copy) UIBezierPath *path;
@property (nullable, nonatomic, copy) NSArray<UIBezierPath *> *exclusionPaths;
@property (nonatomic, assign) CGFloat pathLineWidth;
@property (nonatomic, assign, getter=isPathFillEvenOdd) BOOL pathFillEvenOdd;
@property (nonatomic, assign) NSUInteger maximumNumberOfRows;
@property (nonatomic, assign) NOCMTextTruncationType truncationType;
@property (nullable, nonatomic, copy) NSAttributedString *truncationToken;
@property (nullable, nonatomic, copy) id<NOCMTextLinePositionModifier> linePositionModifier;

+ (instancetype)containerWithSize:(CGSize)size;
+ (instancetype)containerWithSize:(CGSize)size insets:(UIEdgeInsets)insets;
+ (instancetype)containerWithPath:(nullable UIBezierPath *)path;

@end

@class NOCMTextLine;

@protocol NOCMTextLinePositionModifier <NSObject, NSCopying>

@required
- (void)modifyLines:(NSArray<NOCMTextLine *> *)lines fromText:(NSAttributedString *)text inContainer:(NOCMTextContainer *)container;

@end

@interface NOCMTextLinePositionSimpleModifier : NSObject <NOCMTextLinePositionModifier>

@property (nonatomic, assign) CGFloat fixedLineHeight;

@end

@class NOCMTextAttachment;

@interface NOCMTextLine : NSObject

@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, assign) NSUInteger row;

@property (nonatomic, readonly, assign) CTLineRef CTLine;
@property (nonatomic, readonly, assign) NSRange range;

@property (nonatomic, readonly, assign) CGRect bounds;
@property (nonatomic, readonly, assign) CGSize size;
@property (nonatomic, readonly, assign) CGFloat width;
@property (nonatomic, readonly, assign) CGFloat height;
@property (nonatomic, readonly, assign) CGFloat top;
@property (nonatomic, readonly, assign) CGFloat bottom;
@property (nonatomic, readonly, assign) CGFloat left;
@property (nonatomic, readonly, assign) CGFloat right;

@property (nonatomic, assign) CGPoint position;
@property (nonatomic, readonly, assign) CGFloat ascent;
@property (nonatomic, readonly, assign) CGFloat descent;
@property (nonatomic, readonly, assign) CGFloat leading;
@property (nonatomic, readonly, assign) CGFloat lineWidth;
@property (nonatomic, readonly, assign) CGFloat trailingWhitespaceWidth;

@property (nullable, nonatomic, readonly) NSArray<NOCMTextAttachment *> *attachments;
@property (nullable, nonatomic, readonly) NSArray<NSValue *> *attachmentRanges;
@property (nullable, nonatomic, readonly) NSArray<NSValue *> *attachmentRects;

+ (instancetype)lineWithCTLine:(CTLineRef)CTLine position:(CGPoint)position;

@end

@class NOCMTextRange;

@interface NOCMTextLayout : NSObject <NSCopying>

@property (nonatomic, readonly, strong) NOCMTextContainer *container;
@property (nonatomic, readonly, strong) NSAttributedString *text;
@property (nonatomic, readonly, assign) NSRange range;

@property (nonatomic, readonly, assign) CTFramesetterRef frameSetter;
@property (nonatomic, readonly, assign) CTFrameRef frame;
@property (nonatomic, readonly, strong) NSArray<NOCMTextLine *> *lines;
@property (nullable, nonatomic, readonly, strong) NOCMTextLine *truncatedLine;
@property (nullable, nonatomic, readonly, strong) NSArray<NOCMTextAttachment *> *attachments;
@property (nullable, nonatomic, readonly, strong) NSArray<NSValue *> *attachmentRanges;
@property (nullable, nonatomic, readonly, strong) NSArray<NSValue *> *attachmentRects;
@property (nullable, nonatomic, readonly, strong) NSSet *attachmentContentsSet;
@property (nonatomic, readonly, assign) NSUInteger rowCount;
@property (nonatomic, readonly, assign) NSRange visibleRange;
@property (nonatomic, readonly, assign) CGRect textBoundingRect;
@property (nonatomic, readonly, assign) CGSize textBoundingSize;

@property (nonatomic, readonly, assign) BOOL containsHighlight;
@property (nonatomic, readonly, assign) BOOL needDrawBlockBorder;
@property (nonatomic, readonly, assign) BOOL needDrawBackgroundBorder;
@property (nonatomic, readonly, assign) BOOL needDrawShadow;
@property (nonatomic, readonly, assign) BOOL needDrawUnderline;
@property (nonatomic, readonly, assign) BOOL needDrawText;
@property (nonatomic, readonly, assign) BOOL needDrawAttachment;
@property (nonatomic, readonly, assign) BOOL needDrawInnerShadow;
@property (nonatomic, readonly, assign) BOOL needDrawStrikethrough;
@property (nonatomic, readonly, assign) BOOL needDrawBorder;

+ (nullable instancetype)layoutWithContainer:(NOCMTextContainer *)container text:(NSAttributedString *)text;
+ (nullable instancetype)layoutWithContainer:(NOCMTextContainer *)container text:(NSAttributedString *)text range:(NSRange)range;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (nullable NOCMTextRange *)textRangeAtPoint:(CGPoint)point;
- (CGRect)rectForRange:(NOCMTextRange *)range;

- (void)drawInContext:(CGContextRef)context size:(CGSize)size point:(CGPoint)point view:(UIView *)view layer:(CALayer *)layer cancel:(BOOL (^)(void))cancel;

@end

typedef NS_ENUM(NSInteger, NOCMTextAffinity) {
    NOCMTextAffinityForward  = 0,
    NOCMTextAffinityBackward = 1
};

@interface NOCMTextPosition : UITextPosition <NSCopying>

@property (nonatomic, readonly, assign) NSInteger offset;
@property (nonatomic, readonly, assign) NOCMTextAffinity affinity;

+ (instancetype)positionWithOffset:(NSInteger)offset;
+ (instancetype)positionWithOffset:(NSInteger)offset affinity:(NOCMTextAffinity)affinity;

- (NSComparisonResult)compare:(id)otherPosition;

@end

@interface NOCMTextRange : UITextRange <NSCopying>

@property (nonatomic, readonly, assign) NOCMTextPosition *start;
@property (nonatomic, readonly, assign) NOCMTextPosition *end;
@property (nonatomic, readonly, assign, getter=isEmpty) BOOL empty;

+ (instancetype)rangeWithRange:(NSRange)range;
+ (instancetype)rangeWithRange:(NSRange)range affinity:(NOCMTextAffinity) affinity;
+ (instancetype)rangeWithStart:(NOCMTextPosition *)start end:(NOCMTextPosition *)end;
+ (instancetype)defaultRange; ///< <{0,0} Forward>

- (NSRange)asRange;

@end

UIKIT_EXTERN NSString *const NOCMTextBackedStringAttributeName;
UIKIT_EXTERN NSString *const NOCMTextBindingAttributeName;
UIKIT_EXTERN NSString *const NOCMTextShadowAttributeName;
UIKIT_EXTERN NSString *const NOCMTextInnerShadowAttributeName;
UIKIT_EXTERN NSString *const NOCMTextUnderlineAttributeName;
UIKIT_EXTERN NSString *const NOCMTextStrikethroughAttributeName;
UIKIT_EXTERN NSString *const NOCMTextBorderAttributeName;
UIKIT_EXTERN NSString *const NOCMTextBackgroundBorderAttributeName;
UIKIT_EXTERN NSString *const NOCMTextBlockBorderAttributeName;
UIKIT_EXTERN NSString *const NOCMTextAttachmentAttributeName;
UIKIT_EXTERN NSString *const NOCMTextHighlightAttributeName;
UIKIT_EXTERN NSString *const NOCMTextGlyphTransformAttributeName;

UIKIT_EXTERN NSString *const NOCMTextAttachmentToken;
UIKIT_EXTERN NSString *const NOCMTextTruncationToken;

typedef NS_OPTIONS (NSInteger, NOCMTextLineStyle) {
    NOCMTextLineStyleNone       = 0x00, ///< (        ) Do not draw a line (Default).
    NOCMTextLineStyleSingle     = 0x01, ///< (──────) Draw a single line.
};

@interface NOCMTextBorder : NSObject <NSCopying>

@property (nonatomic, assign) NOCMTextLineStyle lineStyle;
@property (nonatomic, assign) CGFloat strokeWidth;
@property (nullable, nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, assign) CGLineJoin lineJoin;
@property (nonatomic, assign) UIEdgeInsets insets;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nullable, nonatomic, strong) UIColor *fillColor;

+ (instancetype)borderWithLineStyle:(NOCMTextLineStyle)lineStyle lineWidth:(CGFloat)width strokeColor:(nullable UIColor *)color;
+ (instancetype)borderWithFillColor:(nullable UIColor *)color cornerRadius:(CGFloat)cornerRadius;

@end

@interface NOCMTextAttachment : NSObject <NSCopying>

@property (nullable, nonatomic, strong) id content;
@property (nonatomic, assign) UIViewContentMode contentMode;
@property (nonatomic, assign) UIEdgeInsets contentInsets;
@property (nullable, nonatomic, strong) NSDictionary *userInfo;

+ (instancetype)attachmentWithContent:(nullable id)content;

@end

@interface NOCMTextHighlight : NSObject <NSCopying>

@property (nullable, nonatomic, copy) NSDictionary<NSString *, id> *attributes;
@property (nullable, nonatomic, copy) NSDictionary *userInfo;

+ (instancetype)highlightWithAttributes:(nullable NSDictionary<NSString *, id> *)attributes;
+ (instancetype)highlightWithBackgroundColor:(nullable UIColor *)color;

- (void)setBackgroundBorder:(nullable NOCMTextBorder *)border;

@end

NS_ASSUME_NONNULL_END
