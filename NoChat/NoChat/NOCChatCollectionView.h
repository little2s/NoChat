//
//  NOCChatCollectionView.h
//  NoChat-Example
//
//  Created by little2s on 2016/12/24.
//  Copyright © 2016年 little2s. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^NOCChatCollectionViewAction)();

@interface NOCChatCollectionView : UICollectionView

@property (nullable, nonatomic, copy) NOCChatCollectionViewAction tapAction;

@end

NS_ASSUME_NONNULL_END
