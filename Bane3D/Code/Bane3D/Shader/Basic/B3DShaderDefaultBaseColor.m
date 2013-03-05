//
//  B3DShaderDefaultBaseColor.m
//  Bane3D
//
//  Created by Andreas Hanft on 12.04.11.
//
//
//  Copyright (C) 2012 Andreas Hanft (talantium.net)
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included
//  in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
//  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

#import "B3DShaderDefaultBaseColor.h"

#import "B3DConstants.h"


@implementation B3DShaderDefaultBaseColor

- (id) init
{
    NSString* name = @"B3DShaderDefaultBaseColor";
    
    NSString* vertexSource = [NSString stringWithFormat:@"\
    \
    uniform mat4        %3$@;\
    \
    attribute vec4      %1$@;\
    attribute vec2      %2$@;\
    \
    varying vec2        v_texture_coords;\
    \
    void main()\
    {\
        v_texture_coords = %2$@;\
        gl_Position = %3$@ * %1$@;\
    }", 
    B3DVertexAttributesPositionName,
    B3DVertexAttributesTexCoord0Name,
    B3DShaderUniformMatrixMVP];

    
    NSString* fragmentSource = [NSString stringWithFormat:@"\
    \
    precision mediump float;\
    \
    uniform lowp sampler2D   %1$@;\
    uniform vec4             %2$@;\
    uniform vec4             %3$@;\
    uniform bool             %4$@;\
    \
    varying vec2             v_texture_coords;\
    \
    void main ()\
    {\
        if (%4$@)\
        {\
            float alpha = texture2D(%1$@, v_texture_coords).a;\
            gl_FragColor = %2$@ * %3$@ * alpha;\
        }\
        else\
        {\
            gl_FragColor = texture2D(%1$@, v_texture_coords) * %2$@ * %3$@;\
        }\
    }",
    B3DShaderUniformTextureBase,
    B3DShaderUniformColorBase,
    B3DShaderUniformColorAmbient,
    B3DShaderUniformToggleTextureAlphaOnly];
    
    self = [super initWithName:name
            vertexShaderSource:vertexSource
          fragmentShaderSource:fragmentSource];
    if (self)
    {
        // Register attributes for binding
        {
            [self bindAttributeNamed:B3DVertexAttributesPositionName toIndex:B3DVertexAttributesPosition];
            [self bindAttributeNamed:B3DVertexAttributesTexCoord0Name toIndex:B3DVertexAttributesTexCoord0];
        }
        
        // Register default uniforms
        {
            [self addUniformNamed:B3DShaderUniformMatrixMVP];
            [self addUniformNamed:B3DShaderUniformTextureBase];
            [self addUniformNamed:B3DShaderUniformColorBase];
            [self addUniformNamed:B3DShaderUniformColorAmbient];
            [self addUniformNamed:B3DShaderUniformToggleTextureAlphaOnly];
        }
    }
    
    return self;
}

@end
