//
//  NOCChatItemCell.h
//  NoChat-Example
//
//  Created by little2s on 2016/12/24.
//  Copyright © 2016年 little2s. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NOCChatItemCellLayout.h"

@class NOCChatItemCell;

@protocol NOCChatItemCellDelegate <NSObject>

@end

@interface NOCChatItemCell : UICollectionViewCell

@property (nonatomic, weak) id<NOCChatItemCellDelegate> delegate;
@property (nonatomic, strong) id<NOCChatItemCellLayout> layout;

+ (NSString *)reuseIdentifier;

@end
