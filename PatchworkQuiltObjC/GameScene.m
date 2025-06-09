#import "GameScene.h"
#import "CardFactory.h"
#import "Card.h"

@implementation GameScene

- (void)didMoveToView:(SKView *)view {
    self.anchorPoint = CGPointMake(0, 0);

    // 1) Layout constants
    CGFloat scale    = 0.7f;
    CGFloat spacing  = 10.0f;
    int     columns  = 13;
    int     rows     = 4;

    // 2) Measure real card size via a sample texture
    NSArray<Card *> *fullDeck = [[CardFactory sharedFactory] generateShuffledDeck];
    SKTexture       *sampleTex = fullDeck.firstObject.texture;
    SKSpriteNode    *probe     = [SKSpriteNode spriteNodeWithTexture:sampleTex];
    probe.xScale = probe.yScale = scale;
    CGSize           cardSize  = probe.size;            // ~89.6×67.2

    // 3) Compute the grid’s total size
    CGFloat totalW = columns * cardSize.width  + (columns - 1) * spacing;
    CGFloat totalH = rows    * cardSize.height + (rows    - 1) * spacing;

    // 4) Center the grid in the scene
    CGSize sceneSize = self.size;
    CGFloat startX   = (sceneSize.width  - totalW) / 2.0f;
    CGFloat startY   = (sceneSize.height + totalH) / 2.0f;

    // 5) Prepare our slot arrays
    NSMutableArray           *slotsArr = [NSMutableArray arrayWithCapacity:52];
    NSMutableDictionary     *occupancy = [NSMutableDictionary dictionaryWithCapacity:52];

    // 6) Create all 52 slots (empty placeholder nodes)
    for (int i = 0; i < fullDeck.count; i++) {
        int    col = i % columns;
        int    row = i / columns;
        CGPoint pos = CGPointMake(
            startX + col * (cardSize.width  + spacing),
            startY - row * (cardSize.height + spacing)
        );

        SKSpriteNode *slot = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor]
                                                           size:cardSize];
        slot.position    = pos;
        slot.anchorPoint = CGPointMake(0, 1);  // top-left
        slot.name        = @"slot";
        slot.zPosition   = 0;
        slot.userData    = [@{@"index": @(i)} mutableCopy];

        [self addChild:slot];
        [slotsArr addObject:slot];
        occupancy[@(i)] = [NSNull null];  // empty
    }

    // 7) Now place every non-King card into its slot
    for (int i = 0; i < fullDeck.count; i++) {
        Card *c = fullDeck[i];
        if (c.rank == 13) continue;      // skip Kings

        SKSpriteNode *slot = slotsArr[i];
        SKSpriteNode *cardNode = [SKSpriteNode spriteNodeWithTexture:c.texture];
        cardNode.size        = cardSize;
        cardNode.anchorPoint = CGPointMake(0, 1);
        cardNode.position    = slot.position;
        cardNode.zPosition   = 1;
        cardNode.userData    = [@{@"card": c, @"slotIndex": @(i)} mutableCopy];

        [self addChild:cardNode];
        occupancy[@(i)] = cardNode;      // mark it occupied
    }

    self.slots          = [slotsArr copy];
    self.slotOccupancy  = occupancy;
}

#pragma mark – Touches / Drag & Drop

- (void)mouseDown:(NSEvent *)event {
    // Convert from view coords into scene coords
    NSPoint viewPoint = [event locationInWindow];
    CGPoint loc       = [self convertPointFromView:viewPoint];

    SKNode *hit = [self nodeAtPoint:loc];
    if ([hit isKindOfClass:[SKSpriteNode class]] && hit.userData[@"card"]) {
        self.draggedNode      = (SKSpriteNode *)hit;
        self.originalPosition = hit.position;
        hit.zPosition         = 10;   // bring above slots
    }
}

- (void)mouseDragged:(NSEvent *)event {
    if (!self.draggedNode) return;
    NSPoint viewPoint = [event locationInWindow];
    CGPoint loc       = [self convertPointFromView:viewPoint];
    self.draggedNode.position = loc;
}

- (void)mouseUp:(NSEvent *)event {
    if (!self.draggedNode) return;

    // 1) Convert to scene coords
    NSPoint viewPoint = [event locationInWindow];
    CGPoint loc       = [self convertPointFromView:viewPoint];

    // 2) Define how much bigger you want the drop zone
    CGFloat dropZoneMargin = 20.0f;  // 20 pts extra on every side

    // 3) Find the slot whose *enlarged* frame contains the touch
    SKSpriteNode *targetSlot = nil;
    for (SKSpriteNode *slot in self.slots) {
        // enlarge the frame by dropZoneMargin in every direction
        CGRect hitRect = CGRectInset(slot.frame, -dropZoneMargin, -dropZoneMargin);
        if (CGRectContainsPoint(hitRect, loc)) {
            targetSlot = slot;
            break;
        }
    }

    BOOL didSnap = NO;
    if (targetSlot) {
        NSInteger idx = [targetSlot.userData[@"index"] integerValue];
        if (self.slotOccupancy[@(idx)] == (id)[NSNull null]) {
            // free the old slot
            NSInteger oldIdx = [self.draggedNode.userData[@"slotIndex"] integerValue];
            self.slotOccupancy[@(oldIdx)] = [NSNull null];

            // snap into new slot
            self.draggedNode.position                = targetSlot.position;
            self.draggedNode.userData[@"slotIndex"] = @(idx);
            self.slotOccupancy[@(idx)]              = self.draggedNode;
            didSnap = YES;
        }
    }

    // 4) Snap back if invalid
    if (!didSnap) {
        [self.draggedNode runAction:
            [SKAction moveTo:self.originalPosition duration:0.2]];
    }

    // 5) Clean up
    self.draggedNode.zPosition = 1;
    self.draggedNode = nil;
}

- (BOOL)canPlaceCard:(SKSpriteNode *)mover inSlot:(SKSpriteNode *)slot {
    NSInteger idx   = [slot.userData[@"index"] integerValue];
    Card      *c    = mover.userData[@"card"];
    
    // 1) slot must be empty
    if ( self.slotOccupancy[@(idx)] != (id)[NSNull null] ) return NO;
    
    // 2) compute column
    NSInteger col = idx % 13;
    
    //  → far-left: only Aces
    if (col == 0) {
        return c.rank == 1;
    }
    
    //  → otherwise must have a card to the left
    NSInteger leftIdx = idx - 1;
    id leftOccupant   = self.slotOccupancy[@(leftIdx)];
    if ( leftOccupant == (id)[NSNull null] ) return NO;
    
    SKSpriteNode *leftNode = (SKSpriteNode *)leftOccupant;
    Card *leftCard = leftNode.userData[@"card"];
    
    //  → same suit & one less in rank
    return (leftCard.suit == c.suit) && (c.rank == leftCard.rank + 1);
}



@end
