//
//  Mandelbrot.m
//  SampleGame
//
//  Created by Andreas Hanft on 21.04.11.
//  Copyright 2011 talantium.net All rights reserved.
//

#import "Mandelbrot.h"


@implementation Mandelbrot

+ (NSString*) uniformCenter
{
    return @"u_center";
}

+ (NSString*) uniformScale
{
    return @"u_scale";
}

- (id) init
{
    self = [super initWithName:@"Mandelbrot"];
    if (self)
    {
        [self bindAttributeNamed:B3DVertexAttributesPositionName toIndex:B3DVertexAttributesPosition];
        [self bindAttributeNamed:B3DVertexAttributesTexCoord0Name toIndex:B3DVertexAttributesTexCoord0];

        [self addUniformNamed:B3DShaderUniformMatrixMVP];
        [self addUniformNamed:B3DShaderUniformTextureBase];
        [self addUniformNamed:[Mandelbrot uniformCenter]];
        [self addUniformNamed:[Mandelbrot uniformScale]];
    }
    
    return self;
}

@end
