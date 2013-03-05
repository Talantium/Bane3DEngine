//
//  SGMenuScene.m
//  SampleGame
//
//  Created by Andreas Hanft on 04.03.13.
//  Copyright (c) 2013 talantium.net. All rights reserved.
//

#import "SGMenuScene.h"


@implementation SGMenuScene

- (void) assetList
{
    [self registerAssetForUse:[B3DTextureFont defaultFontTexture]];
	[self registerAssetForUse:[B3DMesh3DS meshNamed:@"Teddy"]];
}

- (id) init
{
    self = [super init];
    if (self)
    {
        B3DLabel* label = [[B3DLabel alloc] initWithText:@"Bane3DEngine - FPS: ??"];
        label.color = [B3DColor colorWithRGBHex:0xcccccc];
        [label translateByX:2 andY:0 andZ:-10];
        [label updateWithBlock:^(B3DBaseNode* node, double deltaTime)
        {
            ((B3DLabel*)node).text = [NSString stringWithFormat:@"Bane3DEngine - FPS: %0.f", 1.0f/deltaTime];
        }];
        [self addSubNode:label];
        
        B3DBaseModelNode* model = [[B3DBaseModelNode alloc] initWithMesh:@"Teddy" ofType:B3DAssetMesh3DSDefaultExtension
                                                                 texture:nil ofType:nil];
        {
            model.renderer = B3DBaseModelNodeRendererLine;
            [model translateByX:0 andY:0 andZ:-4];
            [model rotateByX:-90 andY:0 andZ:0];
            [model updateWithBlock:^(B3DBaseNode* node, double deltaTime)
             {
                 [node rotateByAngle:30 * deltaTime aroundX:1 andY:1 andZ:0];
             }];
        }
        [self addSubNode:model];
    }
    
    return self;
}


@end
