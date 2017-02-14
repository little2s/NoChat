//
//  TGDeliveryStatusView.m
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

#import "TGDeliveryStatusView.h"

@implementation TGDeliveryStatusView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _clockView = [[TGClockProgressView alloc] init];
        [self addSubview:_clockView];
        
        _checkmark1ImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TGMessageCheckmark1"]];
        [self addSubview:_checkmark1ImageView];
        
        _checkmark2ImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TGMessageCheckmark2"]];
        [self addSubview:_checkmark2ImageView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.clockView.frame = self.bounds;
    self.checkmark1ImageView.frame = CGRectMake(0, 2, 12, 11);
    self.checkmark2ImageView.frame = CGRectMake(3, 2, 12, 11);
}

- (void)setDeliveryStatus:(NOCMessageDeliveryStatus)deliveryStatus
{
    if (deliveryStatus == NOCMessageDeliveryStatusDelivering) {
        self.clockView.hidden = NO;
        [self.clockView startAnimating];
        self.checkmark1ImageView.hidden = YES;
        self.checkmark2ImageView.hidden = YES;
    } else if (deliveryStatus == NOCMessageDeliveryStatusDelivered) {
        [self.clockView stopAnimating];
        self.clockView.hidden = YES;
        self.checkmark1ImageView.hidden = NO;
        self.checkmark2ImageView.hidden = YES;
    } else if (deliveryStatus == NOCMessageDeliveryStatusRead) {
        [self.clockView stopAnimating];
        self.clockView.hidden = YES;
        self.checkmark1ImageView.hidden = NO;
        self.checkmark2ImageView.hidden = NO;
    } else {
        [self.clockView stopAnimating];
        self.clockView.hidden = YES;
        self.checkmark1ImageView.hidden = YES;
        self.checkmark2ImageView.hidden = YES;
    }
}

@end
