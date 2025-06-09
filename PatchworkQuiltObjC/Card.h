#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

typedef NS_ENUM(NSInteger, CardSuit) {
    CardSuitHearts,
    CardSuitDiamonds,
    CardSuitClubs,
    CardSuitSpades
};

@interface Card : NSObject

@property (nonatomic, readonly) CardSuit suit;
@property (nonatomic, readonly) NSInteger rank; // 1 = Ace, 11 = Jack, etc.
@property (nonatomic, strong, readonly) SKTexture *texture;

- (instancetype)initWithSuit:(CardSuit)suit rank:(NSInteger)rank texture:(SKTexture *)texture;
- (NSString *)cardName;

@end
