//
//  TGSystemMessageCell.m
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

#import "TGSystemMessageCell.h"
#import "TGSystemMessageCellLayout.h"

@implementation TGSystemMessageCell

+ (NSString *)reuseIdentifier
{
    return @"TGSystemMessageCell";
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _backgroundImageView = [[UIImageView alloc] init];
        [self.itemView addSubview:_backgroundImageView];
        
        _textLabel = [[UILabel alloc] init];
        _textLabel.numberOfLines = 0;
        [self.itemView addSubview:_textLabel];
    }
    return self;
}

- (void)setLayout:(id<NOCChatItemCellLayout>)layout
{
    [super setLayout:layout];
    
    TGSystemMessageCellLayout *cellLayout = (TGSystemMessageCellLayout *)layout;
    self.backgroundImageView.frame = cellLayout.backgroundImageViewFrame;
    self.backgroundImageView.image = cellLayout.backgroundImage;
    self.textLabel.frame = cellLayout.textLabelFrame;
    self.textLabel.attributedText = cellLayout.attributedText;
}

@end
