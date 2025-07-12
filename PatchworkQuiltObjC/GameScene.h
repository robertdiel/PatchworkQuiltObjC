//
//  GameScene.h
//  PatchworkQuiltObjC
//
//  Created by Robert Diel on 6/8/25.
//

#import <SpriteKit/SpriteKit.h>
#import "ReshuffleButton.h"

@interface GameScene : SKScene  <ReshuffleButtonDelegate>

@property (nonatomic,strong) NSArray<SKSpriteNode*>           *slots;
@property (nonatomic,strong) NSMutableDictionary<NSNumber*,id> *slotOccupancy;
@property (nonatomic,strong) SKSpriteNode                      *draggedNode;
@property (nonatomic,assign) CGPoint                           originalPosition;
// in your @interface extension at top of GameScene.m
@property (nonatomic, strong) SKShapeNode *highlightOverlay;
// at top of GameScene.m in your @interface extension
@property (nonatomic, strong) NSMutableArray<SKShapeNode*> *highlightOverlays;
@property (nonatomic, strong) SKSpriteNode *activeSlot;

/// How many reshuffles are left
@property (nonatomic, assign) ReshuffleButton* reshuffleButton;
@property (nonatomic, assign) NSInteger remainingShuffles;

@end

