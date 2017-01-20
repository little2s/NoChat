//
//  NOCMMessageCell.m
//  NoChat-Example
//
//  Created by little2s on 2016/12/25.
//  Copyright © 2016年 little2s. All rights reserved.
//

#import "NOCMMessageCell.h"
#import "NOCMMessageCellLayout.h"
#import "NOCMMessage.h"

@implementation NOCMMessageHeadView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _senderDisplayNameLabel = [[UILabel alloc] init];
        _senderDisplayNameLabel.font = [NOCMMessageCellLayout senderDisplayNameFont];
        _senderDisplayNameLabel.textColor = [NOCMMessageCellLayout senderDisplayNameColor];
        [self addSubview:_senderDisplayNameLabel];
        
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.font = [NOCMMessageCellLayout dateFont];
        _dateLabel.textColor = [NOCMMessageCellLayout dateColor];
        [self addSubview:_dateLabel];
    }
    return self;
}

@end

@implementation NOCMMessageContentView

- (void)setLayout:(id<NOCMMessageContentViewLayout>)layout
{
    
}

@end

@implementation NOCMMessageView

- (instancetype)initWithCell:(NOCMMessageCell *)cell
{
    self = [super initWithFrame:cell.bounds];
    if (self) {
        _cell = cell;
        
        _headView = [[NOCMMessageHeadView alloc] init];
        [self addSubview:_headView];
        
        _contentView = [[[[cell class] messageContentViewClass] alloc] init];
        _contentView.cell = cell;
        [self addSubview:_contentView];
    }
    return self;
}

- (void)setLayout:(NOCMMessageCellLayout *)layout
{
    _layout = layout;
    
    NOCMMessageCellLayout *cellLayout = (NOCMMessageCellLayout *)layout;
    NOCMMessage *message = (NOCMMessage *)cellLayout.chatItem;
    self.headView.frame = cellLayout.headViewFrame;
    self.headView.senderDisplayNameLabel.frame = cellLayout.senderDisplayNameLabelFrame;
    self.headView.senderDisplayNameLabel.text = message.senderDisplayName;
    self.headView.dateLabel.frame = cellLayout.dateLabelFrame;
    self.headView.dateLabel.text = message.dateString;
    
    self.contentView.frame = cellLayout.contentViewFrame;
    [self.contentView setLayout:cellLayout.messageContentViewLayout];
}

@end

@implementation NOCMMessageCell

+ (NSString *)reuseIdentifier
{
    return @"NOCMMessageCell";
}

+ (Class)messageContentViewClass
{
    return [NOCMMessageContentView class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _messageView = [[NOCMMessageView alloc] initWithCell:self];
        [self.contentView addSubview:_messageView];
    }
    return self;
}

- (void)setLayout:(id<NOCChatItemCellLayout>)layout
{
    self.messageView.frame = CGRectMake(0, 0, layout.width, layout.height);
    self.messageView.layout = layout;
}

@end

// Text Message
@implementation NOCMTextMessageContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        __weak typeof(self) weakSelf = self;
        
        _textLabel = [[NOCMTextLabel alloc] init];
        _textLabel.highlightTapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [text enumerateAttribute:NOCMTextHighlightAttributeName inRange:range options:0 usingBlock:^(NOCMTextHighlight *textHighlight, NSRange range, BOOL *stop) {
                if (textHighlight && textHighlight.userInfo) {
                    NSURL *linkURL = textHighlight.userInfo[@"url"];
                    if (linkURL) {
                        NOCMTextMessageCell *cell = strongSelf.cell;
                        id<NOCMTextMessageCellDelegate> delegate = cell.delegate;
                        if (delegate && [delegate respondsToSelector:@selector(cell:didTapLink:)]) {
                            [delegate cell:cell didTapLink:linkURL];
                        }
                    }
                }
            }];
        };
        [self addSubview:_textLabel];
    }
    return self;
}

- (void)setLayout:(id<NOCMMessageContentViewLayout>)layout
{
    NOCMTextMessageContentViewLayout *contentViewLayout = (NOCMTextMessageContentViewLayout *)layout;
    self.textLabel.frame = contentViewLayout.textLabelFrame;
    self.textLabel.textLayout = contentViewLayout.textLayout;
}

@end

@implementation NOCMTextMessageCell

+ (NSString *)reuseIdentifier
{
    return @"NOCMTextMessageCell";
}

+ (Class)messageContentViewClass
{
    return [NOCMTextMessageContentView class];
}

@end
