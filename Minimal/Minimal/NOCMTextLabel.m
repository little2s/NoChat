//
//  NOCMTextLabel.m
//  NoChat-Example
//
//  Created by little2s on 2016/12/25.
//  Copyright © 2016年 little2s. All rights reserved.
//

#import "NOCMTextLabel.h"
#import <libkern/OSAtomic.h>
#import <QuartzCore/QuartzCore.h>

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
    BOOL _verticalForm;
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
    one->_verticalForm = _verticalForm;
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

- (BOOL)isVerticalForm
{
    Getter(BOOL v = _verticalForm) return v;
}

- (void)setVerticalForm:(BOOL)verticalForm
{
    Setter(_verticalForm = verticalForm);
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
    if (container.verticalForm) {
        for (NSUInteger i = 0, max = lines.count; i < max; i++) {
            NOCMTextLine *line = lines[i];
            CGPoint pos = line.position;
            pos.x = container.size.width - container.insets.right - line.row * _fixedLineHeight - _fixedLineHeight * 0.9;
            line.position = pos;
        }
    } else {
        for (NSUInteger i = 0, max = lines.count; i < max; i++) {
            NOCMTextLine *line = lines[i];
            CGPoint pos = line.position;
            pos.y = line.row * _fixedLineHeight + _fixedLineHeight * 0.9 + container.insets.top;
            line.position = pos;
        }
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

+ (instancetype)lineWithCTLine:(CTLineRef)CTLine position:(CGPoint)position vertical:(BOOL)isVertical
{
    if (!CTLine) {
        return nil;
    }
    
    NOCMTextLine *line = [self new];
    line->_position = position;
    line->_vertical = isVertical;
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
    if (_vertical) {
        _bounds = CGRectMake(_position.x - _descent, _position.y, _ascent + _descent, _lineWidth);
        _bounds.origin.y += _firstGlyphPos;
    } else {
        _bounds = CGRectMake(_position.x, _position.y - _ascent, _lineWidth, _ascent + _descent);
        _bounds.origin.x += _firstGlyphPos;
    }
    
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
            
            if (_vertical) {
                CGFloat temp = runPosition.x;
                runPosition.x = runPosition.y;
                runPosition.y = temp;
                runPosition.y = _position.y + runPosition.y;
                runTypoBounds = CGRectMake(_position.x + runPosition.x - descent, runPosition.y , ascent + descent, runWidth);
            } else {
                runPosition.x += _position.x;
                runPosition.y = _position.y - runPosition.y;
                runTypoBounds = CGRectMake(runPosition.x, runPosition.y - ascent, runWidth, ascent + descent);
            }
            
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

@implementation NOCMTextRunGlyphRange

@end

#pragma mark - NOCMTextLayout

@implementation NOCMTextLayout

+ (instancetype)layoutWithContainer:(NOCMTextContainer *)container text:(NSAttributedString *)text
{
    return [self layoutWithContainer:container text:text range:NSMakeRange(0, text.length)];
}

+ (instancetype)layoutWithContainer:(NOCMTextContainer *)container text:(NSAttributedString *)text range:(NSRange)range
{
    NOCMTextLayout *layout = [[NOCMTextLayout alloc] init];
    return layout;
}

- (NOCMTextRange *)textRangeAtPoint:(CGPoint)point
{
    return nil;
}

- (CGRect)rectForRange:(NOCMTextRange *)range
{
    return CGRectZero;
}

- (void)drawInContext:(CGContextRef)context size:(CGSize)size point:(CGPoint)point view:(UIView *)view layer:(CALayer *)layer cancel:(BOOL (^)(void))cancel
{
    
}

- (id)copyWithZone:(NSZone *)zone
{
    NOCMTextLayout *newLayout = [[NOCMTextLayout alloc] init];
    return newLayout;
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

NSString *NOCMTextAttachmentAttributeName = @"NOCMTextAttachment";

@implementation NOCMTextAttachment

@end
