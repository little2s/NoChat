//
//  NOCMTextKit.m
//  Minimal
//
//  Created by little2s on 2017/1/19.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import "NOCMTextKit.h"
#import "NSAttributedString+NOCMinimal.h"
#import "UIFont+NOCMinimal.h"

#pragma mark - NOCMTextContainer

const CGSize NOCMTextContainerMaxSize = (CGSize){0x100000, 0x100000};

static inline CGSize NOCMTextClipCGSize(CGSize size)
{
    if (size.width > NOCMTextContainerMaxSize.width) { size.width = NOCMTextContainerMaxSize.width; }
    if (size.height > NOCMTextContainerMaxSize.height) { size.height = NOCMTextContainerMaxSize.height; }
    return size;
}

@implementation NOCMTextContainer {
    @package
    BOOL _readonly;
    dispatch_semaphore_t _lock;
    
    CGSize _size;
    UIEdgeInsets _insets;
    UIBezierPath *_path;
    NSArray *_exclusionPaths;
    BOOL _pathFillEvenOdd;
    CGFloat _pathLineWidth;
    NSUInteger _maximumNumberOfRows;
    NOCMTextTruncationType _truncationType;
    NSAttributedString *_truncationToken;
    id<NOCMTextLinePositionModifier> _linePositionModifier;
}

+ (instancetype)containerWithSize:(CGSize)size
{
    return [self containerWithSize:size insets:UIEdgeInsetsZero];
}

+ (instancetype)containerWithSize:(CGSize)size insets:(UIEdgeInsets)insets
{
    NOCMTextContainer *one = [self new];
    one.size = NOCMTextClipCGSize(size);
    one.insets = insets;
    return one;
}

+ (instancetype)containerWithPath:(nullable UIBezierPath *)path
{
    NOCMTextContainer *one = [self new];
    one.path = path;
    return one;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lock = dispatch_semaphore_create(1);
        _pathFillEvenOdd = YES;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    NOCMTextContainer *one = [self.class new];
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    one->_size = _size;
    one->_insets = _insets;
    one->_path = _path;
    one->_exclusionPaths = _exclusionPaths.copy;
    one->_pathFillEvenOdd = _pathFillEvenOdd;
    one->_pathLineWidth = _pathLineWidth;
    one->_maximumNumberOfRows = _maximumNumberOfRows;
    one->_truncationType = _truncationType;
    one->_truncationToken = _truncationToken.copy;
    one->_linePositionModifier = [(NSObject *)_linePositionModifier copy];
    dispatch_semaphore_signal(_lock);
    return one;
}

- (id)mutableCopyWithZone:(nullable NSZone *)zone
{
    return [self copyWithZone:zone];
}

#define Getter(...) \
dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER); \
__VA_ARGS__; \
dispatch_semaphore_signal(_lock);

#define Setter(...) \
if (_readonly) { \
@throw [NSException exceptionWithName:NSInternalInconsistencyException \
reason:@"Cannot change the property of the 'container' in 'NOCMTextLayout'." userInfo:nil]; \
return; \
} \
dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER); \
__VA_ARGS__; \
dispatch_semaphore_signal(_lock);

- (CGSize)size
{
    Getter(CGSize size = _size) return size;
}

- (void)setSize:(CGSize)size
{
    Setter(if(!_path) _size = NOCMTextClipCGSize(size));
}

- (UIEdgeInsets)insets
{
    Getter(UIEdgeInsets insets = _insets) return insets;
}

- (void)setInsets:(UIEdgeInsets)insets
{
    Setter(if(!_path){
        if (insets.top < 0) { insets.top = 0; }
        if (insets.left < 0) { insets.left = 0; }
        if (insets.bottom < 0) { insets.bottom = 0; }
        if (insets.right < 0) { insets.right = 0; }
        _insets = insets;
    });
}

- (UIBezierPath *)path
{
    Getter(UIBezierPath *path = _path) return path;
}

- (void)setPath:(UIBezierPath *)path
{
    Setter(
           _path = path.copy;
           if (_path) {
               CGRect bounds = _path.bounds;
               CGSize size = bounds.size;
               UIEdgeInsets insets = UIEdgeInsetsZero;
               if (bounds.origin.x < 0) { size.width += bounds.origin.x; }
               if (bounds.origin.x > 0) { insets.left = bounds.origin.x; }
               if (bounds.origin.y < 0) { size.height += bounds.origin.y; }
               if (bounds.origin.y > 0) { insets.top = bounds.origin.y; }
               _size = size;
               _insets = insets;
           }
           );
}

- (NSArray *)exclusionPaths
{
    Getter(NSArray *paths = _exclusionPaths) return paths;
}

- (void)setExclusionPaths:(NSArray *)exclusionPaths
{
    Setter(_exclusionPaths = exclusionPaths.copy);
}

- (BOOL)isPathFillEvenOdd
{
    Getter(BOOL is = _pathFillEvenOdd) return is;
}

- (void)setPathFillEvenOdd:(BOOL)pathFillEvenOdd
{
    Setter(_pathFillEvenOdd = pathFillEvenOdd);
}

- (CGFloat)pathLineWidth
{
    Getter(CGFloat width = _pathLineWidth) return width;
}

- (void)setPathLineWidth:(CGFloat)pathLineWidth
{
    Setter(_pathLineWidth = pathLineWidth);
}

- (NSUInteger)maximumNumberOfRows
{
    Getter(NSUInteger num = _maximumNumberOfRows) return num;
}

- (void)setMaximumNumberOfRows:(NSUInteger)maximumNumberOfRows
{
    Setter(_maximumNumberOfRows = maximumNumberOfRows);
}

- (NOCMTextTruncationType)truncationType
{
    Getter(NOCMTextTruncationType type = _truncationType) return type;
}

- (void)setTruncationType:(NOCMTextTruncationType)truncationType
{
    Setter(_truncationType = truncationType);
}

- (NSAttributedString *)truncationToken
{
    Getter(NSAttributedString *token = _truncationToken) return token;
}

- (void)setTruncationToken:(NSAttributedString *)truncationToken
{
    Setter(_truncationToken = truncationToken.copy);
}

- (void)setLinePositionModifier:(id<NOCMTextLinePositionModifier>)linePositionModifier
{
    Setter(_linePositionModifier = [(NSObject *)linePositionModifier copy]);
}

- (id<NOCMTextLinePositionModifier>)linePositionModifier
{
    Getter(id<NOCMTextLinePositionModifier> m = _linePositionModifier) return m;
}

#undef Getter
#undef Setter

@end

#pragma mark - NOCMTextLinePositionSimpleModifier

@implementation NOCMTextLinePositionSimpleModifier

- (void)modifyLines:(NSArray<NOCMTextLine *> *)lines fromText:(NSAttributedString *)text inContainer:(NOCMTextContainer *)container
{
    for (NSUInteger i = 0, max = lines.count; i < max; i++) {
        NOCMTextLine *line = lines[i];
        CGPoint pos = line.position;
        pos.y = line.row * _fixedLineHeight + _fixedLineHeight * 0.9 + container.insets.top;
        line.position = pos;
    }
}

- (id)copyWithZone:(NSZone *)zone
{
    NOCMTextLinePositionSimpleModifier *one = [self.class new];
    one.fixedLineHeight = _fixedLineHeight;
    return one;
}

@end

#pragma mark - NOCMTextLine

@implementation NOCMTextLine {
    CGFloat _firstGlyphPos;
}

+ (instancetype)lineWithCTLine:(CTLineRef)CTLine position:(CGPoint)position
{
    if (!CTLine) {
        return nil;
    }
    
    NOCMTextLine *line = [self new];
    line->_position = position;
    [line setCTLine:CTLine];
    return line;
}

- (void)dealloc
{
    if (_CTLine) CFRelease(_CTLine);
}

- (void)setCTLine:(_Nonnull CTLineRef)CTLine
{
    if (_CTLine != CTLine) {
        if (CTLine) CFRetain(CTLine);
        if (_CTLine) CFRelease(_CTLine);
        _CTLine = CTLine;
        if (_CTLine) {
            _lineWidth = CTLineGetTypographicBounds(_CTLine, &_ascent, &_descent, &_leading);
            CFRange range = CTLineGetStringRange(_CTLine);
            _range = NSMakeRange(range.location, range.length);
            if (CTLineGetGlyphCount(_CTLine) > 0) {
                CFArrayRef runs = CTLineGetGlyphRuns(_CTLine);
                CTRunRef run = CFArrayGetValueAtIndex(runs, 0);
                CGPoint pos;
                CTRunGetPositions(run, CFRangeMake(0, 1), &pos);
                _firstGlyphPos = pos.x;
            } else {
                _firstGlyphPos = 0;
            }
            _trailingWhitespaceWidth = CTLineGetTrailingWhitespaceWidth(_CTLine);
        } else {
            _lineWidth = _ascent = _descent = _leading = _firstGlyphPos = _trailingWhitespaceWidth = 0;
            _range = NSMakeRange(0, 0);
        }
        [self reloadBounds];
    }
}

- (void)setPosition:(CGPoint)position
{
    _position = position;
    [self reloadBounds];
}

- (void)reloadBounds
{
    _bounds = CGRectMake(_position.x, _position.y - _ascent, _lineWidth, _ascent + _descent);
    _bounds.origin.x += _firstGlyphPos;
    
    _attachments = nil;
    _attachmentRanges = nil;
    _attachmentRects = nil;
    if (!_CTLine) return;
    CFArrayRef runs = CTLineGetGlyphRuns(_CTLine);
    NSUInteger runCount = CFArrayGetCount(runs);
    if (runCount == 0) return;
    
    NSMutableArray *attachments = [NSMutableArray new];
    NSMutableArray *attachmentRanges = [NSMutableArray new];
    NSMutableArray *attachmentRects = [NSMutableArray new];
    for (NSUInteger r = 0; r < runCount; r++) {
        CTRunRef run = CFArrayGetValueAtIndex(runs, r);
        CFIndex glyphCount = CTRunGetGlyphCount(run);
        if (glyphCount == 0) continue;
        NSDictionary *attrs = (id)CTRunGetAttributes(run);
        NOCMTextAttachment *attachment = attrs[NOCMTextAttachmentAttributeName];
        if (attachment) {
            CGPoint runPosition = CGPointZero;
            CTRunGetPositions(run, CFRangeMake(0, 1), &runPosition);
            
            CGFloat ascent, descent, leading, runWidth;
            CGRect runTypoBounds;
            runWidth = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading);
            
            runPosition.x += _position.x;
            runPosition.y = _position.y - runPosition.y;
            runTypoBounds = CGRectMake(runPosition.x, runPosition.y - ascent, runWidth, ascent + descent);
            
            CFRange range = CTRunGetStringRange(run);
            NSRange runRange = NSMakeRange(range.location, range.length);
            [attachments addObject:attachment];
            [attachmentRanges addObject:[NSValue valueWithRange:runRange]];
            [attachmentRects addObject:[NSValue valueWithCGRect:runTypoBounds]];
        }
    }
    _attachments = attachments.count ? attachments : nil;
    _attachmentRanges = attachmentRanges.count ? attachmentRanges : nil;
    _attachmentRects = attachmentRects.count ? attachmentRects : nil;
}

- (CGSize)size
{
    return _bounds.size;
}

- (CGFloat)width
{
    return CGRectGetWidth(_bounds);
}

- (CGFloat)height
{
    return CGRectGetHeight(_bounds);
}

- (CGFloat)top
{
    return CGRectGetMinY(_bounds);
}

- (CGFloat)bottom
{
    return CGRectGetMaxY(_bounds);
}

- (CGFloat)left
{
    return CGRectGetMinX(_bounds);
}

