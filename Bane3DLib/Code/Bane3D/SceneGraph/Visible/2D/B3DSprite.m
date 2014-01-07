//
//  B3DSprite.m
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

#import <OpenGLES/ES2/gl.h>

#import "B3DSprite.h"
#import "B3DSprite+Protected.h"

#import "B3DConstants.h"
#import "B3DColor.h"
#import "B3DShaderDefaultSimpleColor.h"
#import "B3DTexturePVR.h"
#import "B3DTexturePNG.h"
#import "B3DAssetToken.h"
#import "B3DMaterial.h"
#import "B3DScene.h"
#import "B3DLayer.h"
#import "B3DRenderMan.h"
#import "B3DCamera.h"
#import "B3DNode+Protected.h"
#import "B3DVisibleNode+Protected.h"
#import "B3DSpriteContainer.h"
#import "B3DMesh.h"


@implementation B3DSprite

@dynamic	center;


- (id) initWithSize:(CGSize)size color:(B3DColor*)baseColor
{    
	self = [self initWithTexture:nil ofType:nil];
	if (self)
	{
        [self useShader:[B3DShaderDefaultSimpleColor token]];

		_size		= size;
		self.color	= baseColor;
	}
	
	return self;
}

- (id) initWithTextureInfo:(B3DTextureInfo)textureInfo 
{
    return [self initWithTextureInfo:textureInfo type:[B3DTexturePVR extension]];
}

- (id) initWithTextureInfo:(B3DTextureInfo)textureInfo type:(NSString*)type
{
	NSString* textureName = [NSString stringWithCString:textureInfo.atlasName encoding:NSUTF8StringEncoding];
	
	self = [self initWithTexture:textureName ofType:type];
	if (self)
	{
		_textureInfo	= textureInfo;
		_size			= CGSizeMake(textureInfo.sourceRect.size.width, textureInfo.sourceRect.size.height);
	}
	
	return self;
}

- (id) initWithPVRTexture:(NSString*)textureName
{
	return [self initWithTexture:textureName ofType:[B3DTexturePVR extension]];
}

- (id) initWithPNGTexture:(NSString*)textureName
{
	return [self initWithTexture:textureName ofType:[B3DTexturePNG extension]];
}

// Designated initializer
- (id) initWithTexture:(NSString*)textureName ofType:(NSString*)type
{
	self = [super init];
	if (self)
	{
		_size           = CGSizeZero;
        _origin         = CGPointZero;
		
		if (textureName != nil && type != nil)
		{
            B3DAssetToken* token = [[B3DAssetToken alloc] init];
            token.uniqueIdentifier = [B3DAssetToken uniqueIdForAsset:textureName withExtension:type];
            [self useAssetWithToken:token
                          atKeyPath:@"material.texture"];
		}

		_textureInfo	= B3DTextureInfo(0, 0, 0, 0, "");
        _mesh           = [[B3DMesh alloc] initWithMesh:@"" ofType:B3DAssetTypeVolatile];
        _mesh.vertexCount = 4;
    }
	
	return self;
}

- (void) create
{
    [super create];
    
    if (_material.texture && _textureInfo.isUnset())
    {
        // Update source rect for textures that came without texture info
        B3DTexture* texture = _material.texture;
        _textureInfo.sourceRect = CGRectMake(0, 0, texture.width, texture.height);
        if (CGSizeEqualToSize(_size, CGSizeZero))
        {
            self.size = CGSizeMake(texture.width, texture.height);
        }
    }
}

- (Class) classForRenderContainer
{
    return [B3DSpriteContainer class];
}

#pragma mark - Properties

- (void) setTextureInfo:(B3DTextureInfo)textureInfo
{
    _textureInfo    = textureInfo;
    // Should size be adjusted also?
//    _size			= CGSizeMake(textureInfo.sourceRect.size.width, textureInfo.sourceRect.size.height);
}

