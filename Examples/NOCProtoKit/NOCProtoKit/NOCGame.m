//
//  NOCGame.m
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

#import "NOCGame.h"
#import "NOCClient.h"

#define kUserId @"89757"

@interface NOCMap ()
@property (nonatomic, strong) NSString *startSence;
@end

@implementation NOCMap

+ (NSDictionary *)scenes
{
    static NSDictionary *_scenes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _scenes = @{
            @"central_corridor": [NOCCentralCorridor new],
            @"laser_weapon_armory": [NOCLasterWeaponArmory new],
            @"the_bridge": [NOCTheBridge new],
            @"escape_pod": [NOCEscapePod new],
            @"death": [NOCDeath new]
        };
    });
    return _scenes;
}

- (instancetype)initWithStartScene:(NSString *)startScene
{
    self = [super init];
    if (self) {
        _startSence = startScene;
    }
    return self;
}

- (id<NOCSence>)nextScene:(NSString *)sceneName
{
    return [NOCMap scenes][sceneName];
}

- (id<NOCSence>)openingScene
{
    return [self nextScene:self.startSence];
}

@end

@interface NOCEngine () <NOCClientDelegate>

@property (nonatomic, strong) NOCMap *sceneMap;
@property (nonatomic, strong) NOCClient *client;
@property (nonatomic, strong) NSString *targetId;
@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation NOCEngine

+ (instancetype)shared
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
        _sceneMap = [[NOCMap alloc] initWithStartScene:@"central_corridor"];
        _client = [[NOCClient alloc] initWithUserId:kUserId];
        _client.delegate = self;
        _targetId = nil;
        dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_DEFAULT, 0);
        _queue = dispatch_queue_create("com.little2s.nocprotokit.game.engine", attr);
    }
    return self;
}

- (void)play
{
    NSLog(@">>>>> game start");
    [self.client open];
    self.currentSence = [self.sceneMap openingScene];
}

- (void)clientDidReceiveMessage:(NSDictionary *)message
{
    NSString *type = message[@"type"];
    if (![type isEqualToString:@"Text"]) {
        return;
    }
    
    NSString *senderId = message[@"from"];
    NSString *text = message[@"text"];
    if (!self.targetId) {
        self.targetId = senderId;
        [self.currentSence enter:text];
    } else if ([self.targetId isEqualToString:senderId]) {
        [self.currentSence enter:text];
    }
}

- (void)print:(NSArray *)msgs completed:(void (^)(void))completed
{
    __block float delay = 0.65;
    [msgs enumerateObjectsUsingBlock:^(NSString *text, NSUInteger idx, BOOL *stop) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), self.queue, ^{
            NSDictionary *message = @{
                @"from": kUserId,
                @"to": self.targetId,
                @"type": @"Text",
                @"text": text,
                @"ctype": @"bot"
            };
            [self.client sendMessage:message];
            if (completed && (idx == msgs.count-1)) {
                completed();
            }
        });
        delay += [self delayOfText:text];
    }];
}

- (float)delayOfText:(NSString *)text
{
    if (text.length < 30) {
        return 0.65;
    } else if (text.length < 70) {
        return 1.25;
    } else
        return 2;
}

- (void)nextScene:(NSString *)sceneName
{
    self.currentSence = [self.sceneMap nextScene:sceneName];
    [self.currentSence enter:nil];
}

@end

@implementation NOCGame

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[NOCEngine shared] play];
    });
}

@end

@interface NOCDeath ()

@property (nonatomic, strong) NSArray *quips;

@end

@implementation NOCDeath

- (void)enter:(NSString *)text
{
    NSUInteger index = arc4random_uniform((uint32_t)self.quips.count);
    NSArray *msgs = @[self.quips[index], @"[Game Over]"];
    [[NOCEngine shared] print:msgs completed:^{
        [[NOCEngine shared] nextScene:@"central_corridor"];
    }];
}

- (NSArray *)quips
{
    if (!_quips) {
        _quips = @[
            @"You dided. You kinda suck at this.",
            @"Your mom would be proud...if she were smarter.",
            @"Such a luser.",
            @"I have a small puppy that's better at this."
        ];
    }
    return _quips;
}

@end

@interface NOCCentralCorridor ()

@property (nonatomic, assign) NSInteger offset;

@end

@implementation NOCCentralCorridor

- (void)enter:(NSString *)text
{
    if (self.offset == 0) {
        [self offset0:text];
    } else if (self.offset == 1) {
        [self offset1:text];
    }
}

- (void)offset0:(NSString *)text
{
    if ([text isEqualToString:@"/start"]) {
        NSArray *msgs = @[
            @"[Game Start]",
            @"The Gothons of Planet Percal #25 have invaded your ship and destroyed your entire crew.",
            @"You are the last surviving member and your last mission is to get the neutron destruct bomb from the Weapons Armory, put it in the bridge, and blow the ship up after getting into an escape pod.",
            @"You're running down the central corridor to the Weapons Armory when a Gothon jumps out, red scaly skin, dark grimy teeth, and evil clown costume flowing around his hate filled body.",
            @"He's blocking the door to the Armory and about to pull a weapon to blast you."
        ];
        [[NOCEngine shared] print:msgs completed:^{
            [self nextOffset];
        }];
    }
}

