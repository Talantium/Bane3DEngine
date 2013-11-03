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

@property (nonatomic, readwrite, strong) NSArray*       shaders;
@property (nonatomic, readwrite, strong) B3DLabel*      currentShaderInfo;
@property (nonatomic, readwrite, assign) NSUInteger     currentShaderIndex;

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
    
    shader = [B3DShader shaderNamed:@"704"];
    {
        [shader bindAttributeNamed:B3DVertexAttributesPositionName toIndex:B3DVertexAttributesPosition];
        
        [shader addUniformNamed:B3DShaderUniformMatrixMVP];
        [shader addUniformNamed:@"time"];
        [shader addUniformNamed:@"resolution"];
        [shader addUniformNamed:@"u_offset"];
    }
    [self registerAssetForUse:shader];
    
    shader = [B3DShader shaderNamed:@"Julia"];
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
            [button setPositionToX:screenSize.width - 24 - button.size.width y:screenSize.height - 64 z:-3];
            [button setAction:@selector(toggleShader) forTarget:self withObject:nil];
        }
        [self addChild:button];
        
        button = [SGButton buttonWithText:@"Back"];
        {
            [button setPositionToX:24 y:screenSize.height - 64 z:-3];
            [button setAction:@selector(presentSceneWithKey:) forTarget:self withObject:NSStringFromClass([SGMenuScene class])];
        }
        [self addChild:button];
        
        NSMutableArray* array = [NSMutableArray array];
               
        B3DGUIImage* shader = [[MandelbrotNode alloc] init];
        [array addObject:shader];
        [self addChild:shader];
        
        self.currentShaderInfo = [[B3DLabel alloc] initWithFontNamed:SGCommonBaseSceneFontName size:SGCommonBaseSceneFontSize];
        self.currentShaderInfo.color = [B3DColor colorWithRGBHex:0xcccccc];
        [self.currentShaderInfo translateByX:4 y:26 z:-3];
        self.currentShaderInfo.text = [NSString stringWithFormat:@"Current shader: %@", shader.name];
        [self addChild:self.currentShaderInfo];
        
        shader = [[SGShaderNode alloc] initWithShaderNamed:@"Julia"];
        shader.visible = NO;
        [array addObject:shader];
        [self addChild:shader];
        
        shader = [[SGShaderNode alloc] initWithShaderNamed:@"704"];
        shader.visible = NO;
        [array addObject:shader];
        [self addChild:shader];
        
        shader = [[SGShaderNode alloc] initWithShaderNamed:@"Apple"];
        shader.visible = NO;
        [array addObject:shader];
        [self addChild:shader];
        
        self.shaders = [NSArray arrayWithArray:array];
        
        
        B3DLabel* label = [[B3DLabel alloc] initWithFontNamed:SGCommonBaseSceneFontName size:SGCommonBaseSceneFontSize text:@"Some shaders are expensive, please be patient..."];
        label.color = [B3DColor colorWithRGBHex:0xcccccc];
        [label translateByX:4 y:4 z:-3];
        [self addChild:label];
    }
    
    return self;
}
- (void) toggleShader
{
    self.currentShaderIndex = (self.currentShaderIndex + 1) % self.shaders.count;
    
    for (int i = 0; i < self.shaders.count; i++)
    {
        B3DGUIImage* shader = self.shaders[i];
        shader.visible = (i == self.currentShaderIndex);
        if (shader.visible)
        {
            self.currentShaderInfo.text = [NSString stringWithFormat:@"Current shader: %@", shader.name];
        }
    }
}

@end
