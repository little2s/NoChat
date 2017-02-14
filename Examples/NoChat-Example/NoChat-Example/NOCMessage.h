//
//  NOCMessage.h
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

#import <Foundation/Foundation.h>
#import <NoChat/NoChat.h>

typedef NS_ENUM(NSUInteger, NOCMessageDeliveryStatus) {
    NOCMessageDeliveryStatusIdle = 0,
    NOCMessageDeliveryStatusDelivering = 1,
    NOCMessageDeliveryStatusDelivered = 2,
    NOCMessageDeliveryStatusFailure = 3,
    NOCMessageDeliveryStatusRead = 4
};

@interface NOCMessage : NSObject <NOCChatItem>

@property (nonatomic, strong) NSString *msgId;
@property (nonatomic, strong) NSString *type;

@property (nonatomic, strong) NSString *senderId;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *text;

@property (nonatomic, assign, getter=isOutgoing) BOOL outgoing;
@property (nonatomic, assign) NOCMessageDeliveryStatus deliveryStatus;

@end
