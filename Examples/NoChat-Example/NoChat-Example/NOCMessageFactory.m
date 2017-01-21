//
//  NOCMessageFactory.m
//  NoChat-Example
//
//  Created by little2s on 2017/1/21.
//  Copyright © 2017年 little2s. All rights reserved.
//

#import "NOCMessageFactory.h"
#import "NOCMessage.h"
#import <LoremIpsum/LoremIpsum.h>

@implementation NOCMessageFactory

+ (NSArray *)fetchMessagesWithNumber:(NSInteger)number
{
    NSArray *metaItems = [self fetchMetaItemsWithNumber:number];
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (NSDictionary *metaItem in metaItems) {
        NOCMessage *message = [NOCMessage new];
        message.senderDisplayName = metaItem[@"senderDisplayName"];
        message.text = metaItem[@"text"];
        [result addObject:message];
    }
    return result;
}

+ (NSArray *)fetchMetaItemsWithNumber:(NSInteger)number
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (NSInteger index = 0; index < number; index++) {
        NSDictionary *metaItem = @{
                                   @"senderDisplayName": [LoremIpsum name],
                                   @"dateString": @"Dec 26 17:01",
                                   @"text": [self richWords]
                                   };
        [result addObject:metaItem];
    }
    return result;
}

+ (NSString *)richWords
{
    NSInteger rd = arc4random() % 3;
    if (rd == 0) {
        NSInteger words1 = (arc4random() % 15) + 1;
        NSInteger words2 = (arc4random() % 15) + 1;
        return [NSString stringWithFormat:@"%@ %@ %@", [LoremIpsum wordsWithNumber:words1], [LoremIpsum URL].absoluteString, [LoremIpsum wordsWithNumber:words2]];
    } else {
        NSInteger words = (arc4random() % 40) + 1;
        return [LoremIpsum wordsWithNumber:words];
    }
}

@end
