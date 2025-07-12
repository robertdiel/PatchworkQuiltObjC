//
//  ReshuffleButton.h
//  PatchworkQuiltObjC
//
//  Created by Robert Diel on 6/11/25.
//


#import <SpriteKit/SpriteKit.h>

@class ReshuffleButton;
@protocol ReshuffleButtonDelegate <NSObject>
- (void)reshuffleButtonWasTapped:(ReshuffleButton*)button;
@end

@interface ReshuffleButton : SKSpriteNode

@property (nonatomic, weak) id<ReshuffleButtonDelegate> delegate;

// convenience factory
+ (instancetype)buttonWithImageNamed:(NSString*)imageName
                               scale:(CGFloat)scale;

@end