- (void)offset1:(NSString *)text
{
    if ([text isEqualToString:@"shoot"]) {
        NSArray *msgs = @[
            @"Quick on the draw you yank out your blaster and fire it at the Gothon.",
            @"His clown costume is flowing and moving around his body, which throws off your aim.",
            @"Your laser hits his costume but misses him entirely.",
            @"This makes him fly into a rage and blast you repeatedly in the face until you are dead.",
            @"Then he eats you."
        ];
        [[NOCEngine shared] print:msgs completed:^{
            [self nextOffset];
            [[NOCEngine shared] nextScene:@"death"];
        }];
        
    } else if ([text isEqualToString:@"dodge"]) {
        NSArray *msgs = @[
            @"Like a world class boxer you dodge, weave, slip and slide right, as the Gothon's blaster cranks a laser past your head.",
            @"In the middle of your artful dodge your foot slips and you bang your head on the metal wall and pass out.",
            @"You wake up shortly after only to die as the Gothon stomps on your head and eats you."
        ];
        [[NOCEngine shared] print:msgs completed:^{
            [self nextOffset];
            [[NOCEngine shared] nextScene:@"death"];
        }];

    } else if ([text isEqualToString:@"tell a joke"]) {
        NSArray *msgs = @[
            @"Lucky for you they made you learn Gothon insults in the academy.",
            @"You tell the one Gothon joke you know: Lbhe zbgure vf fb sng, jura fur fvgf nebhaq gur ubhfr, fur fvgf nebhaq gur ubhfr.",
            @"The Gothon stops, tries not to laugh, then busts out laughing and can't move.",
            @"While he's laughing you run up and shoot him square in the head putting him down, then jump through the Weapon Armory door."
        ];
        [[NOCEngine shared] print:msgs completed:^{
            [self nextOffset];
            [[NOCEngine shared] nextScene:@"laser_weapon_armory"];
        }];

    } else {
        NSArray *msgs = @[@"DOES NOT COMPUTE!"];
        [[NOCEngine shared] print:msgs completed:^{
            [self nextOffset];
            [[NOCEngine shared] nextScene:@"death"];
        }];
    }
}

- (void)nextOffset
{
    self.offset = (self.offset + 1) % 2;
}

@end

@interface NOCLasterWeaponArmory ()

@property (nonatomic, strong) NSString *code;
@property (nonatomic, assign) NSInteger guesses;
@property (nonatomic, assign) NSInteger offset;

@end

@implementation NOCLasterWeaponArmory

- (void)enter:(NSString *)text
{
    if (self.offset == 0) {
        [self offset0:text];
    } else if (self.offset == 1) {
        [self offset1:text];
    }
}

- (void)offset0:(NSString *)text
{
    self.code = [NSString stringWithFormat:@"%@%@%@", [self rand], [self rand], [self rand]];
    self.guesses = 0;
    
    NSLog(@"laser_weapon_armory code: %@", self.code);
    
    NSArray *msg = @[
        @"You do a dive roll into the Weapon Armory, crouch and scan the room for more Gothons that might behiding.",
        @"It's dead quiet, too quiet.",
        @"You stand up and run to the far side of the room and find the neutron bomb in its container.",
        @"There's a keypad lock on the box and you need the code to get the bomb out.",
        @"If you get the code wrong 10 times then the lock closes forever and you can't get the bomb.",
        @"The code is 3 digits."
    ];
    [[NOCEngine shared] print:msg completed:^{
        [self nextOffset];
    }];
}

- (void)offset1:(NSString *)text
{
    if (![text isEqualToString:self.code] && self.guesses < 10) {
        NSArray *msg = @[@"BZZZZEDDD!"];
        [[NOCEngine shared] print:msg completed:^{
            self.guesses += 1;
        }];
    } else {
        if ([text isEqualToString:self.code]) {
            NSArray *msg = @[
                @"The container clicks open and the seal breaks, letting gas out.",
                @"You grab the neutron bomb and run as fast as you can to the bridge where you must place it in the right spot.",
            ];
            [[NOCEngine shared] print:msg completed:^{
                [self nextOffset];
                [[NOCEngine shared] nextScene:@"the_bridge"];
            }];
        } else {
            NSArray *msg = @[
                @"The lock buzzes one last time and then you hear a sickening melting sound as the mechanism is fused together.",
                @"You decide to sit there, and finally the Gothons blow up the ship from their ship and you die."
            ];
            [[NOCEngine shared] print:msg completed:^{
                [self nextOffset];
                [[NOCEngine shared] nextScene:@"death"];
            }];
        }
    }
}

