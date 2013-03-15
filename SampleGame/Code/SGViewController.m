//
//  SGViewController.m
//  SampleGame
//
//  Created by Andreas Hanft on 04.03.13.
//  Copyright (c) 2013 talantium.net. All rights reserved.
//

#import "SGViewController.h"

#import "SGLoadingScene.h"
#import "SGMenuScene.h"
#import "SGShaderDemoScene.h"


@implementation SGViewController

- (void) setupGLforView:(B3DGLView*)view
{
    // Always call super first!
    [super setupGLforView:view];
    
    // If needed, change some engine settings
//    self.desiredFPS = 30;
    self.engine.clearColor = [B3DColor colorWithRGBHex:0x2e2e2e];
    
    // Create and set root scene here!
    B3DScene* scene = [[SGLoadingScene alloc] init];
    [self.engine setAndLoadRootScene:scene];
    
    // Register additional scenes
    scene = [[SGMenuScene alloc] init];
    [self.engine addScene:scene];
    
    scene = [[SGShaderDemoScene alloc] init];
    [self.engine addScene:scene];
}

@end
