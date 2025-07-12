#import "GameScene.h"
#import "CardFactory.h"
#import "Card.h"
#import "ReshuffleButton.h"

@implementation GameScene

- (void)didMoveToView:(SKView *)view {
    //Initialize highlights
    self.highlightOverlays = [NSMutableArray array];
    
    self.remainingShuffles   = 3;


    // add camera node
    SKCameraNode *cam = [SKCameraNode node];
    cam.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    self.camera = cam;
    [self addChild:cam];

    
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
    
    [self addButton];
    
    // … your other setup …

    // 1) Instantiate the button
    ReshuffleButton *btn = [ReshuffleButton buttonWithImageNamed:@"card_back" scale:0.5f];
//    btn.delegate = self;

    // 2) Position it
    btn.position = CGPointMake(self.size.width - btn.size.width * 0.6,
                               btn.size.height * 0.6);

    // 3) Wire up the delegate
    btn.delegate = self;
    NSLog(@"🔗 ReshuffleButton delegate set to: %@", btn.delegate);

    // 4) Add it to the scene
    [self addChild:btn];
}

#pragma mark – ReshuffleButtonDelegate

- (void)reshuffleButtonWasTapped:(ReshuffleButton *)button {
    NSLog(@"IN Reshuffle");
    [self reshuffle];
}

- (void) addButton {
//    [super didMoveToView:view];

    // … your existing setup …

    // 1) Create the back‐of‐card sprite
    SKSpriteNode *cardBack = [SKSpriteNode spriteNodeWithImageNamed:@"card_back"];

    // 2) Size it (optional—defaults to the image’s pixel size)
    CGFloat scale = 0.7f; // or whatever fits your layout
    cardBack.size = CGSizeMake(cardBack.texture.size.width * scale,
                               cardBack.texture.size.height * scale);

    // 3) Position it where you like
    //    e.g. centered in the scene:
    cardBack.position = CGPointMake(self.size.width * 0.5,
                                    self.size.height - 100.0);

    // 4) Make sure it’s on top or behind by adjusting zPosition
    cardBack.zPosition = 5;

    // 5) Finally add it to the scene
    [self addChild:cardBack];
}

//- (void) addButton {
//    SKTexture *cardTexture = [SKTexture textureWithImageNamed:@"card_back"];
//    SKSpriteNode *cardNode = [SKSpriteNode spriteNodeWithTexture:cardTexture];
//    [self addChild:cardNode];
////    let image = SKSpriteNode(imageNamed: "myImage.png")
//
//
//}

//- (IBAction)reshuffleTapped:(id)sender {
//    GameScene *scene = (GameScene *)self.skView.scene;
//    [scene reshuffle];
//}

- (void)checkForWinOrLose {
    BOOL won = YES;
    for (int row = 0; row < 4 && won; row++) {
        for (int col = 0; col < 12; col++) {
            NSInteger idx = row * 13 + col;
            id occ = self.slotOccupancy[@(idx)];

            // make sure it’s actually a card node
            if (![occ isKindOfClass:[SKSpriteNode class]]) {
                won = NO;
                break;
            }

            SKSpriteNode *cardNode = (SKSpriteNode *)occ;
            Card *c = cardNode.userData[@"card"];
            if (c.rank != col + 1) {
                won = NO;
                break;
            }
        }
    }

    if (won) {
        [self showEndGameAlertWithTitle:@"You Win!"
                                message:[NSString stringWithFormat:
                                         @"Great job! You finished with %ld reshuffles left.",
                                         (long)self.remainingShuffles]];
    }
    else if (self.remainingShuffles <= 0) {
        [self showEndGameAlertWithTitle:@"Game Over"
                                message:@"You’ve used up all your reshuffles."];
    }
}

