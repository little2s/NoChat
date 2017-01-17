//
//  NOCMTextLabel.m
//  NoChat-Example
//
//  Created by little2s on 2016/12/25.
//  Copyright © 2016年 little2s. All rights reserved.
//

#import "NOCMTextLabel.h"
#import <libkern/OSAtomic.h>
#import "NSAttributedString+NOCMinimal.h"
#import "UIFont+NOCMinimal.h"

#pragma mark - NOCMSentinel

@interface NOCMSentinel : NSObject
@property (nonatomic, readonly, assign) int32_t value;
- (int32_t)increase;
@end

@implementation NOCMSentinel {
    int32_t _value;
}

- (int32_t)value
{
    return _value;
}

- (int32_t)increase
{
    return OSAtomicIncrement32(&_value);
}

@end

#pragma mark - NOCMAsyncLayer

static dispatch_queue_t NOCMAsyncLayerDisplayQueue()
{
#define MAX_QUEUE_COUNT 16
    static int queueCount;
    static dispatch_queue_t queues[MAX_QUEUE_COUNT];
    static dispatch_once_t onceToken;
    static int32_t counter = 0;
    dispatch_once(&onceToken, ^{
        queueCount = (int)[NSProcessInfo processInfo].activeProcessorCount;
        queueCount = queueCount < 1 ? 1 : queueCount > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : queueCount;
        for (NSUInteger i = 0; i < queueCount; i++) {
            dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, 0);
            queues[i] = dispatch_queue_create("com.little2s.minimal.render", attr);
        }
    });
    int32_t cur = OSAtomicIncrement32(&counter);
    if (cur < 0) {
        cur = -cur;
    }
    return queues[(cur) % queueCount];
#undef MAX_QUEUE_COUNT
}

static dispatch_queue_t NOCMAsyncLayerReleaseQueue()
{
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
}

@interface NOCMAsyncLayerDisplayTask : NSObject

@property (nonatomic, copy) void (^willDisplay)(CALayer *layer);
@property (nonatomic, copy) void (^display)(CGContextRef context, CGSize size, BOOL(^isCancelled)(void));
@property (nonatomic, copy) void (^didDisplay)(CALayer *layer, BOOL finished);

@end

@implementation NOCMAsyncLayerDisplayTask

@end

@protocol NOCMAsyncLayerDelegate <NSObject>

@required
- (NOCMAsyncLayerDisplayTask *)newAsyncDisplayTask;

@end

@interface NOCMAsyncLayer : CALayer

@end

@implementation NOCMAsyncLayer {
    NOCMSentinel *_sentinel;
}

- (void)dealloc
{
    [_sentinel increase];
}

- (instancetype)init
{
    self = [super init];
    
    static CGFloat scale;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        scale = [UIScreen mainScreen].scale;
    });
    
    if (self) {
        self.contentsScale = scale;
        _sentinel = [[NOCMSentinel alloc] init];
    }
    return self;
}

- (void)setNeedsDisplay
{
    [self cancelAsyncDisplay];
    [super setNeedsDisplay];
}

- (void)display
{
    super.contents = super.contents;
    [self displayAsync];
}