- (CGFloat)right
{
    return CGRectGetMaxX(_bounds);
}

- (NSString *)description
{
    NSMutableString *desc = @"".mutableCopy;
    NSRange range = self.range;
    [desc appendFormat:@"<NOCMTextLine: %p> row:%zd range:%tu,%tu",self, self.row, range.location, range.length];
    [desc appendFormat:@" position:%@",NSStringFromCGPoint(self.position)];
    [desc appendFormat:@" bounds:%@",NSStringFromCGRect(self.bounds)];
    return desc;
}

@end

#pragma mark - NOCMTextLayout

typedef struct {
    CGFloat head;
    CGFloat foot;
} NOCMRowEdge;

static inline BOOL NOCMTextIsLinebreakChar(unichar c)
{
    switch (c) {
        case 0x000D:
        case 0x2028:
        case 0x000A:
        case 0x2029:
            return YES;
        default:
            return NO;
    }
}

static inline BOOL NOCMTextIsLinebreakString(NSString * _Nullable str)
{
    if (str.length > 2 || str.length == 0) return NO;
    if (str.length == 1) {
        unichar c = [str characterAtIndex:0];
        return NOCMTextIsLinebreakChar(c);
    } else {
        return ([str characterAtIndex:0] == '\r') && ([str characterAtIndex:1] == '\n');
    }
}

static inline NSUInteger NOCMTextLinebreakTailLength(NSString * _Nullable str)
{
    if (str.length >= 2) {
        unichar c2 = [str characterAtIndex:str.length - 1];
        if (NOCMTextIsLinebreakChar(c2)) {
            unichar c1 = [str characterAtIndex:str.length - 2];
            if (c1 == '\r' && c2 == '\n') return 2;
            else return 1;
        } else {
            return 0;
        }
    } else if (str.length == 1) {
        return NOCMTextIsLinebreakChar([str characterAtIndex:0]) ? 1 : 0;
    } else {
        return 0;
    }
}

static inline BOOL NOCMCTFontContainsColorBitmapGlyphs(CTFontRef font)
{
    return  (CTFontGetSymbolicTraits(font) & kCTFontTraitColorGlyphs) != 0;
}

@interface NOCMTextLayout ()

@property (nonatomic, readwrite, strong) NOCMTextContainer *container;
@property (nonatomic, readwrite, strong) NSAttributedString *text;
@property (nonatomic, readwrite, assign) NSRange range;

@property (nonatomic, readwrite, assign) CTFramesetterRef frameSetter;
@property (nonatomic, readwrite, assign) CTFrameRef frame;
@property (nonatomic, readwrite, strong) NSArray<NOCMTextLine *> *lines;
@property (nullable, nonatomic, readwrite, strong) NOCMTextLine *truncatedLine;
@property (nullable, nonatomic, readwrite, strong) NSArray<NOCMTextAttachment *> *attachments;
@property (nullable, nonatomic, readwrite, strong) NSArray<NSValue *> *attachmentRanges;
@property (nullable, nonatomic, readwrite, strong) NSArray<NSValue *> *attachmentRects;
@property (nullable, nonatomic, readwrite, strong) NSSet *attachmentContentsSet;
@property (nonatomic, readwrite, assign) NSUInteger rowCount;
@property (nonatomic, readwrite, assign) NSRange visibleRange;
@property (nonatomic, readwrite, assign) CGRect textBoundingRect;
@property (nonatomic, readwrite, assign) CGSize textBoundingSize;

@property (nonatomic, readwrite, assign) BOOL containsHighlight;
@property (nonatomic, readwrite, assign) BOOL needDrawBlockBorder;
@property (nonatomic, readwrite, assign) BOOL needDrawBackgroundBorder;
@property (nonatomic, readwrite, assign) BOOL needDrawShadow;
@property (nonatomic, readwrite, assign) BOOL needDrawUnderline;
@property (nonatomic, readwrite, assign) BOOL needDrawText;
@property (nonatomic, readwrite, assign) BOOL needDrawAttachment;
@property (nonatomic, readwrite, assign) BOOL needDrawInnerShadow;
@property (nonatomic, readwrite, assign) BOOL needDrawStrikethrough;
@property (nonatomic, readwrite, assign) BOOL needDrawBorder;

@property (nonatomic, assign) NSUInteger *lineRowsIndex;
@property (nonatomic, assign) NOCMRowEdge *lineRowsEdge;

@end

@implementation NOCMTextLayout

#pragma mark - Layout

+ (instancetype)layoutWithContainer:(NOCMTextContainer *)container text:(NSAttributedString *)text
{
    return [self layoutWithContainer:container text:text range:NSMakeRange(0, text.length)];
}