- (void)showEndGameAlertWithTitle:(NSString*)title message:(NSString*)msg {
    NSAlert *a = [[NSAlert alloc] init];
    a.messageText = title;
    a.informativeText = msg;
    [a addButtonWithTitle:@"OK"];
    [a runModal];
    // optionally reset the game here
}
- (void)reshuffle {
    if (self.remainingShuffles <= 0) return;
    self.remainingShuffles--;

    // 1) Figure out which indices are “held” (A→Q in each row)
    NSMutableIndexSet *held = [NSMutableIndexSet indexSet];
    for (int row = 0; row < 4; row++) {
        for (int col = 0; col < 12; col++) {
            NSInteger idx = row * 13 + col;
            id occ = self.slotOccupancy[@(idx)];
            if (![occ isKindOfClass:[SKSpriteNode class]]) break;
            SKSpriteNode *node = occ;
            Card *c = node.userData[@"card"];
            if (c.rank == col + 1) {
                [held addIndex:idx];
            } else {
                break;
            }
        }
    }

    // 2) Build *one* list of (slotIndex,cardNode) pairs for everything NOT held
    NSMutableArray<NSNumber*>     *shuffleIndices = [NSMutableArray array];
    NSMutableArray<SKSpriteNode*> *shuffleCards   = [NSMutableArray array];

    for (SKSpriteNode *slot in self.slots) {
        NSInteger idx = [slot.userData[@"index"] integerValue];
        NSInteger col = idx % 13;
        // only care about columns 0–11 that aren’t “held”
        if (col < 12 && ![held containsIndex:idx]) {
            id occ = self.slotOccupancy[@(idx)];
            if ([occ isKindOfClass:[SKSpriteNode class]]) {
                [shuffleIndices addObject:@(idx)];
                [shuffleCards   addObject:occ];
                // mark the old slot empty *now*, so we never double-occupy
                self.slotOccupancy[@(idx)] = (id)[NSNull null];
            }
        }
    }

    // 3) Now both arrays are the same length (one entry per card to reshuffle)
    NSAssert(shuffleIndices.count == shuffleCards.count,
             @"Indices/Cards mismatch: %lu vs %lu",
             (unsigned long)shuffleIndices.count,
             (unsigned long)shuffleCards.count);

    // 4) Fisher-Yates shuffle on the cards array
    for (NSUInteger i = shuffleCards.count - 1; i > 0; i--) {
        NSUInteger j = arc4random_uniform((u_int32_t)(i + 1));
        [shuffleCards exchangeObjectAtIndex:i withObjectAtIndex:j];
    }

    // 5) Redeal: animate each card into its new slot
    for (NSUInteger i = 0; i < shuffleCards.count; i++) {
        NSInteger newIdx             = [shuffleIndices[i] integerValue];
        SKSpriteNode *cardToPlace    = shuffleCards[i];
        SKSpriteNode *targetSlot     = self.slots[newIdx];

        // update the card’s userData & occupancy map
        cardToPlace.userData[@"slotIndex"] = @(newIdx);
        self.slotOccupancy[@(newIdx)]       = cardToPlace;

        // animate
        SKAction *move = [SKAction moveTo:targetSlot.position duration:0.3];
        move.timingMode = SKActionTimingEaseOut;
        [cardToPlace runAction:move];
    }

    // 6) Finally check win/lose after animation
    [self runAction:
      [SKAction sequence:@[
         [SKAction waitForDuration:0.35],
         [SKAction runBlock:^{ [self checkForWinOrLose]; }]
      ]]];
}

#pragma mark – camera shake

- (SKAction *)shakeAction {
    CGPoint original = self.camera.position;
    CGFloat  ampX     = 10.0f;
    CGFloat  ampY     = 5.0f;
    NSUInteger shakes = 6;
    NSMutableArray<SKAction*> *ts = [NSMutableArray arrayWithCapacity:shakes+1];

    for (NSUInteger i = 0; i < shakes; i++) {
        // alternate random directions
        CGFloat dx = (arc4random_uniform(2) ? ampX : -ampX);
        CGFloat dy = (arc4random_uniform(2) ? ampY : -ampY);
        [ts addObject:[SKAction moveByX:dx y:dy duration:0.03]];
    }
    // return to origin
    [ts addObject:[SKAction moveTo:original duration:0.02]];
    return [SKAction sequence:ts];
}


#pragma mark – Touches / Drag & Drop