- (void)displayAsync
{
    __strong id<NOCMAsyncLayerDelegate> delegate = (id<NOCMAsyncLayerDelegate>)self.delegate;
    NOCMAsyncLayerDisplayTask *task = [delegate newAsyncDisplayTask];
    if (!task.display) {
        if (task.willDisplay) {
            task.willDisplay(self);
        }
        self.contents = nil;
        if (task.didDisplay) {
            task.didDisplay(self, YES);
        }
        return;
    }
    
    if (task.willDisplay) {
        task.willDisplay(self);
    }
    NOCMSentinel *sentinel = _sentinel;
    int32_t value = sentinel.value;
    BOOL (^isCancelled)() = ^BOOL() {
        return value != sentinel.value;
    };
    CGSize size = self.bounds.size;
    BOOL opaque = self.opaque;
    CGFloat scale = self.contentsScale;
    CGColorRef backgroundColor = (opaque && self.backgroundColor) ? CGColorRetain(self.backgroundColor) : NULL;
    if (size.width < 1 || size.height < 1) {
        CGImageRef image = (__bridge_retained CGImageRef)(self.contents);
        self.contents = nil;
        if (image) {
            dispatch_async(NOCMAsyncLayerReleaseQueue(), ^{
                CFRelease(image);
            });
        }
        if (task.didDisplay) {
            task.didDisplay(self, YES);
        }
        CGColorRelease(backgroundColor);
        return;
    }
    
    dispatch_async(NOCMAsyncLayerDisplayQueue(), ^{
        if (isCancelled()) {
            CGColorRelease(backgroundColor);
            return;
        }
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (opaque) {
            CGContextSaveGState(context);
            {
                if (!backgroundColor || CGColorGetAlpha(backgroundColor) < 1) {
                    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
                    CGContextAddRect(context, CGRectMake(0, 0, size.width * scale, size.height * scale));
                    CGContextFillPath(context);
                }
                if (backgroundColor) {
                    CGContextSetFillColorWithColor(context, backgroundColor);
                    CGContextAddRect(context, CGRectMake(0, 0, size.width * scale, size.height * scale));
                    CGContextFillPath(context);
                }
            }
            CGContextRestoreGState(context);
            CGColorRelease(backgroundColor);
        }
        task.display(context, size, isCancelled);
        if (isCancelled()) {
            UIGraphicsEndImageContext();
            dispatch_async(dispatch_get_main_queue(), ^{
                if (task.didDisplay) {
                    task.didDisplay(self, NO);
                }
            });
            return;
        }
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        if (isCancelled()) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (task.didDisplay) {
                    task.didDisplay(self, NO);
                }
            });
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isCancelled()) {
                if (task.didDisplay) {
                    task.didDisplay(self, NO);
                }
            } else {
                self.contents = (__bridge id)(image.CGImage);
                if (task.didDisplay) {
                    task.didDisplay(self, YES);
                }
            }
        });
    });
}

- (void)cancelAsyncDisplay
{
    [_sentinel increase];
}

@end

#pragma mark - NOCMTextLabel

#define kLongPressMinimumDuration 0.5
#define kLongPressAllowableMovement 9.0

static dispatch_queue_t NOCMTextLabelReleaseQueue()
{
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
}

@interface NOCMTextLabel () <NOCMAsyncLayerDelegate> {
    NSMutableAttributedString *_innerText;
    NOCMTextContainer *_innerContainer;
    NOCMTextLayout *_innerLayout;
    
    NSMutableArray *_attachmentViews;
    NSMutableArray *_attachmentLayers;
    
    NSRange _highlightRange;
    NOCMTextHighlight *_highlight;
    NOCMTextLayout *_highlightLayout;
    
    NSTimer *_longPressTimer;
    CGPoint _touchBeganPoint;
    
    struct {
        unsigned int layoutNeedUpdate : 1;
        unsigned int showingHighlight : 1;
        
        unsigned int trackingTouch : 1;
        unsigned int swallowTouch : 1;
        unsigned int touchMoved : 1;
        
        unsigned int hasTapAction : 1;
        unsigned int hasLongPressAction : 1;
    } _state;
}

@end

@implementation NOCMTextLabel

#pragma mark - Override

+ (Class)layerClass
{
    return [NOCMAsyncLayer class];
}

- (void)dealloc
{
    [_longPressTimer invalidate];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        [self commonInit];
        self.frame = frame;
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    CGSize oldSize = self.bounds.size;
    [super setFrame:frame];
    CGSize newSize = self.bounds.size;
    if (!CGSizeEqualToSize(oldSize, newSize)) {
        _innerContainer.size = self.bounds.size;
        [self clearContents];
        [self setLayoutNeedRedraw];
    }
}

