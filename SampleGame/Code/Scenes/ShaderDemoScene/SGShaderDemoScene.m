//
//  SGShaderDemoScene.m
//  SampleGame
//
//  Created by Andreas Hanft on 15.03.13.
//  Copyright (c) 2013 talantium.net. All rights reserved.
//

#import "SGShaderDemoScene.h"

#import "SGMenuScene.h"
#import "SGButton.h"
#import "SGShaderNode.h"
#import "MandelbrotNode.h"
#import "Mandelbrot.h"


@interface SGShaderDemoScene ()

@property (nonatomic, readwrite, strong) MandelbrotNode*    mandelbrot;
@property (nonatomic, readwrite, strong) SGShaderNode*      otherShader;

@end


@implementation SGShaderDemoScene

- (void) assetList
{
    [super assetList];
    
    [self registerAssetForUse:[B3DTexturePNG textureNamed:@"fract_palette"]];
	[self registerAssetForUse:[Mandelbrot shader]];
    B3DShader* shader = [B3DShader shaderNamed:@"Apple"];
    {
        [shader bindAttributeNamed:B3DVertexAttributesPositionName toIndex:B3DVertexAttributesPosition];

        [shader addUniformNamed:B3DShaderUniformMatrixMVP];
        [shader addUniformNamed:@"time"];
        [shader addUniformNamed:@"resolution"];
        [shader addUniformNamed:@"u_offset"];
    }
    [self registerAssetForUse:shader];
}

- (id) init
{
    self = [super init];
    if (self)
    {
        CGSize screenSize = [UIApplication currentSize];

        SGButton* button = [SGButton buttonWithText:@"Toggle"];
        {
            [button setPositionToX:24 andY:screenSize.height - 64 andZ:-3];
            [button setAction:@selector(toggleShader) forTarget:self withObject:nil];
        }
        [self addSubNode:button];
        
        button = [SGButton buttonWithText:@"Back"];
        {
            [button setPositionToX:screenSize.width - 24 - button.size.width andY:screenSize.height - 64 andZ:-3];
            [button setAction:@selector(presentSceneWithKey:) forTarget:self withObject:NSStringFromClass([SGMenuScene class])];
        }
        [self addSubNode:button];
               
        self.mandelbrot = [[MandelbrotNode alloc] init];
        [self addSubNode:self.mandelbrot];
        
        self.otherShader = [[SGShaderNode alloc] initWithShaderNamed:@"Apple"];
        self.otherShader.visible = NO;
		[self addSubNode:self.otherShader];
    }
    
    return self;
}
- (void) toggleShader
{
    self.mandelbrot.visible = self.otherShader.visible;
    self.otherShader.visible = !self.mandelbrot.visible;
}

@end