//- (void)mouseDown:(NSEvent *)event {
//    // Convert from view coords into scene coords
//    NSPoint viewPoint = [event locationInWindow];
//    CGPoint loc       = [self convertPointFromView:viewPoint];
//
//    SKNode *hit = [self nodeAtPoint:loc];
//    if ([hit isKindOfClass:[SKSpriteNode class]] && hit.userData[@"card"]) {
//        self.draggedNode      = (SKSpriteNode *)hit;
//        self.originalPosition = hit.position;
//        hit.zPosition         = 10;   // bring above slots
//    }
//}

- (void)mouseDragged:(NSEvent *)event {
    if (!self.draggedNode) return;
    NSPoint viewPoint = [event locationInWindow];
    CGPoint loc       = [self convertPointFromView:viewPoint];
    self.draggedNode.position = loc;
}

- (void)moveCard:(SKSpriteNode*)card toSlot:(SKSpriteNode*)slot {
    // 1) Figure out old & new indexes
//    NSLog(@"we in MoveCard");
    NSInteger oldIdx = [card.userData[@"slotIndex"] integerValue];
    NSInteger newIdx = [slot.userData[@"index"]      integerValue];

    // 2) Remove the old occupancy & assign the new
    [self.slotOccupancy removeObjectForKey:@(oldIdx)];
    self.slotOccupancy[@(newIdx)] = card;
    card.userData[@"slotIndex"]   = @(newIdx);

    // 3) Clear any highlights
    for (SKShapeNode *ov in self.highlightOverlays) {
        [ov removeFromParent];
    }
    [self.highlightOverlays removeAllObjects];
    self.activeSlot = nil;

    // 4) Animate the move
    SKAction *move = [SKAction moveTo:slot.position duration:0.25];
    move.timingMode = SKActionTimingEaseOut;
    [card runAction:move];
    
    SKAction *placeSfx = [SKAction playSoundFileNamed:@"card-place-4.ogg" waitForCompletion:NO];

    // 3) Run them in sequence (first sound, then move—or both at once)
    SKAction *seq = [SKAction group:@[ placeSfx ]];
    [card runAction:seq];
}

#pragma mark — mouseDown: override

