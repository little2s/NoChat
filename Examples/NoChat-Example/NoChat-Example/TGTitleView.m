//
//  TGTitleView.m
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

#import "TGTitleView.h"
#import "UIFont+NoChat.h"

@interface TGTitleView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;

@end

@implementation TGTitleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.text = @"Title";
        _titleLabel.font = [UIFont noc_mediumSystemFontOfSize:17];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
        
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _detailLabel.text = @"detail";
        _detailLabel.font = [UIFont systemFontOfSize:12];
        _detailLabel.textColor = [UIColor grayColor];
        _detailLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_detailLabel];
        
        [self setupRegularLayouts];
    }
    return self;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    [self updateLayouts];
}

- (void)setTitle:(NSString *)title
{
    if (![title isEqualToString:self.titleLabel.text]) {
        self.titleLabel.text = title;
        [self updateLayouts];
    }
}

- (NSString *)title
{
    return self.titleLabel.text;
}

- (void)setDetail:(NSString *)detail
{
    if (![detail isEqualToString:self.detailLabel.text]) {
        self.detailLabel.text = detail;
        [self updateLayouts];
    }
}

- (NSString *)detail
{
    return self.detailLabel.text;
}

- (void)updateLayouts
{
    if (self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact) {
        [self setupCompactLayouts];
    } else {
        [self setupRegularLayouts];
    }
}

- (void)setupRegularLayouts
{
    CGSize unlimitSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
    CGSize titleLabelSize = [self.titleLabel sizeThatFits:unlimitSize];
    CGSize detailLabelSize = [self.detailLabel sizeThatFits:unlimitSize];
    
    CGFloat titleViewWidth = MIN(200, MAX(titleLabelSize.width, detailLabelSize.width));
    CGFloat titleViewHeight = 44;
    self.frame = CGRectMake(0, 0, titleViewWidth, titleViewHeight);
    
    CGFloat titleLabelY = 4;
    self.titleLabel.frame = CGRectMake(0, titleLabelY, titleViewWidth, titleLabelSize.height);
    
    CGFloat detailLabelY = titleViewHeight - 4 - detailLabelSize.height;
    self.detailLabel.frame = CGRectMake(0, detailLabelY, titleViewWidth, detailLabelSize.height);
}

- (void)setupCompactLayouts
{
    CGSize unlimitSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
    CGSize titleLabelSize = [self.titleLabel sizeThatFits:unlimitSize];
    CGSize detailLabelSize = [self.detailLabel sizeThatFits:unlimitSize];
    
    CGFloat titleViewWidth = MIN(350, titleLabelSize.width + 8 + detailLabelSize.width);
    CGFloat titleViewHeight = 40;
    self.frame = CGRectMake(0, 0, titleViewWidth, titleViewHeight);
    
    CGFloat titleLabelX = 0;
    CGFloat titleLabelY = titleViewHeight/2 - titleLabelSize.height/2;
    self.titleLabel.frame = CGRectMake(titleLabelX, titleLabelY, titleLabelSize.width, titleLabelSize.height);
    
    CGFloat detailLabelX = titleViewWidth - detailLabelSize.width;
    CGFloat detailLabelY = titleViewHeight/2 - detailLabelSize.height/2;
    self.detailLabel.frame = CGRectMake(detailLabelX, detailLabelY, detailLabelSize.width, detailLabelSize.height);
}

@end
