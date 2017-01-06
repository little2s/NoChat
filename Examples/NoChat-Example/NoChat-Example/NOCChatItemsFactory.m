//
//  NOCChatItemsFactory.m
//  NoChat-Example
//
//  Created by little2s on 2016/12/28.
//  Copyright © 2016年 little2s. All rights reserved.
//

#import "NOCChatItemsFactory.h"
#import <LoremIpsum/LoremIpsum.h>
#import "NOCMMessage.h"

@implementation NOCChatItemsFactory

+ (NSArray *)fetchMinimalChatItemsWithNumber:(NSInteger)number
{
    NSArray *metaItems = [self fetchMetaItemsWithNumber:number];
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (NSDictionary *metaItem in metaItems) {
        NOCMMessage *message = [[NOCMMessage alloc] init];
        message.senderDisplayName = metaItem[@"senderDisplayName"];
        message.dateString = metaItem[@"dateString"];
        message.text = metaItem[@"text"];
        [result addObject:message];
    }
    return result;
}

+ (NSArray *)fetchMetaItemsWithNumber:(NSInteger)number
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (NSInteger index = 0; index < number; index++) {
        NSInteger words = (arc4random() % 40) + 1;
        
        NSDictionary *metaItem = @{
            @"senderDisplayName": [LoremIpsum name],
            @"dateString": @"Dec 26 17:01",
            @"text": [LoremIpsum wordsWithNumber:words]
        };
        [result addObject:metaItem];
    }
    return result;
}

@end
