//
//  NOCClient.m
//  NOCProtoKit
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

#import "NOCClient.h"
#import "NOCDispatcher.h"

@implementation NOCClient
{
    NSString *_userId;
}

- (instancetype)initWithUserId:(NSString *)userId
{
    self = [super init];
    if (self) {
        _userId = userId;
    }
    return self;
}

- (void)open
{
    [[NOCDispatcher shared] registerClient:self withUserId:_userId];
    
    if ([self.delegate respondsToSelector:@selector(clientDidOpen:)]) {
        [self.delegate clientDidOpen:self];
    }
}

- (void)close;
{
    [[NOCDispatcher shared] unregisterClientWithUserId:_userId];
    
    if ([self.delegate respondsToSelector:@selector(clientDidCloseWithCode:reason:)]) {
        [self.delegate clientDidCloseWithCode:0 reason:nil];
    }
}

- (void)sendMessage:(NSDictionary *)message
{
    [[NOCDispatcher shared] pushMessage:message];
}

@end
