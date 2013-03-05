//
//  B3DShader.h
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

#import <GLKit/GLKit.h>
#import <Bane3D/Resources/B3DAsset.h>

@class B3DShaderUnit;
@class B3DShaderUnitVertex;
@class B3DShaderUnitFragment;
@class B3DShaderUniform;

/* 
 Every shader must supply at least the following properties, they will be bound 
 by default.
 
    Uniforms:
    uniform mat4        u_matrix_mvp;       (B3DShaderUniformTextureBase)
    uniform sampler2D   u_texture_base;     (B3DShaderUniformTextureBase)
 
    Attributes:
    attribute vec4      a_position;         (B3DVertexAttributesPositionName bound to Index B3DVertexAttributesPosition)
    attribute vec2      a_texture_coords_0; (B3DVertexAttributesTexCoord0Name bound to Index B3DVertexAttributesTexCoord0)
 
*/

/*

 TEMP
 
// Validate program before drawing. This is a good check, but only really necessary in a debug build.
#if DEBUG
if (![self.material.program validate])
{
    NSLog(@"Failed to validate program: %d", mProgram);
    return;
}
#endif

*/


@interface B3DShader : B3DAsset <NSCopying>
{
    @protected
        B3DShaderUnit*          _vertexShader;
        B3DShaderUnit*          _fragmentShader;
}

+ (id) shaderNamed:(NSString*)name;

// Creates shader program and tries to load shader code from disk with name
// given (eg. 'name' = "MyShader" expects a vertex shader file called "MyShader.vert"
// and a frag shader fille called "MyShader.frag".
- (id) initWithName:(NSString*)name;

// Creates a shader program with given name and sources for vert and frag shader.
- (id) initWithName:(NSString*)name
 vertexShaderSource:(NSString*)vertexSource
fragmentShaderSource:(NSString*)fragmentSource;

// Designated init
- (id) initWithName:(NSString*)name
       vertexShader:(B3DShaderUnitVertex*)vertexShader
     fragmentShader:(B3DShaderUnitFragment*)fragmentShader;

@end


@interface B3DShader (DefaultShaderExtension)

+ (B3DShader*) shader;

@end


// Setting up shader properties must be done prior loading it!
@interface B3DShader (ShaderDataInputExtension)

// Attributes
- (void) bindAttributeNamed:(NSString*)attribute toIndex:(uint)index;

// Uniforms
- (BOOL) addUniformNamed:(NSString*)uniform;
- (B3DShaderUniform*) uniformNamed:(NSString*)name;

- (void) setBoolValue:(GLboolean)value forUniformNamed:(NSString*)uniform;
- (void) setIntValue:(GLint)value forUniformNamed:(NSString*)uniform;
- (void) setFloatValue:(GLfloat)value forUniformNamed:(NSString*)uniform;
- (void) setMatrix3Value:(GLKMatrix3)value forUniformNamed:(NSString*)uniform;
- (void) setMatrix4Value:(GLKMatrix4)value forUniformNamed:(NSString*)uniform;
- (void) setVector2Value:(GLKVector2)value forUniformNamed:(NSString*)uniform;
- (void) setVector3Value:(GLKVector3)value forUniformNamed:(NSString*)uniform;
- (void) setVector4Value:(GLKVector4)value forUniformNamed:(NSString*)uniform;
- (void) setColorValue:(B3DColor*)value forUniformNamed:(NSString*)uniform;

@end

