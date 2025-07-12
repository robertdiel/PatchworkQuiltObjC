//
//  ButtonNode.h
//  PatchworkQuiltObjC
//
//  Created by Robert Diel on 6/10/25.
//


// ButtonNode.h
#import <SpriteKit/SpriteKit.h>

@class ButtonNode;

@protocol ButtonDelegate <NSObject>
- (void)buttonClicked:(ButtonNode *)sender;
@end

@interface ButtonNode : SKSpriteNode

@property (nonatomic, weak) id<ButtonDelegate> delegate;

- (instancetype)initWithTexture:(SKTexture *)texture
                            color:(SKColor *)color
                             size:(CGSize)size;

@end