+ (instancetype)layoutWithContainer:(NOCMTextContainer *)container text:(NSAttributedString *)text range:(NSRange)range
{
    NOCMTextLayout *layout = nil;
    CGPathRef cgPath = nil;
    CGRect cgPathBox = {0};
    BOOL rowMaySeparated = NO;
    NSMutableDictionary *frameAttrs = nil;
    CTFramesetterRef ctSetter = NULL;
    CTFrameRef ctFrame = NULL;
    CFArrayRef ctLines = nil;
    CGPoint *lineOrigins = NULL;
    NSUInteger lineCount = 0;
    NSMutableArray *lines = nil;
    NSMutableArray *attachments = nil;
    NSMutableArray *attachmentRanges = nil;
    NSMutableArray *attachmentRects = nil;
    NSMutableSet *attachmentContentsSet = nil;
    BOOL needTruncation = NO;
    NSAttributedString *truncationToken = nil;
    NOCMTextLine *truncatedLine = nil;
    NOCMRowEdge *lineRowsEdge = NULL;
    NSUInteger *lineRowsIndex = NULL;
    NSRange visibleRange;
    NSUInteger maximumNumberOfRows = 0;
    BOOL constraintSizeIsExtended = NO;
    CGRect constraintRectBeforeExtended = {0};
    
    text = text.mutableCopy;
    container = container.copy;
    if (!text || !container) return nil;
    if (range.location + range.length > text.length) return nil;
    container->_readonly = YES;
    maximumNumberOfRows = container.maximumNumberOfRows;
    
    // CoreText bug when draw joined emoji since iOS 8.3.
    // See -[NSMutableAttributedString setClearColorToJoinedEmoji] for more information.
    static BOOL needFixJoinedEmojiBug = NO;
    // It may use larger constraint size when create CTFrame with
    // CTFramesetterCreateFrame in iOS 10.
    static BOOL needFixLayoutSizeBug = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat systemVersionFloat = [UIDevice currentDevice].systemVersion.floatValue;
        if (8.3 <= systemVersionFloat && systemVersionFloat < 9) {
            needFixJoinedEmojiBug = YES;
        }
        if (systemVersionFloat >= 10) {
            needFixLayoutSizeBug = YES;
        }
    });
    if (needFixJoinedEmojiBug) {
        [((NSMutableAttributedString *)text) nocm_setClearColorToJoinedEmoji];
    }
    
    layout = [[NOCMTextLayout alloc] _init];
    layout.text = text;
    layout.container = container;
    layout.range = range;
    
    // set cgPath and cgPathBox
    if (container.path == nil && container.exclusionPaths.count == 0) {
        if (container.size.width <= 0 || container.size.height <= 0) goto fail;
        CGRect rect = (CGRect) {CGPointZero, container.size };
        if (needFixLayoutSizeBug) {
            constraintSizeIsExtended = YES;
            constraintRectBeforeExtended = UIEdgeInsetsInsetRect(rect, container.insets);
            constraintRectBeforeExtended = CGRectStandardize(constraintRectBeforeExtended);
            rect.size.height = NOCMTextContainerMaxSize.height;
        }
        rect = UIEdgeInsetsInsetRect(rect, container.insets);
        rect = CGRectStandardize(rect);
        cgPathBox = rect;
        rect = CGRectApplyAffineTransform(rect, CGAffineTransformMakeScale(1, -1));
        cgPath = CGPathCreateWithRect(rect, NULL); // let CGPathIsRect() returns true
    } else {
        // pass
    }
    if (!cgPath) goto fail;
    
    // frame setter config
    frameAttrs = [NSMutableDictionary dictionary];
    if (container.isPathFillEvenOdd == NO) {
        frameAttrs[(id)kCTFramePathFillRuleAttributeName] = @(kCTFramePathFillWindingNumber);
    }
    if (container.pathLineWidth > 0) {
        frameAttrs[(id)kCTFramePathWidthAttributeName] = @(container.pathLineWidth);
    }
    
    // create CoreText objects
    ctSetter = CTFramesetterCreateWithAttributedString((CFTypeRef)text);
    if (!ctSetter) goto fail;
    ctFrame = CTFramesetterCreateFrame(ctSetter, CFRangeMake(range.location, range.length), cgPath, (CFTypeRef)frameAttrs);
    if (!ctFrame) goto fail;
    lines = [NSMutableArray new];
    ctLines = CTFrameGetLines(ctFrame);
    lineCount = CFArrayGetCount(ctLines);
    if (lineCount > 0) {
        lineOrigins = malloc(lineCount * sizeof(CGPoint));
        if (lineOrigins == NULL) goto fail;
        CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, lineCount), lineOrigins);
    }
    
    CGRect textBoundingRect = CGRectZero;
    CGSize textBoundingSize = CGSizeZero;
    NSInteger rowIdx = -1;
    NSUInteger rowCount = 0;
    CGRect lastRect = CGRectMake(0, -FLT_MAX, 0, 0);
    CGPoint lastPosition = CGPointMake(0, -FLT_MAX);
    
    // calculate line frame
    NSUInteger lineCurrentIdx = 0;
    for (NSUInteger i = 0; i < lineCount; i++) {
        CTLineRef ctLine = CFArrayGetValueAtIndex(ctLines, i);
        CFArrayRef ctRuns = CTLineGetGlyphRuns(ctLine);
        if (!ctRuns || CFArrayGetCount(ctRuns) == 0) continue;
        
        // CoreText coordinate system
        CGPoint ctLineOrigin = lineOrigins[i];
        
        // UIKit coordinate system
        CGPoint position;
        position.x = cgPathBox.origin.x + ctLineOrigin.x;
        position.y = cgPathBox.size.height + cgPathBox.origin.y - ctLineOrigin.y;
        
        NOCMTextLine *line = [NOCMTextLine lineWithCTLine:ctLine position:position];
        CGRect rect = line.bounds;
        
        if (constraintSizeIsExtended) {
            if (rect.origin.y + rect.size.height >
                constraintRectBeforeExtended.origin.y +
                constraintRectBeforeExtended.size.height) break;
        }
        
        BOOL newRow = YES;
        if (rowMaySeparated && position.x != lastPosition.x) {
            if (rect.size.height > lastRect.size.height) {
                if (rect.origin.y < lastPosition.y && lastPosition.y < rect.origin.y + rect.size.height) newRow = NO;
            } else {
                if (lastRect.origin.y < position.y && position.y < lastRect.origin.y + lastRect.size.height) newRow = NO;
            }
        }
        
        if (newRow) rowIdx++;
        lastRect = rect;
        lastPosition = position;
        
        line.index = lineCurrentIdx;
        line.row = rowIdx;
        [lines addObject:line];
        rowCount = rowIdx + 1;
        lineCurrentIdx ++;
        
        if (i == 0) textBoundingRect = rect;
        else {
            if (maximumNumberOfRows == 0 || rowIdx < maximumNumberOfRows) {
                textBoundingRect = CGRectUnion(textBoundingRect, rect);
            }
        }
    }
    
    if (rowCount > 0) {
        if (maximumNumberOfRows > 0) {
            if (rowCount > maximumNumberOfRows) {
                needTruncation = YES;
                rowCount = maximumNumberOfRows;
                do {
                    NOCMTextLine *line = lines.lastObject;
                    if (!line) break;
                    if (line.row < rowCount) break;
                    [lines removeLastObject];
                } while (1);
            }
        }
        NOCMTextLine *lastLine = lines.lastObject;
        if (!needTruncation && lastLine.range.location + lastLine.range.length < text.length) {
            needTruncation = YES;
        }
        
        // Give user a chance to modify the line's position.
        if (container.linePositionModifier) {
            [container.linePositionModifier modifyLines:lines fromText:text inContainer:container];
            textBoundingRect = CGRectZero;
            for (NSUInteger i = 0, max = lines.count; i < max; i++) {
                NOCMTextLine *line = lines[i];
                if (i == 0) textBoundingRect = line.bounds;
                else textBoundingRect = CGRectUnion(textBoundingRect, line.bounds);
            }
        }
        
        lineRowsEdge = calloc(rowCount, sizeof(NOCMRowEdge));
        if (lineRowsEdge == NULL) goto fail;
        lineRowsIndex = calloc(rowCount, sizeof(NSUInteger));
        if (lineRowsIndex == NULL) goto fail;
        NSInteger lastRowIdx = -1;
        CGFloat lastHead = 0;
        CGFloat lastFoot = 0;
        for (NSUInteger i = 0, max = lines.count; i < max; i++) {
            NOCMTextLine *line = lines[i];
            CGRect rect = line.bounds;
            if ((NSInteger)line.row != lastRowIdx) {
                if (lastRowIdx >= 0) {
                    lineRowsEdge[lastRowIdx] = (NOCMRowEdge) {.head = lastHead, .foot = lastFoot };
                }
                lastRowIdx = line.row;
                lineRowsIndex[lastRowIdx] = i;
                lastHead = rect.origin.y;
                lastFoot = lastHead + rect.size.height;
            } else {
                lastHead = MIN(lastHead, rect.origin.y);
                lastFoot = MAX(lastFoot, rect.origin.y + rect.size.height);
            }
        }
        lineRowsEdge[lastRowIdx] = (NOCMRowEdge) {.head = lastHead, .foot = lastFoot };
        
        for (NSUInteger i = 1; i < rowCount; i++) {
            NOCMRowEdge v0 = lineRowsEdge[i - 1];
            NOCMRowEdge v1 = lineRowsEdge[i];
            lineRowsEdge[i - 1].foot = lineRowsEdge[i].head = (v0.foot + v1.head) * 0.5;
        }
    }
    
    { // calculate bounding size
        CGRect rect = textBoundingRect;
        if (container.path) {
            if (container.pathLineWidth > 0) {
                CGFloat inset = container.pathLineWidth / 2;
                rect = CGRectInset(rect, -inset, -inset);
            }
        } else {
            UIEdgeInsets insets = container.insets;
            rect = UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(-insets.top, -insets.left, -insets.bottom, -insets.right));
        }
        rect = CGRectStandardize(rect);
        CGSize size = rect.size;
        size.width += rect.origin.x;
        size.height += rect.origin.y;
        if (size.width < 0) size.width = 0;
        if (size.height < 0) size.height = 0;
        size.width = ceil(size.width);
        size.height = ceil(size.height);
        textBoundingSize = size;
    }
    
    CFRange cfRange = CTFrameGetVisibleStringRange(ctFrame);
    visibleRange = NSMakeRange(cfRange.location, cfRange.length);
    if (needTruncation) {
        NOCMTextLine *lastLine = lines.lastObject;
        NSRange lastRange = lastLine.range;
        visibleRange.length = lastRange.location + lastRange.length - visibleRange.location;
        
        // create truncated line
        if (container.truncationType != NOCMTextTruncationTypeNone) {
            CTLineRef truncationTokenLine = NULL;
            if (container.truncationToken) {
                truncationToken = container.truncationToken;
                truncationTokenLine = CTLineCreateWithAttributedString((CFAttributedStringRef)truncationToken);
            } else {
                CFArrayRef runs = CTLineGetGlyphRuns(lastLine.CTLine);
                NSUInteger runCount = CFArrayGetCount(runs);
                NSMutableDictionary *attrs = nil;
                if (runCount > 0) {
                    CTRunRef run = CFArrayGetValueAtIndex(runs, runCount - 1);
                    attrs = (id)CTRunGetAttributes(run);
                    attrs = attrs ? attrs.mutableCopy : [NSMutableArray new];
                    [attrs removeObjectsForKeys:[NSMutableAttributedString nocm_allDiscontinuousAttributeKeys]];
                    CTFontRef font = (__bridge CFTypeRef)attrs[(id)kCTFontAttributeName];
                    CGFloat fontSize = font ? CTFontGetSize(font) : 12.0;
                    UIFont *uiFont = [UIFont systemFontOfSize:fontSize * 0.9];
                    font = [uiFont nocm_CTFontRef];
                    if (font) {
                        attrs[(id)kCTFontAttributeName] = (__bridge id)(font);
                        uiFont = nil;
                        CFRelease(font);
                    }
                    CGColorRef color = (__bridge CGColorRef)(attrs[(id)kCTForegroundColorAttributeName]);
                    if (color && CFGetTypeID(color) == CGColorGetTypeID() && CGColorGetAlpha(color) == 0) {
                        // ignore clear color
                        [attrs removeObjectForKey:(id)kCTForegroundColorAttributeName];
                    }
                    if (!attrs) attrs = [NSMutableDictionary new];
                }
                truncationToken = [[NSAttributedString alloc] initWithString:NOCMTextTruncationToken attributes:attrs];
                truncationTokenLine = CTLineCreateWithAttributedString((CFAttributedStringRef)truncationToken);
            }
            if (truncationTokenLine) {
                CTLineTruncationType type = kCTLineTruncationEnd;
                if (container.truncationType == NOCMTextTruncationTypeStart) {
                    type = kCTLineTruncationStart;
                } else if (container.truncationType == NOCMTextTruncationTypeMiddle) {
                    type = kCTLineTruncationMiddle;
                }
                NSMutableAttributedString *lastLineText = [text attributedSubstringFromRange:lastLine.range].mutableCopy;
                [lastLineText appendAttributedString:truncationToken];
                CTLineRef ctLastLineExtend = CTLineCreateWithAttributedString((CFAttributedStringRef)lastLineText);
                if (ctLastLineExtend) {
                    CGFloat truncatedWidth = lastLine.width;
                    CGRect cgPathRect = CGRectZero;
                    if (CGPathIsRect(cgPath, &cgPathRect)) {
                        truncatedWidth = cgPathRect.size.width;
                    }
                    CTLineRef ctTruncatedLine = CTLineCreateTruncatedLine(ctLastLineExtend, truncatedWidth, type, truncationTokenLine);
                    CFRelease(ctLastLineExtend);
                    if (ctTruncatedLine) {
                        truncatedLine = [NOCMTextLine lineWithCTLine:ctTruncatedLine position:lastLine.position];
                        truncatedLine.index = lastLine.index;
                        truncatedLine.row = lastLine.row;
                        CFRelease(ctTruncatedLine);
                    }
                }
                CFRelease(truncationTokenLine);
            }
        }
    }
    
    if (visibleRange.length > 0) {
        layout.needDrawText = YES;
        
        void (^block)(NSDictionary *attrs, NSRange range, BOOL *stop) = ^(NSDictionary *attrs, NSRange range, BOOL *stop) {
            if (attrs[NOCMTextHighlightAttributeName]) layout.containsHighlight = YES;
            if (attrs[NOCMTextBlockBorderAttributeName]) layout.needDrawBlockBorder = YES;
            if (attrs[NOCMTextBackgroundBorderAttributeName]) layout.needDrawBackgroundBorder = YES;
            if (attrs[NOCMTextShadowAttributeName] || attrs[NSShadowAttributeName]) layout.needDrawShadow = YES;
            if (attrs[NOCMTextUnderlineAttributeName]) layout.needDrawUnderline = YES;
            if (attrs[NOCMTextAttachmentAttributeName]) layout.needDrawAttachment = YES;
            if (attrs[NOCMTextInnerShadowAttributeName]) layout.needDrawInnerShadow = YES;
            if (attrs[NOCMTextStrikethroughAttributeName]) layout.needDrawStrikethrough = YES;
            if (attrs[NOCMTextBorderAttributeName]) layout.needDrawBorder = YES;
        };
        
        [layout.text enumerateAttributesInRange:visibleRange options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:block];
        if (truncatedLine) {
            [truncationToken enumerateAttributesInRange:NSMakeRange(0, truncationToken.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:block];
        }
    }
    
    attachments = [NSMutableArray new];
    attachmentRanges = [NSMutableArray new];
    attachmentRects = [NSMutableArray new];
    attachmentContentsSet = [NSMutableSet new];
    for (NSUInteger i = 0, max = lines.count; i < max; i++) {
        NOCMTextLine *line = lines[i];
        if (truncatedLine && line.index == truncatedLine.index) line = truncatedLine;
        if (line.attachments.count > 0) {
            [attachments addObjectsFromArray:line.attachments];
            [attachmentRanges addObjectsFromArray:line.attachmentRanges];
            [attachmentRects addObjectsFromArray:line.attachmentRects];
            for (NOCMTextAttachment *attachment in line.attachments) {
                if (attachment.content) {
                    [attachmentContentsSet addObject:attachment.content];
                }
            }
        }
    }
    if (attachments.count == 0) {
        attachments = attachmentRanges = attachmentRects = nil;
    }
    
    layout.frameSetter = ctSetter;
    layout.frame = ctFrame;
    layout.lines = lines;
    layout.truncatedLine = truncatedLine;
    layout.attachments = attachments;
    layout.attachmentRanges = attachmentRanges;
    layout.attachmentRects = attachmentRects;
    layout.attachmentContentsSet = attachmentContentsSet;
    layout.rowCount = rowCount;
    layout.visibleRange = visibleRange;
    layout.textBoundingRect = textBoundingRect;
    layout.textBoundingSize = textBoundingSize;
    layout.lineRowsEdge = lineRowsEdge;
    layout.lineRowsIndex = lineRowsIndex;
    CFRelease(cgPath);
    CFRelease(ctSetter);
    CFRelease(ctFrame);
    if (lineOrigins) free(lineOrigins);
    return layout;
    
fail:
    if (cgPath) CFRelease(cgPath);
    if (ctSetter) CFRelease(ctSetter);
    if (ctFrame) CFRelease(ctFrame);
    if (lineOrigins) free(lineOrigins);
    if (lineRowsEdge) free(lineRowsEdge);
    if (lineRowsIndex) free(lineRowsIndex);
    return nil;
}

- (instancetype)_init
{
    self = [super init];
    return self;
}

- (void)setFrameSetter:(CTFramesetterRef)frameSetter
{
    if (_frameSetter != frameSetter) {
        if (frameSetter) CFRetain(frameSetter);
        if (_frameSetter) CFRelease(_frameSetter);
        _frameSetter = frameSetter;
    }
}

- (void)setFrame:(CTFrameRef)frame
{
    if (_frame != frame) {
        if (frame) CFRetain(frame);
        if (_frame) CFRelease(_frame);
        _frame = frame;
    }
}

- (void)dealloc
{
    if (_frameSetter) CFRelease(_frameSetter);
    if (_frame) CFRelease(_frame);
    if (_lineRowsIndex) free(_lineRowsIndex);
    if (_lineRowsEdge) free(_lineRowsEdge);
}

#pragma mark - Query

