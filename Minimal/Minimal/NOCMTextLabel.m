//
//  NOCMTextLabel.m
//  NoChat-Example
//
//  Created by little2s on 2016/12/25.
//  Copyright © 2016年 little2s. All rights reserved.
//

#import "NOCMTextLabel.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>

#pragma mark - NOCMAsyncLayer

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

@implementation NOCMAsyncLayer

@end

#pragma mark - NOCMTextLabel

#define kLongPressMinimumDuration 0.5
#define kLongPressAllowableMovement 9.0

static dispatch_queue_t NOCMTextLabelGetReleaseQueue()
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
    
    _highlight = [self getHighlightAtPoint:point range:&_highlightRange];
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
            NOCMTextHighlight *highlight = [self getHighlightAtPoint:point range:nil];
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
            if (!_state.touchMoved || [self getHighlightAtPoint:point range:nil] == _highlight) {
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
    return nil;
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
    
}

- (void)clearContents
{
    
}

- (void)setLayoutNeedRedraw
{
    
}

- (void)endTouch
{
    
}

- (void)updateIfNeeded
{
    
}

- (NOCMTextHighlight *)getHighlightAtPoint:(CGPoint)point range:(NSRangePointer)range
{
    return nil;
}

- (void)startLongPressTimer
{
    
}

- (void)showHighlightAnimated:(BOOL)animated
{
    
}

- (void)endLongPressTimer
{
    
}

- (CGPoint)convertPointToLayout:(CGPoint)point
{
    return CGPointZero;
}

- (CGRect)convertRectFromLayout:(CGRect)rect
{
    return CGRectZero;
}

- (void)removeHighlightAnimated:(BOOL)animated
{
    
}

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

- (id)copyWithZone:(NSZone *)zone
{
    NOCMTextLayout *newLayout = [[NOCMTextLayout alloc] init];
    return newLayout;
}

@end

#pragma mark - NOCMTextContainer

@implementation NOCMTextContainer

+ (instancetype)containerWithSize:(CGSize)size
{
    NOCMTextContainer *container = [[NOCMTextContainer alloc] init];
    return container;
}

- (id)copyWithZone:(NSZone *)zone
{
    NOCMTextContainer *newContainer = [[NOCMTextContainer alloc] init];
    return newContainer;
}

@end

#pragma mark - NOCMTextLinePositionModifier

@implementation NOCMTextLinePositionModifier

- (CGFloat)heightForLineCount:(NSUInteger)lineCount
{
    return 0;
}

- (id)copyWithZone:(NSZone *)zone
{
    NOCMTextLinePositionModifier *modifier = [[NOCMTextLinePositionModifier alloc] init];
    return modifier;
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

