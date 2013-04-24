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
        [self setPositionToX:screenSize.width/2 - size.width/2 andY:screenSize.height/2 - size.height/2 andZ:-5.0f];
//        [self setPositionToX:0 andY:0 andZ:-5.0f];
        [self useShader:[B3DShader tokenWithName:shaderName]];
        
        self.opaque = NO;
        self.batchable = NO;
    }
    
    return self;
}

- (void) update
{
    [super update];

    static float time = 0;
    time += [B3DTime deltaTime];
    
    float scale = [Bane3DEngine entity].contentScale;
    
    B3DShader* shader = self.material.shader;
    [shader setVector2Value:GLKVector2Make(self.size.width * scale, self.size.height * scale) forUniformNamed:@"resolution"];
    [shader setFloatValue:time forUniformNamed:@"time"];
    [shader setVector2Value:GLKVector2Make(self.position.x * scale, self.position.y * scale) forUniformNamed:@"u_offset"];
    
}

@end
