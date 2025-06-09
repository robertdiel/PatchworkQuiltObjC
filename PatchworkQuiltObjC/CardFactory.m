//
//  CardFactory.m
//  PatchworkQuiltObjC
//
//  Created by Robert Diel on 6/8/25.
//


#import "CardFactory.h"

@implementation CardFactory {
    NSArray<SKTexture *> *_cardTextures;
}

+ (instancetype)sharedFactory {
    static CardFactory *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CardFactory alloc] initPrivate];
    });
    return sharedInstance;
}

- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        [self loadTextures];
    }
    return self;
}

- (void)loadTextures {
    SKTexture *spriteSheet = [SKTexture textureWithImageNamed:@"cards_spritesheet"];
    spriteSheet.filteringMode = SKTextureFilteringNearest; // Optional: prevents blur

    int columns = 13;
    int rows = 4;

    CGFloat cardWidth = 1.0 / (CGFloat)columns;
    CGFloat cardHeight = 1.0 / (CGFloat)rows;

    NSMutableArray<SKTexture *> *textures = [NSMutableArray arrayWithCapacity:52];

    for (int row = 0; row < rows; row++) {
        for (int col = 0; col < columns; col++) {
            CGRect rect = CGRectMake(col * cardWidth,
                                     1.0 - (row + 1) * cardHeight, // SpriteKit texture coords are bottom-left
                                     cardWidth,
                                     cardHeight);

            SKTexture *cardTexture = [SKTexture textureWithRect:rect inTexture:spriteSheet];
            [textures addObject:cardTexture];
        }
    }

    _cardTextures = [textures copy];
}


- (NSArray<Card *> *)generateDeck {
    NSMutableArray<Card *> *deck = [NSMutableArray arrayWithCapacity:52];

    for (CardSuit suit = CardSuitHearts; suit <= CardSuitSpades; suit++) {
        for (NSInteger rank = 1; rank <= 13; rank++) {
            NSInteger textureIndex = suit * 13 + (rank - 1);
            SKTexture *texture = _cardTextures[textureIndex];
            Card *card = [[Card alloc] initWithSuit:suit rank:rank texture:texture];
            [deck addObject:card];
        }
    }

    return [deck copy];
}

- (NSArray<Card *> *)generateShuffledDeck {
    NSMutableArray<Card *> *deck = [[self generateDeck] mutableCopy];
    NSUInteger count = deck.count;

    for (NSUInteger i = 0; i < count; i++) {
        NSUInteger j = arc4random_uniform((u_int32_t)count);
        [deck exchangeObjectAtIndex:i withObjectAtIndex:j];
    }

    return [deck copy];
}

@end
