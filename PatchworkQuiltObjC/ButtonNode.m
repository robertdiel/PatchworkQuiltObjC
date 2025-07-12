//
//  ButtonNode.m
//  PatchworkQuiltObjC
//
//  Created by Robert Diel on 6/10/25.
//


#import "ButtonNode.h"

@implementation ButtonNode

- (instancetype)initWithTexture:(SKTexture *)texture
                            color:(SKColor *)color
                             size:(CGSize)size {
    self = [super initWithTexture:texture color:color size:size];
    if (self) {
        self.userInteractionEnabled = YES; // Enable interaction.
    }
    return self;
}


//- (void)touchesBegan:(NSSet<NSTouch *> *)touches withEvent:(UIEvent *)event {
//    [super touchesBegan:touches withEvent:event];
//    // Shrink the button slightly to indicate press
//    [self setScale:0.9];
//}
//
//- (void)touchesEnded:(NSSet<NSTouch *> *)touches withEvent:(UIEvent *)event {
//    [super touchesEnded:touches withEvent:event];
//    // Restore the button to its normal size
//    [self setScale:1.0];
//    // Notify the delegate
//    if ([self.delegate respondsToSelector:@selector(buttonClicked:)]) {
//        [self.delegate buttonClicked:self];
//    }
//}

@end