- (void)nextOffset
{
    self.offset = (self.offset + 1) % 2;
}

- (NSString *)rand
{
    NSUInteger num = arc4random_uniform(9) + 1;
    return [NSString stringWithFormat:@"%@", @(num)];
}

@end

@interface NOCTheBridge ()

@property (nonatomic, assign) NSInteger offset;

@end

@implementation NOCTheBridge

- (void)enter:(NSString *)text
{
    if (self.offset == 0) {
        [self offset0:text];
    } else if (self.offset == 1) {
        [self offset1:text];
    }
}

- (void)offset0:(NSString *)text
{
    NSArray *msgs = @[
        @"You burst onto the Bridge with the neutron destruct bomb under your arm and surprise 5 Gothons who are trying to take control of the ship.",
        @"Each of them has an even uglier clown costume than the last.",
        @"They haven't pulled their weapons out yet, as they see the active bomb under your arm and don't want to set it off."
    ];
    [[NOCEngine shared] print:msgs completed:^{
        [self nextOffset];
    }];
}

- (void)offset1:(NSString *)text
{
    if ([text isEqualToString:@"throw the bomb"]) {
        NSArray *msgs = @[
            @"In a panic you throw the bomb at the group of Gothons and make a leap for the door.",
            @"Right as you drop it a Gothon shoots you right in the back killing you.",
            @"As you die you see another Gothon frantically try to disarm the bomb.",
            @"You die knowing they will probably blow up when it goes off."
        ];
        [[NOCEngine shared] print:msgs completed:^{
            [self nextOffset];
            [[NOCEngine shared] nextScene:@"death"];
        }];
    } else if ([text isEqualToString:@"slowly place the bomb"]) {
        NSArray *msgs = @[
            @"You point your blaster at the bomb under your arm and the Gothons put their hands up and start to sweat.",
            @"You inch backward to the door, open it, and then carefully place the bomb on the floor, pointing your blaster at it.",
            @"You then jump back through the door, punch the close button and blast the lock so the Gothons can't get out.",
            @"Now that the bomb is placed you run to the escape pod to get off this tin can."
        ];
        [[NOCEngine shared] print:msgs completed:^{
            [self nextOffset];
            [[NOCEngine shared] nextScene:@"escape_pod"];
        }];
    } else {
        NSArray *msgs = @[@"DOES NOT COMPUTE!"];
        [[NOCEngine shared] print:msgs completed:^{
            [self nextOffset];
            [[NOCEngine shared] nextScene:@"the_bridge"];
        }];
    }
}

- (void)nextOffset
{
    self.offset = (self.offset + 1) % 2;
}

@end

@interface NOCEscapePod ()

@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, strong) NSString *goodPod;

@end

@implementation NOCEscapePod

- (void)enter:(NSString *)text
{
    if (self.offset == 0) {
        [self offset0:text];
    } else if (self.offset == 1) {
        [self offset1:text];
    }
}

- (void)offset0:(NSString *)text
{
    self.goodPod = [self rand];
    
    NSLog(@"escape_pod goodPod: %@", self.goodPod);
    
    NSArray *msg = @[
        @"You rush through the ship desperately trying to make it to the escape pod before the whole ship explodes.",
        @"It seems like hardly any Gothons are on the ship, so your run is clear of interference.",
        @"You get to the chamber with the escape pods, and now need to pick one to take.",
        @"Some of them could be damaged but you don't have time to look.",
        @"There's 5 pods, which one do you take?"
    ];
    [[NOCEngine shared] print:msg completed:^{
        [self nextOffset];
    }];
}

- (void)offset1:(NSString *)text
{
    if (![text isEqualToString:self.goodPod]) {
        NSString *str = [NSString stringWithFormat:@"You jump into pod %@ and hit the eject button.", text];
        NSArray *msg = @[
            str,
            @"The pod escapes out into the void of space, then implodes as the hull ruptures, crushing your body into jam jelly."
        ];
        [[NOCEngine shared] print:msg completed:^{
            [self nextOffset];
            [[NOCEngine shared] nextScene:@"death"];
        }];
    } else {
        NSString *str = [NSString stringWithFormat:@"You jump into pod %@ and hit the eject button.", text];
        NSArray *msg = @[
            str,
            @"The pod easily slides out into space heading to the planet below.",
            @"As it flies to the planet, you look back and see your ship implode then explode like a bright star, taking out the Gothon ship at the same time.",
            @"You won!",
            @"[Game Over]"
        ];
        [[NOCEngine shared] print:msg completed:^{
            [self nextOffset];
            [[NOCEngine shared] nextScene:@"central_corridor"];
        }];
    }
}

- (void)nextOffset
{
    self.offset = (self.offset + 1) % 2;
}

- (NSString *)rand
{
    NSUInteger num = arc4random_uniform(5) + 1;
    return [NSString stringWithFormat:@"%@", @(num)];
}

@end
