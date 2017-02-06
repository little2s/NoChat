//
//  NOCMessageManager.h
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

@class NOCMessageManager;

@protocol NOCMessageManagerDelegate <NSObject>

@optional
- (void)didReceiveMessages:(NSArray *)messages chatId:(NSString *)chatId;

@end

@class NOCChat;
@class NOCMessage;

@interface NOCMessageManager : NSObject

+ (instancetype)manager;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (void)play;

- (void)fetchMessagesWithChatId:(NSString *)chatId handler:(void (^)(NSArray *messages))handler;
- (void)sendMessage:(NOCMessage *)message toChat:(NOCChat *)chat;

- (void)addDelegate:(id<NOCMessageManagerDelegate>)delegate;
- (void)removeDelegate:(id<NOCMessageManagerDelegate>)delegate;

@end