- (NSUInteger)_rowIndexForEdge:(CGFloat)edge
{
    if (_rowCount == 0) return NSNotFound;
    NSUInteger lo = 0, hi = _rowCount - 1, mid = 0;
    NSUInteger rowIdx = NSNotFound;
    while (lo <= hi) {
        mid = (lo + hi) / 2;
        NOCMRowEdge oneEdge = _lineRowsEdge[mid];
        if (oneEdge.head <= edge && edge <= oneEdge.foot) {
            rowIdx = mid;
            break;
        }
        if (edge < oneEdge.head) {
            if (mid == 0) break;
            hi = mid - 1;
        } else {
            lo = mid + 1;
        }
    }
    return rowIdx;
}

- (NSUInteger)_closestRowIndexForEdge:(CGFloat)edge
{
    if (_rowCount == 0) return NSNotFound;
    NSUInteger rowIdx = [self _rowIndexForEdge:edge];
    if (rowIdx == NSNotFound) {
        if (edge < _lineRowsEdge[0].head) {
            rowIdx = 0;
        } else if (edge > _lineRowsEdge[_rowCount - 1].foot) {
            rowIdx = _rowCount - 1;
        }
    }
    return rowIdx;
}

- (CTRunRef)_runForLine:(NOCMTextLine *)line position:(NOCMTextPosition *)position
{
    if (!line || !position) return NULL;
    CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
    for (NSUInteger i = 0, max = CFArrayGetCount(runs); i < max; i++) {
        CTRunRef run = CFArrayGetValueAtIndex(runs, i);
        CFRange range = CTRunGetStringRange(run);
        if (position.affinity == NOCMTextAffinityBackward) {
            if (range.location < position.offset && position.offset <= range.location + range.length) {
                return run;
            }
        } else {
            if (range.location <= position.offset && position.offset < range.location + range.length) {
                return run;
            }
        }
    }
    return NULL;
}

- (BOOL)_insideComposedCharacterSequences:(NOCMTextLine *)line position:(NSUInteger)position block:(void (^)(CGFloat left, CGFloat right, NSUInteger prev, NSUInteger next))block
{
    NSRange range = line.range;
    if (range.length == 0) return NO;
    __block BOOL inside = NO;
    __block NSUInteger _prev, _next;
    [_text.string enumerateSubstringsInRange:range options:NSStringEnumerationByComposedCharacterSequences usingBlock: ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        NSUInteger prev = substringRange.location;
        NSUInteger next = substringRange.location + substringRange.length;
        if (prev == position || next == position) {
            *stop = YES;
        }
        if (prev < position && position < next) {
            inside = YES;
            _prev = prev;
            _next = next;
            *stop = YES;
        }
    }];
    if (inside && block) {
        CGFloat left = [self offsetForTextPosition:_prev lineIndex:line.index];
        CGFloat right = [self offsetForTextPosition:_next lineIndex:line.index];
        block(left, right, _prev, _next);
    }
    return inside;
}

