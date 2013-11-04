//
//  SGShaderNode.m
//  ShaderToy
//
//  Created by Andreas Hanft on 28.11.11.
//  Copyright (c) 2011 talantium.net. All rights reserved.
//

#import "SGShaderNode.h"


@implementation SGShaderNode

- (id) initWithShaderNamed:(NSString*)shaderName
{
    CGSize screenSize = [UIApplication currentSize];
    CGSize size = CGSizeMake(screenSize.width/2, screenSize.height/2);
    self = [super initWithSize:size color:[B3DColor whiteColor]];
    if (self)
    {
        self.name = shaderName;
        [self setPositionToX:screenSize.width/2 - size.width/2 y:screenSize.height/2 - size.height/2 z:-5.0f];
//        [self setPositionToX:0 y:0 z:-5.0f];
        [self useShader:[B3DShader tokenWithName:shaderName]];
        
        self.opaque = NO;
        self.batchable = NO;

        [self updateWithBlock:^(B3DNode *node, double deltaTime)
        {
            static float time = 0;
            time += deltaTime;

            float scale = [Bane3DEngine entity].contentScale;

            B3DSprite* nodeSelf = (B3DSprite*)node;

            B3DShader* shader = nodeSelf.material.shader;
            [shader setVector2Value:GLKVector2Make(nodeSelf.size.width * scale, nodeSelf.size.height * scale) forUniformNamed:@"resolution"];
            [shader setFloatValue:time forUniformNamed:@"time"];
            [shader setVector2Value:GLKVector2Make(nodeSelf.position.x * scale, nodeSelf.position.y * scale) forUniformNamed:@"u_offset"];
        }];
    }
    
    return self;
}

@end
