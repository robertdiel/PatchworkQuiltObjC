#import "Card.h"

@implementation Card

- (instancetype)initWithSuit:(CardSuit)suit rank:(NSInteger)rank texture:(SKTexture *)texture {
    self = [super init];
    if (self) {
        _suit = suit;
        _rank = rank;
        _texture = texture;
    }
    return self;
}

- (NSString *)cardName {
    NSString *rankStr;
    switch (self.rank) {
        case 1:  rankStr = @"A"; break;
        case 11: rankStr = @"J"; break;
        case 12: rankStr = @"Q"; break;
        case 13: rankStr = @"K"; break;
        default: rankStr = [NSString stringWithFormat:@"%ld", (long)self.rank]; break;
    }

    NSString *suitStr = @[@"♥", @"♦", @"♣", @"♠"][_suit];
    return [NSString stringWithFormat:@"%@%@", rankStr, suitStr];
}

@end
