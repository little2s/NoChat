//
//  MMBaseMessageCell.m
//  NoChat-Example
//
//  Copyright (c) 2016-present, little2s.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "MMBaseMessageCell.h"
#import "MMBaseMessageCellLayout.h"

@implementation MMBaseMessageCell

+ (NSString *)reuseIdentifier
{
    return @"MMBaseMessageCell";
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _messageView = [[UIView alloc] init];
        [self.contentView addSubview:_messageView];
        
        _avatarImageView = [[UIImageView alloc] init];
        [_messageView addSubview:_avatarImageView];
        
        _bubbleView = [[UIView alloc] init];
        [_messageView addSubview:_bubbleView];
    }
    return self;
}

- (void)setLayout:(id<NOCChatItemCellLayout>)layout
{
    [super setLayout:layout];
    self.messageView.frame = CGRectMake(0, 0, layout.width, layout.height);
    
    MMBaseMessageCellLayout *cellLayout = (MMBaseMessageCellLayout *)layout;
    self.bubbleView.frame = cellLayout.bubbleViewFrame;
    self.avatarImageView.frame = cellLayout.avatarImageViewFrame;
    self.avatarImageView.image = cellLayout.avatarImage;
}

@end