- (BOOL)_insideEmoji:(NOCMTextLine *)line position:(NSUInteger)position block:(void (^)(CGFloat left, CGFloat right, NSUInteger prev, NSUInteger next))block
{
    if (!line) return NO;
    CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
    for (NSUInteger r = 0, rMax = CFArrayGetCount(runs); r < rMax; r++) {
        CTRunRef run = CFArrayGetValueAtIndex(runs, r);
        NSUInteger glyphCount = CTRunGetGlyphCount(run);
        if (glyphCount == 0) continue;
        CFRange range = CTRunGetStringRange(run);
        if (range.length <= 1) continue;
        if (position <= range.location || position >= range.location + range.length) continue;
        CFDictionaryRef attrs = CTRunGetAttributes(run);
        CTFontRef font = CFDictionaryGetValue(attrs, kCTFontAttributeName);
        if (!NOCMCTFontContainsColorBitmapGlyphs(font)) continue;
        
        // Here's Emoji runs (larger than 1 unichar), and position is inside the range.
        CFIndex indices[glyphCount];
        CTRunGetStringIndices(run, CFRangeMake(0, glyphCount), indices);
        for (NSUInteger g = 0; g < glyphCount; g++) {
            CFIndex prev = indices[g];
            CFIndex next = g + 1 < glyphCount ? indices[g + 1] : range.location + range.length;
            if (position == prev) break; // Emoji edge
            if (prev < position && position < next) { // inside an emoji (such as National Flag Emoji)
                CGPoint pos = CGPointZero;
                CGSize adv = CGSizeZero;
                CTRunGetPositions(run, CFRangeMake(g, 1), &pos);
                CTRunGetAdvances(run, CFRangeMake(g, 1), &adv);
                if (block) {
                    block(line.position.x + pos.x,
                          line.position.x + pos.x + adv.width,
                          prev, next);
                }
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL)_isRightToLeftInLine:(NOCMTextLine *)line atPoint:(CGPoint)point
{
    if (!line) return NO;
    // get write direction
    BOOL RTL = NO;
    CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
    for (NSUInteger r = 0, max = CFArrayGetCount(runs); r < max; r++) {
        CTRunRef run = CFArrayGetValueAtIndex(runs, r);
        CGPoint glyphPosition;
        CTRunGetPositions(run, CFRangeMake(0, 1), &glyphPosition);
        CGFloat runX = glyphPosition.x;
        runX += line.position.x;
        CGFloat runWidth = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), NULL, NULL, NULL);
        if (runX <= point.x && point.x <= runX + runWidth) {
            if (CTRunGetStatus(run) & kCTRunStatusRightToLeft) RTL = YES;
            break;
        }
    }
    return RTL;
}

- (NOCMTextRange *)_correctedRangeWithEdge:(NOCMTextRange *)range
{
    NSRange visibleRange = self.visibleRange;
    NOCMTextPosition *start = range.start;
    NOCMTextPosition *end = range.end;
    
    if (start.offset == visibleRange.location && start.affinity == NOCMTextAffinityBackward) {
        start = [NOCMTextPosition positionWithOffset:start.offset affinity:NOCMTextAffinityForward];
    }
    
    if (end.offset == visibleRange.location + visibleRange.length && start.affinity == NOCMTextAffinityForward) {
        end = [NOCMTextPosition positionWithOffset:end.offset affinity:NOCMTextAffinityBackward];
    }
    
    if (start != range.start || end != range.end) {
        range = [NOCMTextRange rangeWithStart:start end:end];
    }
    return range;
}

- (NSUInteger)lineIndexForRow:(NSUInteger)row
{
    if (row >= _rowCount) return NSNotFound;
    return _lineRowsIndex[row];
}

- (NSUInteger)lineCountForRow:(NSUInteger)row
{
    if (row >= _rowCount) return NSNotFound;
    if (row == _rowCount - 1) {
        return _lines.count - _lineRowsIndex[row];
    } else {
        return _lineRowsIndex[row + 1] - _lineRowsIndex[row];
    }
}

- (NSUInteger)rowIndexForLine:(NSUInteger)line
{
    if (line >= _lines.count) return NSNotFound;
    return ((NOCMTextLine *)_lines[line]).row;
}

- (NSUInteger)lineIndexForPoint:(CGPoint)point
{
    if (_lines.count == 0 || _rowCount == 0) return NSNotFound;
    NSUInteger rowIdx = [self _rowIndexForEdge:point.y];
    if (rowIdx == NSNotFound) return NSNotFound;
    
    NSUInteger lineIdx0 = _lineRowsIndex[rowIdx];
    NSUInteger lineIdx1 = rowIdx == _rowCount - 1 ? _lines.count - 1 : _lineRowsIndex[rowIdx + 1] - 1;
    for (NSUInteger i = lineIdx0; i <= lineIdx1; i++) {
        CGRect bounds = ((NOCMTextLine *)_lines[i]).bounds;
        if (CGRectContainsPoint(bounds, point)) return i;
    }
    
    return NSNotFound;
}

- (NSUInteger)closestLineIndexForPoint:(CGPoint)point
{
    if (_lines.count == 0 || _rowCount == 0) return NSNotFound;
    NSUInteger rowIdx = [self _closestRowIndexForEdge:point.y];
    if (rowIdx == NSNotFound) return NSNotFound;
    
    NSUInteger lineIdx0 = _lineRowsIndex[rowIdx];
    NSUInteger lineIdx1 = rowIdx == _rowCount - 1 ? _lines.count - 1 : _lineRowsIndex[rowIdx + 1] - 1;
    if (lineIdx0 == lineIdx1) return lineIdx0;
    
    CGFloat minDistance = CGFLOAT_MAX;
    NSUInteger minIndex = lineIdx0;
    for (NSUInteger i = lineIdx0; i <= lineIdx1; i++) {
        CGRect bounds = ((NOCMTextLine *)_lines[i]).bounds;
        if (bounds.origin.x <= point.x && point.x <= bounds.origin.x + bounds.size.width) return i;
        CGFloat distance;
        if (point.x < bounds.origin.x) {
            distance = bounds.origin.x - point.x;
        } else {
            distance = point.x - (bounds.origin.x + bounds.size.width);
        }
        if (distance < minDistance) {
            minDistance = distance;
            minIndex = i;
        }
    }
    return minIndex;
}

- (CGFloat)offsetForTextPosition:(NSUInteger)position lineIndex:(NSUInteger)lineIndex
{
    if (lineIndex >= _lines.count) return CGFLOAT_MAX;
    NOCMTextLine *line = _lines[lineIndex];
    CFRange range = CTLineGetStringRange(line.CTLine);
    if (position < range.location || position > range.location + range.length) return CGFLOAT_MAX;
    
    CGFloat offset = CTLineGetOffsetForStringIndex(line.CTLine, position, NULL);
    return offset + line.position.x;
}

- (NSUInteger)textPositionForPoint:(CGPoint)point lineIndex:(NSUInteger)lineIndex
{
    if (lineIndex >= _lines.count) return NSNotFound;
    NOCMTextLine *line = _lines[lineIndex];
    point.x -= line.position.x;
    point.y = 0;
    
    CFIndex idx = CTLineGetStringIndexForPosition(line.CTLine, point);
    if (idx == kCFNotFound) return NSNotFound;
    
    /*
     If the emoji contains one or more variant form (such as ☔️ "\u2614\uFE0F")
     and the font size is smaller than 379/15, then each variant form ("\uFE0F")
     will rendered as a single blank glyph behind the emoji glyph. Maybe it's a
     bug in CoreText? Seems iOS8.3 fixes this problem.
     
     If the point hit the blank glyph, the CTLineGetStringIndexForPosition()
     returns the position before the emoji glyph, but it should returns the
     position after the emoji and variant form.
     
     Here's a workaround.
     */
    CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
    for (NSUInteger r = 0, max = CFArrayGetCount(runs); r < max; r++) {
        CTRunRef run = CFArrayGetValueAtIndex(runs, r);
        CFRange range = CTRunGetStringRange(run);
        if (range.location <= idx && idx < range.location + range.length) {
            NSUInteger glyphCount = CTRunGetGlyphCount(run);
            if (glyphCount == 0) break;
            CFDictionaryRef attrs = CTRunGetAttributes(run);
            CTFontRef font = CFDictionaryGetValue(attrs, kCTFontAttributeName);
            if (!NOCMCTFontContainsColorBitmapGlyphs(font)) break;
            
            CFIndex indices[glyphCount];
            CGPoint positions[glyphCount];
            CTRunGetStringIndices(run, CFRangeMake(0, glyphCount), indices);
            CTRunGetPositions(run, CFRangeMake(0, glyphCount), positions);
            for (NSUInteger g = 0; g < glyphCount; g++) {
                NSUInteger gIdx = indices[g];
                if (gIdx == idx && g + 1 < glyphCount) {
                    CGFloat right = positions[g + 1].x;
                    if (point.x < right) break;
                    NSUInteger next = indices[g + 1];
                    do {
                        if (next == range.location + range.length) break;
                        unichar c = [_text.string characterAtIndex:next];
                        if ((c == 0xFE0E || c == 0xFE0F)) { // unicode variant form for emoji style
                            next++;
                        } else break;
                    }
                    while (1);
                    if (next != indices[g + 1]) idx = next;
                    break;
                }
            }
            break;
        }
    }
    return idx;
}

- (nullable NOCMTextPosition *)closestPositionToPoint:(CGPoint)point
{
    // When call CTLineGetStringIndexForPosition() on ligature such as 'fi',
    // and the point `hit` the glyph's left edge, it may get the ligature inside offset.
    // I don't know why, maybe it's a bug of CoreText. Try to avoid it.
    point.x += 0.00001234;
    
    NSUInteger lineIndex = [self closestLineIndexForPoint:point];
    if (lineIndex == NSNotFound) return nil;
    NOCMTextLine *line = _lines[lineIndex];
    __block NSUInteger position = [self textPositionForPoint:point lineIndex:lineIndex];
    if (position == NSNotFound) position = line.range.location;
    if (position <= _visibleRange.location) {
        return [NOCMTextPosition positionWithOffset:_visibleRange.location affinity:NOCMTextAffinityForward];
    } else if (position >= _visibleRange.location + _visibleRange.length) {
        return [NOCMTextPosition positionWithOffset:_visibleRange.location + _visibleRange.length affinity:NOCMTextAffinityBackward];
    }
    
    NOCMTextAffinity finalAffinity = NOCMTextAffinityForward;
    BOOL finalAffinityDetected = NO;
    
    // empty line
    if (line.range.length == 0) {
        BOOL behind = (_lines.count > 1 && lineIndex == _lines.count - 1);  //end line
        return [NOCMTextPosition positionWithOffset:line.range.location affinity:behind ? NOCMTextAffinityBackward:NOCMTextAffinityForward];
    }
    
    // detect whether the line is a linebreak token
    if (line.range.length <= 2) {
        NSString *str = [_text.string substringWithRange:line.range];
        if (NOCMTextIsLinebreakString(str)) { // an empty line ("\r", "\n", "\r\n")
            return [NOCMTextPosition positionWithOffset:line.range.location];
        }
    }
    
    // above whole text frame
    if (lineIndex == 0 && (point.y < line.top)) {
        position = 0;
        finalAffinity = NOCMTextAffinityForward;
        finalAffinityDetected = YES;
    }
    // below whole text frame
    if (lineIndex == _lines.count - 1 && (point.y > line.bottom)) {
        position = line.range.location + line.range.length;
        finalAffinity = NOCMTextAffinityBackward;
        finalAffinityDetected = YES;
    }
    
    // There must be at least one non-linebreak char,
    // ignore the linebreak characters at line end if exists.
    if (position >= line.range.location + line.range.length - 1) {
        if (position > line.range.location) {
            unichar c1 = [_text.string characterAtIndex:position - 1];
            if (NOCMTextIsLinebreakChar(c1)) {
                position--;
                if (position > line.range.location) {
                    unichar c0 = [_text.string characterAtIndex:position - 1];
                    if (NOCMTextIsLinebreakChar(c0)) {
                        position--;
                    }
                }
            }
        }
    }
    if (position == line.range.location) {
        return [NOCMTextPosition positionWithOffset:position];
    }
    if (position == line.range.location + line.range.length) {
        return [NOCMTextPosition positionWithOffset:position affinity:NOCMTextAffinityBackward];
    }
    
    [self _insideComposedCharacterSequences:line position:position block: ^(CGFloat left, CGFloat right, NSUInteger prev, NSUInteger next) {
        position = fabs(left - point.x) < fabs(right - point.x) < (right ? prev : next);
    }];
    
    [self _insideEmoji:line position:position block: ^(CGFloat left, CGFloat right, NSUInteger prev, NSUInteger next) {
        position = fabs(left - point.x) < fabs(right - point.x) < (right ? prev : next);
    }];
    
    if (position < _visibleRange.location) position = _visibleRange.location;
    else if (position > _visibleRange.location + _visibleRange.length) position = _visibleRange.location + _visibleRange.length;
    
    if (!finalAffinityDetected) {
        CGFloat ofs = [self offsetForTextPosition:position lineIndex:lineIndex];
        if (ofs != CGFLOAT_MAX) {
            BOOL RTL = [self _isRightToLeftInLine:line atPoint:point];
            if (position >= line.range.location + line.range.length) {
                finalAffinity = RTL ? NOCMTextAffinityForward : NOCMTextAffinityBackward;
            } else if (position <= line.range.location) {
                finalAffinity = RTL ? NOCMTextAffinityBackward : NOCMTextAffinityForward;
            } else {
                finalAffinity = (ofs < point.x && !RTL) ? NOCMTextAffinityForward : NOCMTextAffinityBackward;
            }
        }
    }
    
    return [NOCMTextPosition positionWithOffset:position affinity:finalAffinity];
}

- (nullable NOCMTextPosition *)positionForPoint:(CGPoint)point oldPosition:(NOCMTextPosition *)oldPosition otherPosition:(NOCMTextPosition *)otherPosition
{
    if (!oldPosition || !otherPosition) {
        return oldPosition;
    }
    NOCMTextPosition *newPos = [self closestPositionToPoint:point];
    if (!newPos) return oldPosition;
    if ([newPos compare:otherPosition] == [oldPosition compare:otherPosition] &&
        newPos.offset != otherPosition.offset) {
        return newPos;
    }
    NSUInteger lineIndex = [self lineIndexForPosition:otherPosition];
    if (lineIndex == NSNotFound) return oldPosition;
    NOCMTextLine *line = _lines[lineIndex];
    NOCMRowEdge vertical = _lineRowsEdge[line.row];
    point.y = (vertical.head + vertical.foot) * 0.5;
    newPos = [self closestPositionToPoint:point];
    if ([newPos compare:otherPosition] == [oldPosition compare:otherPosition] &&
        newPos.offset != otherPosition.offset) {
        return newPos;
    }
    
    if ([oldPosition compare:otherPosition] == NSOrderedAscending) { // search backward
        NOCMTextRange *range = [self textRangeByExtendingPosition:otherPosition inDirection:UITextLayoutDirectionLeft offset:1];
        if (range) return range.start;
    } else { // search forward
        NOCMTextRange *range = [self textRangeByExtendingPosition:otherPosition inDirection:UITextLayoutDirectionRight offset:1];
        if (range) return range.end;
    }
    
    return oldPosition;
}

- (nullable NOCMTextRange *)textRangeAtPoint:(CGPoint)point
{
    NSUInteger lineIndex = [self lineIndexForPoint:point];
    if (lineIndex == NSNotFound) return nil;
    NSUInteger textPosition = [self textPositionForPoint:point lineIndex:[self lineIndexForPoint:point]];
    if (textPosition == NSNotFound) return nil;
    NOCMTextPosition *pos = [self closestPositionToPoint:point];
    if (!pos) return nil;
    
    // get write direction
    BOOL RTL = [self _isRightToLeftInLine:_lines[lineIndex] atPoint:point];
    CGRect rect = [self caretRectForPosition:pos];
    if (CGRectIsNull(rect)) return nil;
    
    NOCMTextRange *range = [self textRangeByExtendingPosition:pos inDirection:(rect.origin.x >= point.x && !RTL) ? UITextLayoutDirectionLeft:UITextLayoutDirectionRight offset:1];
    return range;
}

- (nullable NOCMTextRange *)closestTextRangeAtPoint:(CGPoint)point
{
    NOCMTextPosition *pos = [self closestPositionToPoint:point];
    if (!pos) return nil;
    NSUInteger lineIndex = [self lineIndexForPosition:pos];
    if (lineIndex == NSNotFound) return nil;
    NOCMTextLine *line = _lines[lineIndex];
    BOOL RTL = [self _isRightToLeftInLine:line atPoint:point];
    CGRect rect = [self caretRectForPosition:pos];
    if (CGRectIsNull(rect)) return nil;
    
    UITextLayoutDirection direction = UITextLayoutDirectionRight;
    if (pos.offset >= line.range.location + line.range.length) {
        if (direction != RTL) {
            direction = UITextLayoutDirectionLeft;
        } else {
            direction = UITextLayoutDirectionRight;
        }
    } else if (pos.offset <= line.range.location) {
        if (direction != RTL) {
            direction = UITextLayoutDirectionRight;
        } else {
            direction = UITextLayoutDirectionLeft;
        }
    } else {
        direction = (rect.origin.x >= point.x && !RTL) ? UITextLayoutDirectionLeft:UITextLayoutDirectionRight;
    }
    
    NOCMTextRange *range = [self textRangeByExtendingPosition:pos inDirection:direction offset:1];
    return range;
}

- (nullable NOCMTextRange *)textRangeByExtendingPosition:(NOCMTextPosition *)position
{
    NSUInteger visibleStart = _visibleRange.location;
    NSUInteger visibleEnd = _visibleRange.location + _visibleRange.length;
    
    if (!position) return nil;
    if (position.offset < visibleStart || position.offset > visibleEnd) return nil;
    
    // head or tail, returns immediately
    if (position.offset == visibleStart) {
        return [NOCMTextRange rangeWithRange:NSMakeRange(position.offset, 0)];
    } else if (position.offset == visibleEnd) {
        return [NOCMTextRange rangeWithRange:NSMakeRange(position.offset, 0) affinity:NOCMTextAffinityBackward];
    }
    
    // inside emoji or composed character sequences
    NSUInteger lineIndex = [self lineIndexForPosition:position];
    if (lineIndex != NSNotFound) {
        __block NSUInteger _prev, _next;
        BOOL emoji = NO, seq = NO;
        
        NOCMTextLine *line = _lines[lineIndex];
        emoji = [self _insideEmoji:line position:position.offset block: ^(CGFloat left, CGFloat right, NSUInteger prev, NSUInteger next) {
            _prev = prev;
            _next = next;
        }];
        if (!emoji) {
            seq = [self _insideComposedCharacterSequences:line position:position.offset block: ^(CGFloat left, CGFloat right, NSUInteger prev, NSUInteger next) {
                _prev = prev;
                _next = next;
            }];
        }
        if (emoji || seq) {
            return [NOCMTextRange rangeWithRange:NSMakeRange(_prev, _next - _prev)];
        }
    }
    
    // inside linebreak '\r\n'
    if (position.offset > visibleStart && position.offset < visibleEnd) {
        unichar c0 = [_text.string characterAtIndex:position.offset - 1];
        if ((c0 == '\r') && position.offset < visibleEnd) {
            unichar c1 = [_text.string characterAtIndex:position.offset];
            if (c1 == '\n') {
                return [NOCMTextRange rangeWithStart:[NOCMTextPosition positionWithOffset:position.offset - 1] end:[NOCMTextPosition positionWithOffset:position.offset + 1]];
            }
        }
        if (NOCMTextIsLinebreakChar(c0) && position.affinity == NOCMTextAffinityBackward) {
            NSString *str = [_text.string substringToIndex:position.offset];
            NSUInteger len = NOCMTextLinebreakTailLength(str);
            return [NOCMTextRange rangeWithStart:[NOCMTextPosition positionWithOffset:position.offset - len] end:[NOCMTextPosition positionWithOffset:position.offset]];
        }
    }
    
    return [NOCMTextRange rangeWithRange:NSMakeRange(position.offset, 0) affinity:position.affinity];
}

- (nullable NOCMTextRange *)textRangeByExtendingPosition:(NOCMTextPosition *)position inDirection:(UITextLayoutDirection)direction offset:(NSInteger)offset
{
    NSInteger visibleStart = _visibleRange.location;
    NSInteger visibleEnd = _visibleRange.location + _visibleRange.length;
    
    if (!position) return nil;
    if (position.offset < visibleStart || position.offset > visibleEnd) return nil;
    if (offset == 0) return [self textRangeByExtendingPosition:position];
    
    BOOL verticalMove, forwardMove;
    
    verticalMove = direction == UITextLayoutDirectionUp || direction == UITextLayoutDirectionDown;
    forwardMove = direction == UITextLayoutDirectionDown || direction == UITextLayoutDirectionRight;
    
    if (offset < 0) {
        forwardMove = !forwardMove;
        offset = -offset;
    }
    
    // head or tail, returns immediately
    if (!forwardMove && position.offset == visibleStart) {
        return [NOCMTextRange rangeWithRange:NSMakeRange(_visibleRange.location, 0)];
    } else if (forwardMove && position.offset == visibleEnd) {
        return [NOCMTextRange rangeWithRange:NSMakeRange(position.offset, 0) affinity:NOCMTextAffinityBackward];
    }
    
    // extend from position
    NOCMTextRange *fromRange = [self textRangeByExtendingPosition:position];
    if (!fromRange) return nil;
    NOCMTextRange *allForward = [NOCMTextRange rangeWithStart:fromRange.start end:[NOCMTextPosition positionWithOffset:visibleEnd]];
    NOCMTextRange *allBackward = [NOCMTextRange rangeWithStart:[NOCMTextPosition positionWithOffset:visibleStart] end:fromRange.end];
    
    if (verticalMove) { // up/down in text layout
        NSInteger lineIndex = [self lineIndexForPosition:position];
        if (lineIndex == NSNotFound) return nil;
        
        NOCMTextLine *line = _lines[lineIndex];
        NSInteger moveToRowIndex = (NSInteger)line.row + (forwardMove ? offset : -offset);
        if (moveToRowIndex < 0) return allBackward;
        else if (moveToRowIndex >= (NSInteger)_rowCount) return allForward;
        
        CGFloat ofs = [self offsetForTextPosition:position.offset lineIndex:lineIndex];
        if (ofs == CGFLOAT_MAX) return nil;
        
        NSUInteger moveToLineFirstIndex = [self lineIndexForRow:moveToRowIndex];
        NSUInteger moveToLineCount = [self lineCountForRow:moveToRowIndex];
        if (moveToLineFirstIndex == NSNotFound || moveToLineCount == NSNotFound || moveToLineCount == 0) return nil;
        CGFloat mostLeft = CGFLOAT_MAX, mostRight = -CGFLOAT_MAX;
        NOCMTextLine *mostLeftLine = nil, *mostRightLine = nil;
        NSUInteger insideIndex = NSNotFound;
        for (NSUInteger i = 0; i < moveToLineCount; i++) {
            NSUInteger lineIndex = moveToLineFirstIndex + i;
            NOCMTextLine *line = _lines[lineIndex];
            if (line.left <= ofs && ofs <= line.right) {
                insideIndex = line.index;
                break;
            }
            if (line.left < mostLeft) {
                mostLeft = line.left;
                mostLeftLine = line;
            }
            if (line.right > mostRight) {
                mostRight = line.right;
                mostRightLine = line;
            }
        }
        BOOL afinityEdge = NO;
        if (insideIndex == NSNotFound) {
            if (ofs <= mostLeft) {
                insideIndex = mostLeftLine.index;
            } else {
                insideIndex = mostRightLine.index;
            }
            afinityEdge = YES;
        }
        NOCMTextLine *insideLine = _lines[insideIndex];
        NSUInteger pos = [self textPositionForPoint:CGPointMake(ofs, insideLine.position.y) lineIndex:insideIndex];
        if (pos == NSNotFound) return nil;
        NOCMTextPosition *extPos;
        if (afinityEdge) {
            if (pos == insideLine.range.location + insideLine.range.length) {
                NSString *subStr = [_text.string substringWithRange:insideLine.range];
                NSUInteger lineBreakLen = NOCMTextLinebreakTailLength(subStr);
                extPos = [NOCMTextPosition positionWithOffset:pos - lineBreakLen];
            } else {
                extPos = [NOCMTextPosition positionWithOffset:pos];
            }
        } else {
            extPos = [NOCMTextPosition positionWithOffset:pos];
        }
        NOCMTextRange *ext = [self textRangeByExtendingPosition:extPos];
        if (!ext) return nil;
        if (forwardMove) {
            return [NOCMTextRange rangeWithStart:fromRange.start end:ext.end];
        } else {
            return [NOCMTextRange rangeWithStart:ext.start end:fromRange.end];
        }
        
    } else { // left/right in text layout
        NOCMTextPosition *toPosition = [NOCMTextPosition positionWithOffset:position.offset + (forwardMove ? offset : -offset)];
        if (toPosition.offset <= visibleStart) return allBackward;
        else if (toPosition.offset >= visibleEnd) return allForward;
        
        NOCMTextRange *toRange = [self textRangeByExtendingPosition:toPosition];
        if (!toRange) return nil;
        
        NSInteger start = MIN(fromRange.start.offset, toRange.start.offset);
        NSInteger end = MAX(fromRange.end.offset, toRange.end.offset);
        return [NOCMTextRange rangeWithRange:NSMakeRange(start, end - start)];
    }
}

- (NSUInteger)lineIndexForPosition:(NOCMTextPosition *)position
{
    if (!position) return NSNotFound;
    if (_lines.count == 0) return NSNotFound;
    NSUInteger location = position.offset;
    NSInteger lo = 0, hi = _lines.count - 1, mid = 0;
    if (position.affinity == NOCMTextAffinityBackward) {
        while (lo <= hi) {
            mid = (lo + hi) / 2;
            NOCMTextLine *line = _lines[mid];
            NSRange range = line.range;
            if (range.location < location && location <= range.location + range.length) {
                return mid;
            }
            if (location <= range.location) {
                hi = mid - 1;
            } else {
                lo = mid + 1;
            }
        }
    } else {
        while (lo <= hi) {
            mid = (lo + hi) / 2;
            NOCMTextLine *line = _lines[mid];
            NSRange range = line.range;
            if (range.location <= location && location < range.location + range.length) {
                return mid;
            }
            if (location < range.location) {
                hi = mid - 1;
            } else {
                lo = mid + 1;
            }
        }
    }
    return NSNotFound;
}

- (CGPoint)linePositionForPosition:(NOCMTextPosition *)position
{
    NSUInteger lineIndex = [self lineIndexForPosition:position];
    if (lineIndex == NSNotFound) return CGPointZero;
    NOCMTextLine *line = _lines[lineIndex];
    CGFloat offset = [self offsetForTextPosition:position.offset lineIndex:lineIndex];
    if (offset == CGFLOAT_MAX) return CGPointZero;
    return CGPointMake(offset, line.position.y);
}

- (CGRect)caretRectForPosition:(NOCMTextPosition *)position
{
    NSUInteger lineIndex = [self lineIndexForPosition:position];
    if (lineIndex == NSNotFound) return CGRectNull;
    NOCMTextLine *line = _lines[lineIndex];
    CGFloat offset = [self offsetForTextPosition:position.offset lineIndex:lineIndex];
    if (offset == CGFLOAT_MAX) return CGRectNull;
    return CGRectMake(offset, line.bounds.origin.y, 0, line.bounds.size.height);
}

- (CGRect)firstRectForRange:(NOCMTextRange *)range
{
    range = [self _correctedRangeWithEdge:range];
    
    NSUInteger startLineIndex = [self lineIndexForPosition:range.start];
    NSUInteger endLineIndex = [self lineIndexForPosition:range.end];
    if (startLineIndex == NSNotFound || endLineIndex == NSNotFound) return CGRectNull;
    if (startLineIndex > endLineIndex) return CGRectNull;
    NOCMTextLine *startLine = _lines[startLineIndex];
    NOCMTextLine *endLine = _lines[endLineIndex];
    NSMutableArray *lines = [NSMutableArray new];
    for (NSUInteger i = startLineIndex; i <= startLineIndex; i++) {
        NOCMTextLine *line = _lines[i];
        if (line.row != startLine.row) break;
        [lines addObject:line];
    }
    
    if (lines.count == 1) {
        CGFloat left = [self offsetForTextPosition:range.start.offset lineIndex:startLineIndex];
        CGFloat right;
        if (startLine == endLine) {
            right = [self offsetForTextPosition:range.end.offset lineIndex:startLineIndex];
        } else {
            right = startLine.right;
        }
        if (left == CGFLOAT_MAX || right == CGFLOAT_MAX) return CGRectNull;
        if (left > right) {
            CGFloat temp = left;
            left = right;
            right = temp;
        }
        return CGRectMake(left, startLine.top, right - left, startLine.height);
    } else {
        CGFloat left = [self offsetForTextPosition:range.start.offset lineIndex:startLineIndex];
        CGFloat right = startLine.right;
        if (left == CGFLOAT_MAX || right == CGFLOAT_MAX) return CGRectNull;
        if (left > right) {
            CGFloat temp = left;
            left = right;
            right = temp;
        }
        CGRect rect = CGRectMake(left, startLine.top, right - left, startLine.height);
        for (NSUInteger i = 1; i < lines.count; i++) {
            NOCMTextLine *line = lines[i];
            rect = CGRectUnion(rect, line.bounds);
        }
        return rect;
    }
}

- (CGRect)rectForRange:(NOCMTextRange *)range
{
    NSArray *rects = [self selectionRectsForRange:range];
    if (rects.count == 0) return CGRectNull;
    CGRect rectUnion = ((NOCMTextSelectionRect *)rects.firstObject).rect;
    for (NSUInteger i = 1; i < rects.count; i++) {
        NOCMTextSelectionRect *rect = rects[i];
        rectUnion = CGRectUnion(rectUnion, rect.rect);
    }
    return rectUnion;
}

- (NSArray<NOCMTextSelectionRect *> *)selectionRectsForRange:(NOCMTextRange *)range
{
    range = [self _correctedRangeWithEdge:range];
    
    NSMutableArray *rects = [NSMutableArray array];
    if (!range) return rects;
    
    NSUInteger startLineIndex = [self lineIndexForPosition:range.start];
    NSUInteger endLineIndex = [self lineIndexForPosition:range.end];
    if (startLineIndex == NSNotFound || endLineIndex == NSNotFound) return rects;
    if (startLineIndex > endLineIndex) {
        NSUInteger temp = startLineIndex;
        startLineIndex = endLineIndex;
        endLineIndex = temp;
    }
    NOCMTextLine *startLine = _lines[startLineIndex];
    NOCMTextLine *endLine = _lines[endLineIndex];
    CGFloat offsetStart = [self offsetForTextPosition:range.start.offset lineIndex:startLineIndex];
    CGFloat offsetEnd = [self offsetForTextPosition:range.end.offset lineIndex:endLineIndex];
    
    NOCMTextSelectionRect *start = [NOCMTextSelectionRect new];
    start.rect = CGRectMake(offsetStart, startLine.top, 0, startLine.height);
    start.containsStart = YES;
    [rects addObject:start];
    
    NOCMTextSelectionRect *end = [NOCMTextSelectionRect new];
    end.rect = CGRectMake(offsetEnd, endLine.top, 0, endLine.height);
    end.containsEnd = YES;
    [rects addObject:end];
    
    if (startLine.row == endLine.row) { // same row
        if (offsetStart > offsetEnd) {
            CGFloat temp = offsetStart;
            offsetStart = offsetEnd;
            offsetEnd = temp;
        }
        NOCMTextSelectionRect *rect = [NOCMTextSelectionRect new];
        rect.rect = CGRectMake(offsetStart, startLine.bounds.origin.y, offsetEnd - offsetStart, MAX(startLine.height, endLine.height));
        [rects addObject:rect];
        
    } else { // more than one row
        
        // start line select rect
        NOCMTextSelectionRect *topRect = [NOCMTextSelectionRect new];
        CGFloat topOffset = [self offsetForTextPosition:range.start.offset lineIndex:startLineIndex];
        CTRunRef topRun = [self _runForLine:startLine position:range.start];
        if (topRun && (CTRunGetStatus(topRun) & kCTRunStatusRightToLeft)) {
            topRect.rect = CGRectMake(_container.path ? startLine.left : _container.insets.left, startLine.top, topOffset - startLine.left, startLine.height);
            topRect.writingDirection = UITextWritingDirectionRightToLeft;
        } else {
            topRect.rect = CGRectMake(topOffset, startLine.top, (_container.path ? startLine.right : _container.size.width - _container.insets.right) - topOffset, startLine.height);
        }
        [rects addObject:topRect];
        
        // end line select rect
        NOCMTextSelectionRect *bottomRect = [NOCMTextSelectionRect new];
        CGFloat bottomOffset = [self offsetForTextPosition:range.end.offset lineIndex:endLineIndex];
        CTRunRef bottomRun = [self _runForLine:endLine position:range.end];
        if (bottomRun && (CTRunGetStatus(bottomRun) & kCTRunStatusRightToLeft)) {
            bottomRect.rect = CGRectMake(bottomOffset, endLine.top, (_container.path ? endLine.right : _container.size.width - _container.insets.right) - bottomOffset, endLine.height);
            bottomRect.writingDirection = UITextWritingDirectionRightToLeft;
        } else {
            CGFloat left = _container.path ? endLine.left : _container.insets.left;
            bottomRect.rect = CGRectMake(left, endLine.top, bottomOffset - left, endLine.height);
        }
        [rects addObject:bottomRect];
        
        if (endLineIndex - startLineIndex >= 2) {
            CGRect r = CGRectZero;
            BOOL startLineDetected = NO;
            for (NSUInteger l = startLineIndex + 1; l < endLineIndex; l++) {
                NOCMTextLine *line = _lines[l];
                if (line.row == startLine.row || line.row == endLine.row) continue;
                if (!startLineDetected) {
                    r = line.bounds;
                    startLineDetected = YES;
                } else {
                    r = CGRectUnion(r, line.bounds);
                }
            }
        if (startLineDetected) {
                if (!_container.path) {
                    r.origin.x = _container.insets.left;
                    r.size.width = _container.size.width - _container.insets.right - _container.insets.left;
                }
                r.origin.y = CGRectGetMaxY(topRect.rect);
                r.size.height = bottomRect.rect.origin.y - r.origin.y;
                
                NOCMTextSelectionRect *rect = [NOCMTextSelectionRect new];
                rect.rect = r;
                [rects addObject:rect];
            }
        } else {
            CGRect r0 = topRect.rect;
            CGRect r1 = bottomRect.rect;
            CGFloat mid = (CGRectGetMaxY(r0) + CGRectGetMinY(r1)) * 0.5;
            r0.size.height = mid - r0.origin.y;
            CGFloat r1ofs = r1.origin.y - mid;
            r1.origin.y -= r1ofs;
            r1.size.height += r1ofs;
            topRect.rect = r0;
            bottomRect.rect = r1;
        }
    }
    return rects;
}

- (NSArray<NOCMTextSelectionRect *> *)selectionRectsWithoutStartAndEndForRange:(NOCMTextRange *)range
{
    NSMutableArray *rects = [self selectionRectsForRange:range].mutableCopy;
    for (NSInteger i = 0, max = rects.count; i < max; i++) {
        NOCMTextSelectionRect *rect = rects[i];
        if (rect.containsStart || rect.containsEnd) {
            [rects removeObjectAtIndex:i];
            i--;
            max--;
        }
    }
    return rects;
}

- (NSArray<NOCMTextSelectionRect *> *)selectionRectsWithOnlyStartAndEndForRange:(NOCMTextRange *)range
{
    NSMutableArray *rects = [self selectionRectsForRange:range].mutableCopy;
    for (NSInteger i = 0, max = rects.count; i < max; i++) {
        NOCMTextSelectionRect *rect = rects[i];
        if (!rect.containsStart && !rect.containsEnd) {
            [rects removeObjectAtIndex:i];
            i--;
            max--;
        }
    }
    return rects;
}

#pragma mark - Copying

- (id)copyWithZone:(NSZone *)zone
{
    return self; // readonly object
}

#pragma mark - Draw

typedef NS_OPTIONS(NSUInteger, NOCMTextBorderType) {
    NOCMTextBorderTypeBackgound = 1 << 0,
    NOCMTextBorderTypeNormal    = 1 << 1,
};

static CGRect NOCMTextMergeRectInSameLine(CGRect rect1, CGRect rect2)
{
    CGFloat left = MIN(rect1.origin.x, rect2.origin.x);
    CGFloat right = MAX(rect1.origin.x + rect1.size.width, rect2.origin.x + rect2.size.width);
    CGFloat height = MAX(rect1.size.height, rect2.size.height);
    return CGRectMake(left, rect1.origin.y, right - left, height);
}

static void NOCMTextDrawRun(NOCMTextLine *line, CTRunRef run, CGContextRef context, CGSize size, CGFloat verticalOffset)
{
    CGAffineTransform runTextMatrix = CTRunGetTextMatrix(run);
    BOOL runTextMatrixIsID = CGAffineTransformIsIdentity(runTextMatrix);
    
    if (!runTextMatrixIsID) {
        CGContextSaveGState(context);
        CGAffineTransform trans = CGContextGetTextMatrix(context);
        CGContextSetTextMatrix(context, CGAffineTransformConcat(trans, runTextMatrix));
    }
    CTRunDraw(run, context, CFRangeMake(0, 0));
    if (!runTextMatrixIsID) {
        CGContextRestoreGState(context);
    }
}

static void NOCMTextDrawText(NOCMTextLayout *layout, CGContextRef context, CGSize size, CGPoint point, BOOL (^cancel)(void))
{
    CGContextSaveGState(context);
    {
        CGContextTranslateCTM(context, point.x, point.y);
        CGContextTranslateCTM(context, 0, size.height);
        CGContextScaleCTM(context, 1, -1);
        
        CGFloat verticalOffset = 0;
        
        NSArray *lines = layout.lines;
        for (NSUInteger l = 0, lMax = lines.count; l < lMax; l++) {
            NOCMTextLine *line = lines[l];
            if (layout.truncatedLine && layout.truncatedLine.index == line.index) line = layout.truncatedLine;
            CGFloat posX = line.position.x + verticalOffset;
            CGFloat posY = size.height - line.position.y;
            CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
            for (NSUInteger r = 0, rMax = CFArrayGetCount(runs); r < rMax; r++) {
                CTRunRef run = CFArrayGetValueAtIndex(runs, r);
                CGContextSetTextMatrix(context, CGAffineTransformIdentity);
                CGContextSetTextPosition(context, posX, posY);
                NOCMTextDrawRun(line, run, context, size, verticalOffset);
            }
            if (cancel && cancel()) break;
        }
        
        // Use this to draw frame for test/debug.
        // CGContextTranslateCTM(context, verticalOffset, size.height);
        // CTFrameDraw(layout.frame, context);
        
    }
    CGContextRestoreGState(context);
}

static void NOCMTextDrawBorder(NOCMTextLayout *layout, CGContextRef context, CGSize size, CGPoint point, NOCMTextBorderType type, BOOL (^cancel)(void))
{
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, point.x, point.y);
    
    CGFloat verticalOffset = 0;
    
    NSArray *lines = layout.lines;
    NSString *borderKey = (type == NOCMTextBorderTypeNormal ? NOCMTextBorderAttributeName : NOCMTextBackgroundBorderAttributeName);
    
    BOOL needJumpRun = NO;
    NSUInteger jumpRunIndex = 0;
    
    for (NSInteger l = 0, lMax = lines.count; l < lMax; l++) {
        if (cancel && cancel()) break;
        
        NOCMTextLine *line = lines[l];
        if (layout.truncatedLine && layout.truncatedLine.index == line.index) line = layout.truncatedLine;
        CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
        for (NSInteger r = 0, rMax = CFArrayGetCount(runs); r < rMax; r++) {
            if (needJumpRun) {
                needJumpRun = NO;
                r = jumpRunIndex + 1;
                if (r >= rMax) break;
            }
            
            CTRunRef run = CFArrayGetValueAtIndex(runs, r);
            CFIndex glyphCount = CTRunGetGlyphCount(run);
            if (glyphCount == 0) continue;
            
            NSDictionary *attrs = (id)CTRunGetAttributes(run);
            NOCMTextBorder *border = attrs[borderKey];
            if (!border) continue;
            
            CFRange runRange = CTRunGetStringRange(run);
            if (runRange.location == kCFNotFound || runRange.length == 0) continue;
            if (runRange.location + runRange.length > layout.text.length) continue;
            
            NSMutableArray *runRects = [NSMutableArray new];
            NSInteger endLineIndex = l;
            NSInteger endRunIndex = r;
            BOOL endFound = NO;
            for (NSInteger ll = l; ll < lMax; ll++) {
                if (endFound) break;
                NOCMTextLine *iLine = lines[ll];
                CFArrayRef iRuns = CTLineGetGlyphRuns(iLine.CTLine);
                
                CGRect extLineRect = CGRectNull;
                for (NSInteger rr = (ll == l) ? r : 0, rrMax = CFArrayGetCount(iRuns); rr < rrMax; rr++) {
                    CTRunRef iRun = CFArrayGetValueAtIndex(iRuns, rr);
                    NSDictionary *iAttrs = (id)CTRunGetAttributes(iRun);
                    NOCMTextBorder *iBorder = iAttrs[borderKey];
                    if (![border isEqual:iBorder]) {
                        endFound = YES;
                        break;
                    }
                    endLineIndex = ll;
                    endRunIndex = rr;
                    
                    CGPoint iRunPosition = CGPointZero;
                    CTRunGetPositions(iRun, CFRangeMake(0, 1), &iRunPosition);
                    CGFloat ascent, descent;
                    CGFloat iRunWidth = CTRunGetTypographicBounds(iRun, CFRangeMake(0, 0), &ascent, &descent, NULL);
                    
                    iRunPosition.x += iLine.position.x;
                    CGRect iRect = CGRectMake(iRunPosition.x, iLine.position.y - ascent, iRunWidth, ascent + descent);
                    if (CGRectIsNull(extLineRect)) {
                        extLineRect = iRect;
                    } else {
                        extLineRect = CGRectUnion(extLineRect, iRect);
                    }
                }
                
                if (!CGRectIsNull(extLineRect)) {
                    [runRects addObject:[NSValue valueWithCGRect:extLineRect]];
                }
            }
            
            NSMutableArray *drawRects = [NSMutableArray new];
            CGRect curRect= ((NSValue *)[runRects firstObject]).CGRectValue;
            for (NSInteger re = 0, reMax = runRects.count; re < reMax; re++) {
                CGRect rect = ((NSValue *)runRects[re]).CGRectValue;
                if (fabs(rect.origin.y - curRect.origin.y) < 1) {
                    curRect = NOCMTextMergeRectInSameLine(rect, curRect);
                } else {
                    [drawRects addObject:[NSValue valueWithCGRect:curRect]];
                    curRect = rect;
                }
            }
            if (!CGRectEqualToRect(curRect, CGRectZero)) {
                [drawRects addObject:[NSValue valueWithCGRect:curRect]];
            }
            
            NOCMTextDrawBorderRects(context, size, border, drawRects);
            
            if (l == endLineIndex) {
                r = endRunIndex;
            } else {
                l = endLineIndex - 1;
                needJumpRun = YES;
                jumpRunIndex = endRunIndex;
                break;
            }
            
        }
    }
    
    CGContextRestoreGState(context);
}

