//
//  NOCMTextLabel.h
//  NoChat-Example
//
//  Created by little2s on 2016/12/25.
//  Copyright © 2016年 little2s. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

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
@property (nonatomic, assign, getter=isVerticalForm) BOOL verticalForm;
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

@class NOCMTextRunGlyphRange;
@class NOCMTextAttachment;

@interface NOCMTextLine : NSObject

@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, assign) NSUInteger row;
@property (nullable, nonatomic, strong) NSArray<NSArray<NOCMTextRunGlyphRange *> *> *verticalRotateRange;

@property (nonatomic, readonly, assign) CTLineRef CTLine;
@property (nonatomic, readonly, assign) NSRange range;
@property (nonatomic, readonly, assign) BOOL vertical;

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

+ (instancetype)lineWithCTLine:(CTLineRef)CTLine position:(CGPoint)position vertical:(BOOL)isVertical;

@end

typedef NS_ENUM(NSUInteger, NOCMTextRunGlyphDrawMode) {
    NOCMTextRunGlyphDrawModeHorizontal = 0,
    NOCMTextRunGlyphDrawModeVerticalRotate = 1,
    NOCMTextRunGlyphDrawModeVerticalRotateMove = 2,
};

@interface NOCMTextRunGlyphRange : NSObject

@property (nonatomic, assign) NSRange glyphRangeInRun;
@property (nonatomic, assign) NOCMTextRunGlyphDrawMode drawMode;

+ (instancetype)rangeWithRange:(NSRange)range drawMode:(NOCMTextRunGlyphDrawMode)mode;

@end

NS_ASSUME_NONNULL_END

@class NOCMTextRange;

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

extern NSString *NOCMTextAttachmentAttributeName;

@interface NOCMTextAttachment : NSObject

@property (nonnull, strong) id content;

@end
