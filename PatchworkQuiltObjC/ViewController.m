////
////  ViewController.m
////  PatchworkQuiltObjC
////
////  Created by Robert Diel on 6/8/25.
////
//
#import "ViewController.h"
#import <SpriteKit/SpriteKit.h>
#import "GameScene.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 1) Grab the SKView
    SKView *skView = (SKView *)self.view;
    skView.showsFPS       = YES;
    skView.showsNodeCount = YES;

    CGSize gameScreenSize = CGSizeMake(1024.0,768.0);
    // 2) Create your GameScene *in code*, sized to fill the view
    GameScene *scene = [[GameScene alloc] initWithSize:gameScreenSize];

    
    // 3) Make the scene’s coordinate system exactly match the view
    scene.scaleMode   = SKSceneScaleModeResizeFill;
    scene.anchorPoint = CGPointMake(0, 0);   // (0,0) bottom-left

    // 4) Present it
    [skView presentScene:scene];
    

    NSLog(@"Presented a %@ of size %@",
          NSStringFromClass([scene class]),
          NSStringFromSize(scene.size));
}

@end