static inline CGPoint NOCMCGPointPixelRound(CGPoint point)
{
    CGFloat scale = [UIScreen mainScreen].scale;
    return CGPointMake(round(point.x * scale) / scale,
                       round(point.y * scale) / scale);
}

static inline CGRect NOCMCGRectPixelRound(CGRect rect)
{
    CGPoint origin = NOCMCGPointPixelRound(rect.origin);
    CGPoint corner = NOCMCGPointPixelRound(CGPointMake(rect.origin.x + rect.size.width,
                                                       rect.origin.y + rect.size.height));
    return CGRectMake(origin.x, origin.y, corner.x - origin.x, corner.y - origin.y);
}

static void NOCMTextDrawBorderRects(CGContextRef context, CGSize size, NOCMTextBorder *border, NSArray *rects)
{
    if (rects.count == 0) return;
    
    NSMutableArray *paths = [NSMutableArray new];
    for (NSValue *value in rects) {
        CGRect rect = value.CGRectValue;
        rect = UIEdgeInsetsInsetRect(rect, border.insets);
        rect = NOCMCGRectPixelRound(rect);
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:border.cornerRadius];
        [path closePath];
        [paths addObject:path];
    }
    
    if (border.fillColor) {
        CGContextSaveGState(context);
        CGContextSetFillColorWithColor(context, border.fillColor.CGColor);
        for (UIBezierPath *path in paths) {
            CGContextAddPath(context, path.CGPath);
        }
        CGContextFillPath(context);
        CGContextRestoreGState(context);
    }
}

