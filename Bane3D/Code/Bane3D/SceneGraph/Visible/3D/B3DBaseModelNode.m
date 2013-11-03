//
//  B3DBaseModelNode.m
//  Bane3D
//
//  Created by Andreas Hanft on 06.04.11.
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

#import "B3DBaseModelNode.h"

#import "B3DConstants.h"
#import "B3DColor.h"
#import "B3DShaderDefaultBaseColor.h"
#import "B3DTexturePVR.h"
#import "B3DTexturePNG.h"
#import "B3DAssetToken.h"
#import "B3DMaterial.h"
#import "B3DRenderMan.h"
#import "B3DTransparentNodeSorter.h"
#import "B3DScene.h"
#import "B3DCamera.h"
#import "B3DMesh.h"
#import "B3DVisibleNode+Protected.h"


@implementation B3DBaseModelNode

// Designated initializer
- (id) initWithMesh:(NSString*)meshName ofType:(NSString*)meshType
            texture:(NSString*)textureName ofType:(NSString*)textureType
{
	self = [super init];
	if (self)
	{
        [self useShader:[B3DShaderDefaultBaseColor token]];

        B3DAssetToken* token = nil;
        
		if (meshName != nil && meshType != nil)
		{
            token = [[B3DAssetToken alloc] init];
            if (meshType == B3DAssetTypeVolatile)
            {
                token.uniqueIdentifier = [B3DAssetToken uniqueIdForAsset:meshName withExtension:@"" ofType:meshType];
            }
            else
            {
                token.uniqueIdentifier = [B3DAssetToken uniqueIdForAsset:meshName withExtension:meshType];
            }
            [self useAssetWithToken:token
                          atKeyPath:@"mesh"];
		}
        
        if (textureName != nil && textureType != nil)
		{
            token = [[B3DAssetToken alloc] init];
            token.uniqueIdentifier = [B3DAssetToken uniqueIdForAsset:textureName withExtension:textureType];
            [self useAssetWithToken:token
                          atKeyPath:@"material.texture"];
		}

        _lineWidth = 4.0f;
    }
	
	return self;
}


- (void) awake
{
    [super awake];
    
    // Set default value
    [_material.shader setBoolValue:NO forUniformNamed:B3DShaderUniformToggleTextureAlphaOnly];
}


- (void) draw
{
    [super draw];

    // Complex 3D models are generally not considered batchable...
    if (_opaque)
    {   
        // ... if it is opaque we can render it right away...
        [self render];
    }
    else
    {
        // ... otherwise need to z-sort all transparent nodes prior drawing!
        [_renderMan.transparentNodeSorter addNode:self];
    }
}

- (void) render
{
    // Just for counting
    [_renderMan renderModel:self];
    
    static GLKMatrix4 matrix_mvp;
    if (self.useOrtho)
    {
        [self.parentScene useOrthoCamera];
    }
    
    // Create Model-View-Projection-Matrix based on currently used scene camera
    matrix_mvp = GLKMatrix4Multiply(self.parentScene.mainCamera.viewMatrix, [self worldTransform]);
    [_material.shader setMatrix4Value:matrix_mvp forUniformNamed:B3DShaderUniformMatrixMVP];
    [_material.shader setIntValue:0 forUniformNamed:B3DShaderUniformTextureBase];
    
    GLenum mode;
    switch (_renderer)
    {
        case B3DModelRendererPoint:
            // Draws every vertice as a single point
            mode = GL_POINTS;
            glDisable(GL_CULL_FACE);
            break;
            
        case B3DModelRendererLines:
            // Draws every vertice as lines
            mode = GL_LINES;
            glLineWidth(_lineWidth);
            break;
            
        case B3DModelRendererLineStrip:
            // Draws every vertice as lines
            mode = GL_LINE_STRIP;
            glLineWidth(_lineWidth);
            break;
            
        case B3DModelRendererLineLoop:
            // Draws every vertice as lines
            mode = GL_LINE_LOOP;
            glLineWidth(_lineWidth);
            break;
            
        case B3DModelRendererSolidStrip:
            mode = GL_TRIANGLE_STRIP;
            break;
            
        default:
            // Regular drawing as indexed triangles
            mode = GL_TRIANGLES;
            break;
    }

    // Set shader and texture
    [_material enable];
    [_mesh enable];
    
    // Regular drawing as indexed triangles
    glDrawElements(mode, _mesh.vertexIndexLength, GL_UNSIGNED_SHORT, [_mesh.vertexIndexData bytes]);

    [_mesh disable];
    [_material disable];
        
    switch (_renderer)
    {
        case B3DModelRendererPoint:
            glEnable(GL_CULL_FACE);
            break;
            
        default:
            break;
    }
}

@end