- (void)setBounds:(CGRect)bounds
{
    CGSize oldSize = self.bounds.size;
    [super setBounds:bounds];
    CGSize newSize = self.bounds.size;
    if (!CGSizeEqualToSize(oldSize, newSize)) {
        _innerContainer.size = self.bounds.size;
        [self clearContents];
        [self setLayoutNeedRedraw];
    }
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return _innerLayout.textBoundingSize;
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self updateIfNeeded];
    
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    
    _highlight = [self highlightAtPoint:point range:&_highlightRange];
    _highlightLayout = nil;
    
    if (_highlight || _tapAction || _longPressAction) {
        _touchBeganPoint = point;
        _state.trackingTouch = YES;
        _state.swallowTouch = YES;
        _state.touchMoved = NO;
        [self startLongPressTimer];
        if (_highlight) {
            [self showHighlightAnimated:NO];
        }
    } else {
        _state.trackingTouch = NO;
        _state.swallowTouch = NO;
        _state.touchMoved = NO;
    }
    
    if (!_state.swallowTouch) {
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self updateIfNeeded];
    
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    
    if (_state.trackingTouch) {
        if (!_state.touchMoved) {
            CGFloat moveX = point.x - _touchBeganPoint.x;
            CGFloat moveY = point.y - _touchBeganPoint.y;
            if (fabs(moveX) > fabs(moveY)) {
                if (fabs(moveX) > kLongPressAllowableMovement) {
                    _state.touchMoved = YES;
                }
            } else {
                if (fabs(moveY) > kLongPressAllowableMovement) {
                    _state.touchMoved = YES;
                }
            }
            if (_state.touchMoved) {
                [self endLongPressTimer];
            }
        }
        if (_state.touchMoved && _highlight) {
            NOCMTextHighlight *highlight = [self highlightAtPoint:point range:nil];
            if (highlight == _highlight) {
                [self showHighlightAnimated:NO];
            } else {
                [self showHighlightAnimated:NO];
            }
        }
    }
    
    if (!_state.swallowTouch) {
        [super touchesMoved:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    
    if (_state.trackingTouch) {
        [self endLongPressTimer];
        if (!_state.touchMoved && _tapAction) {
            NSRange range = NSMakeRange(NSNotFound, 0);
            CGRect rect = CGRectNull;
            CGPoint point = [self convertPointToLayout:_touchBeganPoint];
            NOCMTextRange *textRange = [_innerLayout textRangeAtPoint:point];
            CGRect textRect = [_innerLayout rectForRange:textRange];
            textRect = [self convertRectFromLayout:textRect];
            if (textRange) {
                range = textRange.asRange;
                rect = textRect;
            }
            _tapAction(self, _innerText, range, rect);
        }
        if (_highlight) {
            if (!_state.touchMoved || [self highlightAtPoint:point range:nil] == _highlight) {
                NOCMTextAction tapAction = _tapAction;
                if (tapAction) {
                    NOCMTextPosition *start = [NOCMTextPosition positionWithOffset:_highlightRange.location];
                    NOCMTextPosition *end = [NOCMTextPosition positionWithOffset:_highlightRange.location + _highlightRange.length affinity:NOCMTextAffinityBackward];
                    NOCMTextRange *range = [NOCMTextRange rangeWithStart:start end:end];
                    CGRect rect = [_innerLayout rectForRange:range];
                    rect = [self convertRectFromLayout:rect];
                    tapAction(self, _innerText, _highlightRange, rect);
                }
            }
            [self removeHighlightAnimated:NO];
        }
    }
    
    if (!_state.swallowTouch) {
        [super touchesEnded:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self endTouch];
    if (!_state.swallowTouch) {
        [super touchesCancelled:touches withEvent:event];
    }
}

#pragma mark - NOCMAsyncLayerDelegate

- (NOCMAsyncLayerDisplayTask *)newAsyncDisplayTask
{
    NSAttributedString *text = _innerText;
    NOCMTextContainer *container = _innerContainer;
    NSMutableArray *attachmentViews = _attachmentViews;
    NSMutableArray *attachmentLayers = _attachmentLayers;
    BOOL layoutNeedUpdate = _state.layoutNeedUpdate;
    __block NOCMTextLayout *layout = (_state.showingHighlight && _highlightLayout) ? _highlightLayout : _innerLayout;
    __block BOOL layoutUpdated = NO;
    if (layoutNeedUpdate) {
        text = text.copy;
        container = container.copy;
    }
    
    NOCMAsyncLayerDisplayTask *task = [[NOCMAsyncLayerDisplayTask alloc] init];
    
    task.willDisplay = ^(CALayer *layer) {
        [layer removeAnimationForKey:@"contents"];
        
        for (UIView *view in attachmentViews) {
            if (layoutNeedUpdate || ![layout.attachmentContentsSet containsObject:view]) {
                if (view.superview == self) {
                    [view removeFromSuperview];
                }
            }
        }
        for (CALayer *layer in attachmentLayers) {
            if (layoutNeedUpdate || ![layout.attachmentContentsSet containsObject:layer]) {
                if (layer.superlayer == self.layer) {
                    [layer removeFromSuperlayer];
                }
            }
        }
        [attachmentViews removeAllObjects];
        [attachmentLayers removeAllObjects];
    };
    
    task.display = ^(CGContextRef context, CGSize size, BOOL (^isCancelled)(void)) {
        if (isCancelled() || text.length == 0) {
            return;
        }
        
        NOCMTextLayout *drawLayout = layout;
        if (layoutNeedUpdate) {
            layout = [NOCMTextLayout layoutWithContainer:container text:text];
            if (isCancelled()) {
                return;
            }
            layoutUpdated = YES;
            drawLayout = layout;
        }
        
        CGSize boundingSize = drawLayout.textBoundingSize;
        CGPoint point = CGPointZero;
        [drawLayout drawInContext:context size:size point:point view:nil layer:nil cancel:isCancelled];
    };
    
    task.didDisplay = ^(CALayer *layer, BOOL finished) {
        NOCMTextLayout *drawLayout = layout;
        if (!finished) {
            for (NOCMTextAttachment *attachment in drawLayout.attachments) {
                id content = attachment.content;
                if ([content isKindOfClass:[UIView class]]) {
                    UIView *aView = (UIView *)content;
                    if (aView.superview == layer.delegate) {
                        [aView removeFromSuperview];
                    }
                } else if ([content isKindOfClass:[CALayer class]]) {
                    CALayer *aLayer = (CALayer *)content;
                    if (aLayer.superlayer == layer) {
                        [aLayer removeFromSuperlayer];
                    }
                }
            }
            return;
        }
        [layer removeAnimationForKey:@"contents"];
        
        __strong NOCMTextLabel *view = (NOCMTextLabel *)layer.delegate;
        if (!view) {
            return;
        }
        if (view->_state.layoutNeedUpdate && layoutUpdated) {
            view->_innerLayout = layout;
            view->_state.layoutNeedUpdate = NO;
        }
        
        CGSize size = layer.bounds.size;
        CGSize boundingSize = drawLayout.textBoundingSize;
        CGPoint point = CGPointZero;
        
        [drawLayout drawInContext:nil size:size point:point view:view layer:layer cancel:nil];
        for (NOCMTextAttachment *attachment in drawLayout.attachments) {
            id content = attachment.content;
            if ([content isKindOfClass:[UIView class]]) {
                [attachmentViews addObject:content];
            } else if ([content isKindOfClass:[CALayer class]]) {
                [attachmentLayers addObject:content];
            }
        }
        
    };
    
    return task;
}

#pragma mark - Setters & Getters

- (void)setTextLayout:(NOCMTextLayout *)textLayout
{
    _innerLayout = textLayout;
    _innerText = (NSMutableAttributedString *)textLayout.text;
    _innerContainer = textLayout.container;
    [self clearContents];
    _state.layoutNeedUpdate = NO;
    [self setLayoutNeedRedraw];
    [self endTouch];
    [self invalidateIntrinsicContentSize];
}

- (NOCMTextLayout *)textLayout
{
    [self updateIfNeeded];
    return _innerLayout;
}

#pragma mark - Private

- (void)commonInit
{
    self.layer.contentsScale = [UIScreen mainScreen].scale;
    self.contentMode = UIViewContentModeRedraw;
    
    _attachmentViews = [NSMutableArray new];
    _attachmentLayers = [NSMutableArray new];
    
    _innerText = [NSMutableString new];
    _innerContainer = [NOCMTextContainer new];
}

- (void)clearContents
{
    CGImageRef image = (__bridge_retained CGImageRef)(self.layer.contents);
    self.layer.contents = nil;
    if (image) {
        dispatch_async(NOCMTextLabelReleaseQueue(), ^{
            CFRelease(image);
        });
    }
}

- (void)setLayoutNeedRedraw
{
    [self.layer setNeedsDisplay];
}

- (void)endTouch
{
    [self endLongPressTimer];
    [self removeHighlightAnimated:YES];
    _state.trackingTouch = NO;
}

- (void)updateIfNeeded
{
    if (_state.layoutNeedUpdate) {
        _state.layoutNeedUpdate = NO;
        [self updateLayout];
        [self.layer setNeedsDisplay];
    }
}

- (void)updateLayout
{
    _innerLayout = [NOCMTextLayout layoutWithContainer:_innerContainer text:_innerText];
}

- (void)startLongPressTimer
{
    [_longPressTimer invalidate];
    __weak typeof(self) weakSelf = self;
    _longPressTimer = [NSTimer timerWithTimeInterval:kLongPressMinimumDuration
                                              target:weakSelf
                                            selector:@selector(_trackDidLongPress)
                                            userInfo:nil
                                             repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_longPressTimer forMode:NSRunLoopCommonModes];
}

- (void)endLongPressTimer
{
    [_longPressTimer invalidate];
    _longPressTimer = nil;
}

- (CGPoint)convertPointToLayout:(CGPoint)point
{
    return CGPointZero;
}

- (CGPoint)convertPointFromLayout:(CGPoint)point
{
    return CGPointZero;
}

- (CGRect)convertRectToLayout:(CGRect)rect
{
    rect.origin = [self convertPointToLayout:rect.origin];
    return rect;
}

- (CGRect)convertRectFromLayout:(CGRect)rect
{
    rect.origin = [self convertPointFromLayout:rect.origin];
    return rect;
}

- (NOCMTextHighlight *)highlightAtPoint:(CGPoint)point range:(NSRangePointer)range
{
    return nil;
}

- (void)showHighlightAnimated:(BOOL)animated
{
    
}

- (void)removeHighlightAnimated:(BOOL)animated
{
    
}

@end

#pragma mark - NOCMTextContainer

const CGSize NOCMTextContainerMaxSize = (CGSize){0x100000, 0x100000};

static inline CGSize NOCMTextClipCGSize(CGSize size)
{
    if (size.width > NOCMTextContainerMaxSize.width) { size.width = NOCMTextContainerMaxSize.width; }
    if (size.height > NOCMTextContainerMaxSize.height) { size.height = NOCMTextContainerMaxSize.height; }
    return size;
}

static inline UIEdgeInsets UIEdgeInsetRotateVertical(UIEdgeInsets insets)
{
    UIEdgeInsets one;
    one.top = insets.left;
    one.left = insets.bottom;
    one.bottom = insets.right;
    one.right = insets.top;
    return one;
}

static CGColorRef NOCMTextGetCGColor(CGColorRef color)
{
    static UIColor *defaultColor;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultColor = [UIColor blackColor];
    });
    if (!color) return defaultColor.CGColor;
    if ([((__bridge NSObject *)color) respondsToSelector:@selector(CGColor)]) {
        return ((__bridge UIColor *)color).CGColor;
    }
    return color;
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

- (void)dealloc
{
    if (_frameSetter) CFRelease(_frameSetter);
    if (_frame) CFRelease(_frame);
    if (_lineRowsIndex) free(_lineRowsIndex);
    if (_lineRowsEdge) free(_lineRowsEdge);
}

#pragma mark - Query

- (NOCMTextRange *)textRangeAtPoint:(CGPoint)point
{
    return nil;
}

- (CGRect)rectForRange:(NOCMTextRange *)range
{
    return CGRectZero;
}

#pragma mark - Copying

- (id)copyWithZone:(NSZone *)zone
{
    return self; // readonly object
}

#pragma mark - Draw

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

- (void)drawInContext:(CGContextRef)context size:(CGSize)size point:(CGPoint)point view:(UIView *)view layer:(CALayer *)layer cancel:(BOOL (^)(void))cancel
{
    @autoreleasepool {
        if (self.needDrawText && context) {
            if (cancel && cancel()) return;
            NOCMTextDrawText(self, context, size, point, cancel);
        }
    }
}

@end

#pragma mark - NOCMTextHighlight

@implementation NOCMTextHighlight

@end

#pragma mark - NOCMTextPosition

@implementation NOCMTextPosition

+ (instancetype)positionWithOffset:(NSInteger)offset
{
    return nil;
}

+ (instancetype)positionWithOffset:(NSInteger)offset affinity:(NOCMTextAffinity)affinity
{
    return nil;
}

@end

#pragma mark - NOCMTextRange

@implementation NOCMTextRange

+ (instancetype)rangeWithStart:(NOCMTextPosition *)start end:(NOCMTextPosition *)end
{
    return nil;
}

- (NSRange)asRange
{
    return NSMakeRange(NSNotFound, 0);
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

@implementation NOCMTextAttachment

@end