- (void)drawInContext:(CGContextRef)context size:(CGSize)size point:(CGPoint)point view:(UIView *)view layer:(CALayer *)layer cancel:(BOOL (^)(void))cancel
{
    @autoreleasepool {
        if (self.needDrawBackgroundBorder && context) {
            if (cancel && cancel()) return;
            NOCMTextDrawBorder(self, context, size, point, NOCMTextBorderTypeBackgound, cancel);
        }
        if (self.needDrawText && context) {
            if (cancel && cancel()) return;
            NOCMTextDrawText(self, context, size, point, cancel);
        }
        if (self.needDrawBorder && context) {
            if (cancel && cancel()) return;
            NOCMTextDrawBorder(self, context, size, point, NOCMTextBorderTypeNormal, cancel);
        }
    }
}

@end

#pragma mark - NOCMTextPosition

@implementation NOCMTextPosition

+ (instancetype)positionWithOffset:(NSInteger)offset
{
    return [self positionWithOffset:offset affinity:NOCMTextAffinityForward];
}

+ (instancetype)positionWithOffset:(NSInteger)offset affinity:(NOCMTextAffinity)affinity
{
    NOCMTextPosition *p = [self new];
    p->_offset = offset;
    p->_affinity = affinity;
    return p;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    return [self.class positionWithOffset:_offset affinity:_affinity];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p> (%@%@)", self.class, self, @(_offset), _affinity == NOCMTextAffinityForward ? @"F":@"B"];
}

