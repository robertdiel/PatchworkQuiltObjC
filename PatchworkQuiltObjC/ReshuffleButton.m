//
//  ReshuffleButton.m
//  PatchworkQuiltObjC
//
//  Created by Robert Diel on 6/11/25.
//


#import "ReshuffleButton.h"

@implementation ReshuffleButton

+ (instancetype)buttonWithImageNamed:(NSString*)imageName scale:(CGFloat)scale {
    ReshuffleButton *btn = [self spriteNodeWithImageNamed:imageName];
    btn.xScale = btn.yScale = scale;
    btn.name   = @"reshuffleButton";
    btn.userInteractionEnabled = YES;   // important!
    return btn;
}

// this runs when the node enters the scene graph
- (void)didMoveToParent {
//    [super didMoveToParent];
    // give it a higher z if you like
    self.zPosition = 100;
}

// handle clicks directly on the node
- (void)mouseDown:(NSEvent *)event {
    printf("MOUSE DOWN EVENT");
    if ([self.delegate respondsToSelector:@selector(reshuffleButtonWasTapped:)]) {
        [self.delegate reshuffleButtonWasTapped:self];
    }
}

@end
