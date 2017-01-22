//
//  NOCChatItemViewLayout.h
//  NoChat-Example
//
//  Created by little2s on 2016/12/24.
//  Copyright © 2016年 little2s. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NOCChatItem.h"

NS_ASSUME_NONNULL_BEGIN

@protocol NOCChatItemCellLayout <NSObject>

@property (nonatomic, strong) NSString *reuseIdentifier;
@property (nonatomic, strong) id<NOCChatItem> chatItem;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

- (instancetype)initWithChatItem:(id<NOCChatItem>)chatItem cellWidth:(CGFloat)width;
- (void)calculateLayout;

@end

NS_ASSUME_NONNULL_END
