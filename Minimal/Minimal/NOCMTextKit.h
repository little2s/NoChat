//
//  NOCMTextKit.h
//  Minimal
//
//  Created by little2s on 2017/1/19.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

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

@class NOCMTextPosition;
@class NOCMTextRange;
@class NOCMTextSelectionRect;

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

- (NSUInteger)lineIndexForRow:(NSUInteger)row;
- (NSUInteger)lineCountForRow:(NSUInteger)row;
- (NSUInteger)rowIndexForLine:(NSUInteger)line;
- (NSUInteger)lineIndexForPoint:(CGPoint)point;
- (NSUInteger)closestLineIndexForPoint:(CGPoint)point;
- (CGFloat)offsetForTextPosition:(NSUInteger)position lineIndex:(NSUInteger)lineIndex;
- (NSUInteger)textPositionForPoint:(CGPoint)point lineIndex:(NSUInteger)lineIndex;
- (nullable NOCMTextPosition *)closestPositionToPoint:(CGPoint)point;
- (nullable NOCMTextPosition *)positionForPoint:(CGPoint)point oldPosition:(NOCMTextPosition *)oldPosition otherPosition:(NOCMTextPosition *)otherPosition;
- (nullable NOCMTextRange *)textRangeAtPoint:(CGPoint)point;
- (nullable NOCMTextRange *)closestTextRangeAtPoint:(CGPoint)point;
- (nullable NOCMTextRange *)textRangeByExtendingPosition:(NOCMTextPosition *)position;
- (nullable NOCMTextRange *)textRangeByExtendingPosition:(NOCMTextPosition *)position inDirection:(UITextLayoutDirection)direction offset:(NSInteger)offset;
- (NSUInteger)lineIndexForPosition:(NOCMTextPosition *)position;
- (CGPoint)linePositionForPosition:(NOCMTextPosition *)position;
- (CGRect)caretRectForPosition:(NOCMTextPosition *)position;
- (CGRect)firstRectForRange:(NOCMTextRange *)range;
- (CGRect)rectForRange:(NOCMTextRange *)range;
- (NSArray<NOCMTextSelectionRect *> *)selectionRectsForRange:(NOCMTextRange *)range;
- (NSArray<NOCMTextSelectionRect *> *)selectionRectsWithoutStartAndEndForRange:(NOCMTextRange *)range;
- (NSArray<NOCMTextSelectionRect *> *)selectionRectsWithOnlyStartAndEndForRange:(NOCMTextRange *)range;

- (void)drawInContext:(nullable CGContextRef)context size:(CGSize)size point:(CGPoint)point view:(nullable UIView *)view layer:(nullable CALayer *)layer cancel:(nullable BOOL (^)(void))cancel;

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

@interface NOCMTextSelectionRect : UITextSelectionRect <NSCopying>

@property (nonatomic, readwrite) CGRect rect;
@property (nonatomic, readwrite) UITextWritingDirection writingDirection;
@property (nonatomic, readwrite) BOOL containsStart;
@property (nonatomic, readwrite) BOOL containsEnd;

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

typedef void(^NOCMTextAction)(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect);

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