- (void)mouseDown:(NSEvent *)event {
    // 1) Convert the click into scene-space coordinates
    NSPoint viewP   = [event locationInWindow];
    CGPoint sceneP  = [self convertPointFromView:viewP];

    // 2) If we have exactly one highlight & an activeSlot, see if this click should move it
    if (self.activeSlot && self.highlightOverlays.count > 0) {
        SKSpriteNode *cardToMove = nil;
        SKNode *hitNode = [self nodeAtPoint:sceneP];

        // 2A) Click on the overlay itself?
        if ([hitNode isKindOfClass:[SKShapeNode class]] &&
            [self.highlightOverlays containsObject:(SKShapeNode*)hitNode]) {
            cardToMove = (SKSpriteNode*)hitNode.parent;
        }
        // 2B) Click on the card sprite itself?
        else if ([hitNode isKindOfClass:[SKSpriteNode class]] &&
                 hitNode.userData[@"card"]) {
            SKShapeNode *ov = self.highlightOverlays.firstObject;
            if (ov.parent == hitNode) {
                cardToMove = (SKSpriteNode*)hitNode;
            }
        }
        // 2C) Click on the slot (hole) itself?
        if (!cardToMove) {
            CGPoint pInSlot = [self.activeSlot convertPoint:sceneP fromNode:self];
            if ([self.activeSlot containsPoint:pInSlot]) {
                SKShapeNode *ov = self.highlightOverlays.firstObject;
                cardToMove = (SKSpriteNode*)ov.parent;
            }
        }
        

        
        if (cardToMove) {
            [self moveCard:cardToMove toSlot:self.activeSlot];
            return;
        }
    }

    // 3) Otherwise, check if we clicked inside any slot → highlight or prepare to move on second click
    for (SKSpriteNode *slot in self.slots) {
        // local-coords hit test
        CGPoint pInSlot = [slot convertPoint:sceneP fromNode:self];
        CGRect slotBounds = CGRectMake(
            -slot.size.width  * slot.anchorPoint.x,
            -slot.size.height * slot.anchorPoint.y,
             slot.size.width,
             slot.size.height
        );
        if (!CGRectContainsPoint(slotBounds, pInSlot)) continue;

        NSInteger idx    = [slot.userData[@"index"] integerValue];
        id occ           = self.slotOccupancy[@(idx)];
        BOOL isEmpty     = (occ == nil || occ == (id)[NSNull null]);
        NSInteger column = idx % 13;

//        NSInteger leftIdx = idx - 1;
        NSInteger leftIdx = idx - 1;
        id leftOcc = self.slotOccupancy[@(leftIdx)];
        if ([leftOcc isKindOfClass:[SKSpriteNode class]]) {
            SKSpriteNode *leftNode = (SKSpriteNode*)leftOcc;
            Card *leftCard = leftNode.userData[@"card"];
            if (leftCard.rank == 12) {
                // shake camera and bail
                [self.camera runAction:[self shakeAction]];
                
                SKAction *errorSfx = [SKAction playSoundFileNamed:@"error_008.ogg" waitForCompletion:NO];

                // 3) Run them in sequence (first sound, then move—or both at once)
                SKAction *seq = [SKAction group:@[ errorSfx ]];
                [leftOcc runAction:seq];
                
                return;
            }
        }
        
        if (isEmpty) {
            // a) second-click on same slot with one highlight → move
            if (slot == self.activeSlot && self.highlightOverlays.count == 1) {
                SKShapeNode *ov   = self.highlightOverlays.firstObject;
                SKSpriteNode *card = (SKSpriteNode*)ov.parent;
                [self moveCard:card toSlot:slot];
                return;
            }

            // b) first click → clear old highlights, highlight new candidates
            [self.highlightOverlays makeObjectsPerformSelector:@selector(removeFromParent)];
            [self.highlightOverlays removeAllObjects];

            if (column == 0) {
                // highlight all aces
                NSMutableArray<SKSpriteNode*> *aces = [NSMutableArray array];
                [self.slotOccupancy enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id val, BOOL *stop) {
                    if ([val isKindOfClass:[SKSpriteNode class]]) {
                        Card *c = ((SKSpriteNode*)val).userData[@"card"];
                        if (c.rank == 1) [aces addObject:val];
                    }
                }];
                [self highlightCardNodes:aces];
            } else {
                // highlight the single valid follower
                SKSpriteNode *cand = [self candidateCardNodeForSlot:slot];
                if (cand) [self highlightCardNodes:@[cand]];
            }

            self.activeSlot = slot;
            return;  // don’t start a drag
        }

        break;  // occupied slot: fall through to drag logic
    }

    // 4) Finally, normal drag-pick up if you clicked a card
    SKNode *hit = [self nodeAtPoint:sceneP];
    if ([hit isKindOfClass:[SKSpriteNode class]] && hit.userData[@"card"]) {
        self.draggedNode      = (SKSpriteNode*)hit;
        self.originalPosition = hit.position;
        hit.zPosition         = 10;
    }
}


#pragma mark — find the one card that fits

- (SKSpriteNode *)candidateCardNodeForSlot:(SKSpriteNode *)slot {
    NSInteger idx = [slot.userData[@"index"] integerValue];
    NSInteger col = idx % 13;
    // Aces go in col 0
    if (col == 0) {
        for (id occ in self.slotOccupancy.allValues) {
            if ([occ isKindOfClass:[SKSpriteNode class]]) {
                Card *c = ((SKSpriteNode*)occ).userData[@"card"];
                if (c.rank == 1) return occ;
            }
        }
        return nil;
    }
    // otherwise look left
    NSInteger leftIdx = idx - 1;
    id leftOcc = self.slotOccupancy[@(leftIdx)];
    if (![leftOcc isKindOfClass:[SKSpriteNode class]]) return nil;
    Card *leftCard = ((SKSpriteNode*)leftOcc).userData[@"card"];
    // find the one rank-higher, same-suit
    for (id occ in self.slotOccupancy.allValues) {
        if ([occ isKindOfClass:[SKSpriteNode class]]) {
            Card *c = ((SKSpriteNode*)occ).userData[@"card"];
            if (c.suit == leftCard.suit && c.rank == leftCard.rank + 1) {
                return occ;
            }
        }
    }
    return nil;
}

#pragma mark — highlight it!

