#import <Foundation/Foundation.h>
#import "Card.h"

@interface CardFactory : NSObject

+ (instancetype)sharedFactory;

- (NSArray<Card *> *)generateDeck;
- (NSArray<Card *> *)generateShuffledDeck;

@end
