//
//  TGTitleView.m
//  NoChat-Example
//
//  Created by little2s on 2017/1/24.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import "TGTitleView.h"
#import "UIFont+NOChat.h"

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
        _titleLabel.font = [UIFont noc_mediumSystemFontOfSize:16];
        _titleLabel.textColor = [UIColor blackColor];
        [self addSubview:_titleLabel];
        
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _detailLabel.text = @"detail";
        _detailLabel.font = [UIFont systemFontOfSize:12];
        _detailLabel.textColor = [UIColor grayColor];
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
    if (![title isEqualToString:_title]) {
        _title = title;
        [self updateLayouts];
    }
}

- (void)setDetail:(NSString *)detail
{
    if (![detail isEqualToString:_detail]) {
        _detail = detail;
        [self updateLayouts];
    }
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
    
    CGFloat titleViewWidth = MAX(titleLabelSize.width, detailLabelSize.width);
    CGFloat titleViewHeight = 44;
    self.frame = CGRectMake(0, 0, titleViewWidth, titleViewHeight);
    
    CGFloat titleLabelX = titleViewWidth/2 - titleLabelSize.width/2;
    CGFloat titleLabelY = 4;
    self.titleLabel.frame = CGRectMake(titleLabelX, titleLabelY, titleLabelSize.width, titleLabelSize.height);
    
    CGFloat detailLabelX = titleViewWidth/2 - detailLabelSize.width/2;
    CGFloat detailLabelY = titleViewHeight - 4 - detailLabelSize.height;
    self.detailLabel.frame = CGRectMake(detailLabelX, detailLabelY, detailLabelSize.width, detailLabelSize.height);
}

- (void)setupCompactLayouts
{
    CGSize unlimitSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
    CGSize titleLabelSize = [self.titleLabel sizeThatFits:unlimitSize];
    CGSize detailLabelSize = [self.detailLabel sizeThatFits:unlimitSize];
    
    CGFloat titleViewWidth = titleLabelSize.width + 8 + detailLabelSize.width;
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