- (void)highlightCardNode:(SKSpriteNode *)card {
    // 1) remove any existing highlight
    [self.highlightOverlay removeFromParent];
    self.highlightOverlay = nil;

    // 2) Create the overlay box
    SKShapeNode *overlay = [SKShapeNode shapeNodeWithRectOfSize:card.size cornerRadius:4];
    overlay.fillColor   = [[NSColor greenColor] colorWithAlphaComponent:0.4];
    overlay.strokeColor = [NSColor clearColor];
    
    // 3) Compute the offset from the card's origin to its center
    //    card.anchorPoint.x/y tell you where the origin is in [0–1] of the size.
    CGFloat dx = (0.5 - card.anchorPoint.x) * card.size.width;
    CGFloat dy = (0.5 - card.anchorPoint.y) * card.size.height;
    
    // 4) Place the overlay at that offset
    overlay.position    = CGPointMake(dx, dy);
    overlay.zPosition   = card.zPosition + 1;
    
    // 5) Add it as a child of the card
    [card addChild:overlay];
    self.highlightOverlay = overlay;

    // 6) Fade it out if you like
    [overlay runAction:
       [SKAction sequence:@[
         [SKAction waitForDuration:0.8],
         [SKAction fadeOutWithDuration:0.3],
         [SKAction removeFromParent]
    ]]];
}

- (void)highlightCardNodes:(NSArray<SKSpriteNode*>*)cards {
    // remove any old overlays
    for (SKShapeNode *ov in self.highlightOverlays) {
        [ov removeFromParent];
    }
    [self.highlightOverlays removeAllObjects];

    // for each card, add a centered translucent box
    for (SKSpriteNode *card in cards) {
        SKShapeNode *overlay = [SKShapeNode shapeNodeWithRectOfSize:card.size cornerRadius:4];
        overlay.fillColor   = [[NSColor greenColor] colorWithAlphaComponent:0.4];
        overlay.strokeColor = [NSColor clearColor];

        // compute offset so it centers no matter the card.anchorPoint
        CGFloat dx = (0.5 - card.anchorPoint.x) * card.size.width;
        CGFloat dy = (0.5 - card.anchorPoint.y) * card.size.height;
        overlay.position    = CGPointMake(dx, dy);
        overlay.zPosition   = card.zPosition + 1;

        [card addChild:overlay];
        [self.highlightOverlays addObject:overlay];

        // fade out after a bit if you like
        [overlay runAction:
          [SKAction sequence:@[
            [SKAction waitForDuration:0.8],
            [SKAction fadeOutWithDuration:0.3],
            [SKAction removeFromParent]
        ]]];
    }
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
    if (targetSlot && [self canPlaceCard:self.draggedNode inSlot:targetSlot]) {
        // free old
        NSInteger oldIdx = [self.draggedNode.userData[@"slotIndex"] integerValue];
        self.slotOccupancy[@(oldIdx)] = [NSNull null];

        // snap into new
        NSInteger newIdx = [targetSlot.userData[@"index"] integerValue];
        self.draggedNode.position                = targetSlot.position;
        self.draggedNode.userData[@"slotIndex"] = @(newIdx);
        self.slotOccupancy[@(newIdx)]           = self.draggedNode;
        didSnap = YES;
    }

    if (!didSnap) {
        SKAction *errorSfx = [SKAction playSoundFileNamed:@"error_008.ogg" waitForCompletion:NO];

        // 3) Run them in sequence (first sound, then move—or both at once)
        SKAction *seq = [SKAction group:@[ errorSfx ]];
        [self.draggedNode runAction:seq];
        // shake the camera
        [self.camera runAction:[self shakeAction]];
        // move back card
        [self.draggedNode runAction:[SKAction moveTo:self.originalPosition duration:0.2]];
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
    
    //Play no move sound effect
    if (leftCard.rank == 12) {
        
        SKAction *errorSfx = [SKAction playSoundFileNamed:@"error_008.ogg" waitForCompletion:NO];

        // 3) Run them in sequence (first sound, then move—or both at once)
        SKAction *seq = [SKAction group:@[ errorSfx ]];
        [leftNode runAction:seq];

    }
    //  → same suit & one less in rank
    return (leftCard.suit == c.suit) && (c.rank == leftCard.rank + 1);
}



@end
