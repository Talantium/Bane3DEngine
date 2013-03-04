//
//  B3DSprite.h
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

#import <Bane3D/SceneGraph/Visible/B3DVisibleNode.h>
#import <Bane3D/Core/B3DDatatypes.h>

@class B3DTexture;


@interface B3DSprite : B3DVisibleNode
{
	@protected
		CGSize					_size;
        CGPoint                 _origin;
        CGPoint                 _center;

        B3DTextureInfo			_textureInfo;
        B3DSpriteVertexData     _vertices[4];
    
        GLuint                  _vertexArrayObject;
        GLuint                  _vertexBufferObject;
}

@property (nonatomic, assign)	B3DTextureInfo	textureInfo;
@property (nonatomic, assign)	CGSize          size;
@property (nonatomic, assign)	CGPoint         center;
@property (nonatomic, assign)	CGPoint         origin;

// Create sprite without texture and only color and size
- (id) initWithSize:(CGSize)size andColor:(B3DColor*)baseColor;

// Texture Info for use with a texture atlas (always considered of type PVR!)
- (id) initWithTextureInfo:(B3DTextureInfo)textureInfo;
- (id) initWithPVRTexture:(NSString*)textureName;
- (id) initWithPNGTexture:(NSString*)textureName;
- (id) initWithTexture:(NSString*)textureName ofType:(NSString*)type;

- (B3DSpriteVertexData*) updateVerticeData;

@end