- (CGPoint) center
{
    if (_transformDirty)
    {
        _center = CGPointMake(self.position.x + self.size.width / 2.0f, self.position.y + self.size.height / 2.0f);
    }
    
	return _center;
}

- (void) setCenter:(CGPoint)center
{
    self.position = GLKVector3Make(center.x - self.size.width / 2.0f, center.y - self.size.height / 2.0f, self.position.z);
}

- (void) setSize:(CGSize)size
{
    _size = size;
}

- (void) updateVerticeData
{
    B3DTexture* texture = _material.texture;
    B3DColor* color = _color;

    B3DSpriteVertexData vertices[_mesh.vertexCount];

    static B3DSpriteVertexData vertice = {0.0f, 0.0f, 0.0f, 255, 255, 255, 255, 0, 0};
    vertices[0] = vertice;
    vertices[1] = vertice;
    vertices[2] = vertice;
    vertices[3] = vertice;

    // Update the positions of the four corner vertices
    // Bottom left corner is left unchanged at 0, 0
    vertices[0].posX = (0.0f - _origin.x) * _size.width;
    vertices[0].posY = (0.0f - _origin.y) * _size.height;
    vertices[0].posZ = 0.0f;
    
    vertices[1].posX = (1.0f - _origin.x) * _size.width;//_size.width;   // Bottom right
    vertices[1].posY = (0.0f - _origin.y) * _size.height;   // Bottom right
    vertices[1].posZ = 0.0f;
    
    vertices[2].posX = (0.0f - _origin.x) * _size.width;  // Top left
    vertices[2].posY = (1.0f - _origin.y) * _size.height;  // Top left
    vertices[2].posZ = 0.0f;

    vertices[3].posX = (1.0f - _origin.x) * _size.width;   // Top right
    vertices[3].posY = (1.0f - _origin.y) * _size.height;  // Top right
    vertices[3].posZ = 0.0f;

    // Generate texture UV coords
    if (texture)
    {
        GLushort xMin, xMax, yMin, yMax;
        xMin = (_textureInfo.sourceRect.origin.x / texture.width) * USHRT_MAX;
        xMax = ((_textureInfo.sourceRect.origin.x + _textureInfo.sourceRect.size.width) / texture.width) * USHRT_MAX;
        yMin = (_textureInfo.sourceRect.origin.y / texture.height) * USHRT_MAX;
        yMax = ((_textureInfo.sourceRect.origin.y + _textureInfo.sourceRect.size.height) / texture.height) * USHRT_MAX;
        
        if (texture.invertX)
        {
            GLushort xTemp = xMin;
            xMin = xMax;
            xMax = xTemp;
        }        
        if (texture.invertY)
        {
            GLushort yTemp = yMin;
            yMin = yMax;
            yMax = yTemp;
        }
        
        vertices[0].texCoord0U = xMin;
        vertices[0].texCoord0V = yMin;
        vertices[1].texCoord0U = xMax;
        vertices[1].texCoord0V = yMin;
        vertices[2].texCoord0U = xMin;
        vertices[2].texCoord0V = yMax;
        vertices[3].texCoord0U = xMax;
        vertices[3].texCoord0V = yMax;
    }
    
    // Recalculate and set color
    GLubyte colors[4] =
    {
        static_cast<GLubyte>(color.r * 255),
        static_cast<GLubyte>(color.g * 255),
        static_cast<GLubyte>(color.b * 255),
        static_cast<GLubyte>(color.a * 255)
    };

    for (int i = 0; i < 4; i++)
    {
        vertices[i].colR = colors[0];
        vertices[i].colG = colors[1];
        vertices[i].colB = colors[2];
        vertices[i].colA = colors[3];
    }

    _mesh.vertexData = [NSMutableData dataWithBytes:vertices length:sizeof(B3DSpriteVertexData) * _mesh.vertexCount];
    _mesh.dirty = YES;
}

@end