- (NSUInteger)hash
{
    return _offset * 2 + (_affinity == NOCMTextAffinityForward ? 1 : 0);
}

- (BOOL)isEqual:(NOCMTextPosition *)object
{
    if (!object) return NO;
    return _offset == object.offset && _affinity == object.affinity;
}

- (NSComparisonResult)compare:(NOCMTextPosition *)otherPosition
{
    if (!otherPosition) return NSOrderedAscending;
    if (_offset < otherPosition.offset) return NSOrderedAscending;
    if (_offset > otherPosition.offset) return NSOrderedDescending;
    if (_affinity == NOCMTextAffinityBackward && otherPosition.affinity == NOCMTextAffinityForward) return NSOrderedAscending;
    if (_affinity == NOCMTextAffinityForward && otherPosition.affinity == NOCMTextAffinityBackward) return NSOrderedDescending;
    return NSOrderedSame;
}

@end

#pragma mark - NOCMTextRange

@implementation NOCMTextRange {
    NOCMTextPosition *_start;
    NOCMTextPosition *_end;
}

- (instancetype)init
{
    self = [super init];
    if (!self) return nil;
    _start = [NOCMTextPosition positionWithOffset:0];
    _end = [NOCMTextPosition positionWithOffset:0];
    return self;
}

- (NOCMTextPosition *)start
{
    return _start;
}

- (NOCMTextPosition *)end
{
    return _end;
}

- (BOOL)isEmpty
{
    return _start.offset == _end.offset;
}

- (NSRange)asRange
{
    return NSMakeRange(_start.offset, _end.offset - _start.offset);
}

+ (instancetype)rangeWithRange:(NSRange)range
{
    return [self rangeWithRange:range affinity:NOCMTextAffinityForward];
}

+ (instancetype)rangeWithRange:(NSRange)range affinity:(NOCMTextAffinity)affinity
{
    NOCMTextPosition *start = [NOCMTextPosition positionWithOffset:range.location affinity:affinity];
    NOCMTextPosition *end = [NOCMTextPosition positionWithOffset:range.location + range.length affinity:affinity];
    return [self rangeWithStart:start end:end];
}

+ (instancetype)rangeWithStart:(NOCMTextPosition *)start end:(NOCMTextPosition *)end
{
    if (!start || !end) return nil;
    if ([start compare:end] == NSOrderedDescending) {
        NOCMTextPosition *temp = start;
        start = end;
        end = temp;
    }
    NOCMTextRange *range = [NOCMTextRange new];
    range->_start = start;
    range->_end = end;
    return range;
}

+ (instancetype)defaultRange
{
    return [self new];
}

- (instancetype)copyWithZone:(NSZone *)zone {
    return [self.class rangeWithStart:_start end:_end];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p> (%@, %@)%@", self.class, self, @(_start.offset), @(_end.offset - _start.offset), _end.affinity == NOCMTextAffinityForward ? @"F":@"B"];
}

- (NSUInteger)hash
{
    return (sizeof(NSUInteger) == 8 ? OSSwapInt64(_start.hash) : OSSwapInt32(_start.hash)) + _end.hash;
}

- (BOOL)isEqual:(NOCMTextRange *)object
{
    if (!object) return NO;
    return [_start isEqual:object.start] && [_end isEqual:object.end];
}

@end

#pragma mark - NOCMTextSelectionRect

@implementation NOCMTextSelectionRect

@synthesize rect = _rect;
@synthesize writingDirection = _writingDirection;
@synthesize containsStart = _containsStart;
@synthesize containsEnd = _containsEnd;

- (id)copyWithZone:(NSZone *)zone
{
    NOCMTextSelectionRect *one = [self.class new];
    one.rect = _rect;
    one.writingDirection = _writingDirection;
    one.containsStart = _containsStart;
    one.containsEnd = _containsEnd;
    return one;
}

@end

#pragma mark - NOCMTextAttachment

NSString *const NOCMTextBackedStringAttributeName = @"NOCMTextBackedString";
NSString *const NOCMTextBindingAttributeName = @"NOCMTextBinding";
NSString *const NOCMTextShadowAttributeName = @"NOCMTextShadow";
NSString *const NOCMTextInnerShadowAttributeName = @"NOCMTextInnerShadow";
NSString *const NOCMTextUnderlineAttributeName = @"NOCMTextUnderline";
NSString *const NOCMTextStrikethroughAttributeName = @"NOCMTextStrikethrough";
NSString *const NOCMTextBorderAttributeName = @"NOCMTextBorder";
NSString *const NOCMTextBackgroundBorderAttributeName = @"NOCMTextBackgroundBorder";
NSString *const NOCMTextBlockBorderAttributeName = @"NOCMTextBlockBorder";
NSString *const NOCMTextAttachmentAttributeName = @"NOCMTextAttachment";
NSString *const NOCMTextHighlightAttributeName = @"NOCMTextHighlight";
NSString *const NOCMTextGlyphTransformAttributeName = @"NOCMTextGlyphTransform";

NSString *const NOCMTextAttachmentToken = @"\uFFFC";
NSString *const NOCMTextTruncationToken = @"\u2026";

@implementation NOCMTextBorder

+ (instancetype)borderWithLineStyle:(NOCMTextLineStyle)lineStyle lineWidth:(CGFloat)width strokeColor:(UIColor *)color
{
    NOCMTextBorder *one = [self new];
    one.lineStyle = lineStyle;
    one.strokeWidth = width;
    one.strokeColor = color;
    return one;
}

+ (instancetype)borderWithFillColor:(UIColor *)color cornerRadius:(CGFloat)cornerRadius
{
    NOCMTextBorder *one = [self new];
    one.fillColor = color;
    one.cornerRadius = cornerRadius;
    one.insets = UIEdgeInsetsMake(-2, 0, 0, -2);
    return one;
}

- (instancetype)init
{
    self = [super init];
    self.lineStyle = NOCMTextLineStyleSingle;
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    typeof(self) one = [self.class new];
    one.lineStyle = self.lineStyle;
    one.strokeWidth = self.strokeWidth;
    one.strokeColor = self.strokeColor;
    one.lineJoin = self.lineJoin;
    one.insets = self.insets;
    one.cornerRadius = self.cornerRadius;
    one.fillColor = self.fillColor;
    return one;
}

@end

@implementation NOCMTextAttachment

+ (instancetype)attachmentWithContent:(id)content
{
    NOCMTextAttachment *one = [self new];
    one.content = content;
    return one;
}

- (id)copyWithZone:(NSZone *)zone
{
    typeof(self) one = [self.class new];
    if ([self.content respondsToSelector:@selector(copy)]) {
        one.content = [self.content copy];
    } else {
        one.content = self.content;
    }
    one.contentInsets = self.contentInsets;
    one.userInfo = self.userInfo.copy;
    return one;
}

@end

#pragma mark - NOCMTextHighlight

@implementation NOCMTextHighlight

+ (instancetype)highlightWithAttributes:(NSDictionary *)attributes
{
    NOCMTextHighlight *one = [self new];
    one.attributes = attributes;
    return one;
}

+ (instancetype)highlightWithBackgroundColor:(UIColor *)color
{
    NOCMTextBorder *highlightBorder = [NOCMTextBorder new];
    highlightBorder.insets = UIEdgeInsetsMake(-2, -1, -2, -1);
    highlightBorder.cornerRadius = 3;
    highlightBorder.fillColor = color;
    
    NOCMTextHighlight *one = [self new];
    [one setBackgroundBorder:highlightBorder];
    return one;
}

- (void)setAttributes:(NSDictionary *)attributes
{
    _attributes = attributes.mutableCopy;
}

- (id)copyWithZone:(NSZone *)zone
{
    typeof(self) one = [self.class new];
    one.attributes = self.attributes.mutableCopy;
    return one;
}

- (void)_makeMutableAttributes
{
    if (!_attributes) {
        _attributes = [NSMutableDictionary new];
    } else if (![_attributes isKindOfClass:[NSMutableDictionary class]]) {
        _attributes = _attributes.mutableCopy;
    }
}

- (void)setTextAttribute:(NSString *)attribute value:(id)value
{
    [self _makeMutableAttributes];
    if (value == nil) value = [NSNull null];
    ((NSMutableDictionary *)_attributes)[attribute] = value;
}

- (void)setBackgroundBorder:(NOCMTextBorder *)border
{
    [self setTextAttribute:NOCMTextBackgroundBorderAttributeName value:border];
}

@end
