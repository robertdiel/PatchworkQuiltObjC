//
//  GameScene.h
//  PatchworkQuiltObjC
//
//  Created by Robert Diel on 6/8/25.
//

#import <SpriteKit/SpriteKit.h>

@interface GameScene : SKScene

@property (nonatomic,strong) NSArray<SKSpriteNode*>           *slots;
@property (nonatomic,strong) NSMutableDictionary<NSNumber*,id> *slotOccupancy;
@property (nonatomic,strong) SKSpriteNode                      *draggedNode;
@property (nonatomic,assign) CGPoint                           originalPosition;

@end

