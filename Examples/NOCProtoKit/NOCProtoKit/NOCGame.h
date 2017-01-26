//
//  NOCGame.h
//  NOCProtoKit
//
//  Created by little2s on 2017/1/25.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NOCSence <NSObject>
@required
- (void)enter:(NSString *)text;
@end

@interface NOCMap : NSObject

+ (NSDictionary *)scenes;

- (instancetype)initWithStartScene:(NSString *)startScene;

- (id<NOCSence>)nextScene:(NSString *)sceneName;
- (id<NOCSence>)openingScene;

@end

@interface NOCEngine : NSObject

@property (nonatomic, strong) id<NOCSence> currentSence;

+ (instancetype)shared;
- (void)play;
- (void)print:(NSArray *)msgs completed:(void (^)())completed;
- (void)nextScene:(NSString *)sceneName;

@end

// Scence
@interface NOCDeath : NSObject <NOCSence>

@end

@interface NOCCentralCorridor : NSObject <NOCSence>

@end

@interface NOCLasterWeaponArmory : NSObject <NOCSence>

@end

@interface NOCTheBridge : NSObject <NOCSence>

@end

@interface NOCEscapePod : NSObject <NOCSence>

@end

