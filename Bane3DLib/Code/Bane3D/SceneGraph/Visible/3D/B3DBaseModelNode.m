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
#import "B3DNode+Protected.h"
#import "B3DVisibleNode+Protected.h"
#import "B3DMeshContainer.h"


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

- (Class) classForRenderContainer
{
    return [B3DMeshContainer class];
}

- (void) awake
{
    [super awake];
    
    // Set default value
    [_material.shader setBoolValue:NO forUniformNamed:B3DShaderUniformToggleTextureAlphaOnly];
}

@end
