//
//  NSAttributedString+NOCMinimal.h
//  Pods
//
//  Created by little2s on 2017/1/17.
//
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (NOCMinimal)

@end

@interface NSMutableAttributedString (NOCMinimal)

+ (NSArray<NSString *> *)nocm_allDiscontinuousAttributeKeys;

- (void)nocm_setClearColorToJoinedEmoji;

@end
