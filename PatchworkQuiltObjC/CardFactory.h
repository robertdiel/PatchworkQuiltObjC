//
//  CardFactory.h
//  PatchworkQuiltObjC
//
//  Created by Robert Diel on 6/8/25.
//


#import <Foundation/Foundation.h>
#import "Card.h"

@interface CardFactory : NSObject

+ (instancetype)sharedFactory;

- (NSArray<Card *> *)generateDeck;
- (NSArray<Card *> *)generateShuffledDeck;

@end
