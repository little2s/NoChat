//
//  NOCSoundManager.m
//  NoChat-Example
//
//  Created by little2s on 2017/2/7.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import "NOCSoundManager.h"
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

@implementation NOCSoundManager {
    NSMutableDictionary *_loadedSoundSamples;
}

+ (instancetype)manager
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _loadedSoundSamples = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)playSound:(NSString *)name vibrate:(BOOL)vibrate
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
           return;
        }

        if (name == nil) {
            return;
        };
        
        static NSMutableDictionary *soundPlayed = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            soundPlayed = [[NSMutableDictionary alloc] init];
        });
       
        double lastTimeSoundPlayed = [[soundPlayed objectForKey:name] doubleValue];
       
        CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
        if (currentTime - lastTimeSoundPlayed < 0.25) {
            return;
        }
       
        [soundPlayed setObject:[[NSNumber alloc] initWithDouble:currentTime] forKey:name];
       
        NSNumber *soundId = [_loadedSoundSamples objectForKey:name];
        if (soundId == nil) {
           NSString *path = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], name];
           NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
           SystemSoundID sound;
           AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &sound);
           soundId = [NSNumber numberWithUnsignedLong:sound];
           [_loadedSoundSamples setObject:soundId forKey:name];
        }
       
        AudioServicesPlaySystemSound((SystemSoundID)[soundId unsignedLongValue]);

        if (vibrate) {
           AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
    });
}

@end
