//
//  B3DShaderDefaultSimpleColor.m
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

#import "B3DShaderDefaultSimpleColor.h"

#import "B3DConstants.h"


@implementation B3DShaderDefaultSimpleColor

- (id) init
{
    NSString* name = @"B3DShaderDefaultSimpleColor";
    
    NSString* vertexSource = [NSString stringWithFormat:@"\
    \
    uniform             mat4    %3$@;\
    \
    attribute           vec4    %1$@;\
    attribute           vec4    %2$@;\
    \
    varying     lowp    vec4    v_color;\
    \
    void main()\
    {\
        v_color = %2$@;\
        gl_Position = %3$@ * %1$@;\
    }", 
    B3DVertexAttributesPositionName,
    B3DVertexAttributesColorName,
    B3DShaderUniformMatrixMVP];

    
    NSString* fragmentSource = [NSString stringWithFormat:@"\
    \
    precision mediump float;\
    \
    varying     lowp    vec4    v_color;\
    \
    void main ()\
    {\
        gl_FragColor = v_color;\
    }"];
    
    self = [super initWithName:name
            vertexShaderSource:vertexSource
          fragmentShaderSource:fragmentSource];
    if (self)
    {
        // Register attributes for binding
        {
            [self bindAttributeNamed:B3DVertexAttributesPositionName toIndex:B3DVertexAttributesPosition];
            [self bindAttributeNamed:B3DVertexAttributesColorName toIndex:B3DVertexAttributesColor];
        }
        
        // Register uniforms
        {
            [self addUniformNamed:B3DShaderUniformMatrixMVP];
        }
    }
    
    return self;
}

@end
