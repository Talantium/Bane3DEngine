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
#import "B3DRenderMan.h"
#import "B3DCamera.h"
#import "B3DBaseNode+Protected.h"
#import "B3DVisibleNode+Protected.h"


@interface B3DSprite ()
{
    @private
        GLsizeiptr          _bufferSize;
}

- (void) createBuffers;
- (void) tearDownBuffers;

@end


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
        _batchable      = YES;
        _origin         = CGPointZero;
		
		if (textureName != nil && type != nil)
		{
            B3DAssetToken* token = [[B3DAssetToken alloc] init];
            token.uniqueIdentifier = [B3DAssetToken uniqueIdForAsset:textureName withExtension:type];
            [self useAssetWithToken:token
                          atKeyPath:@"material.texture"];
		}

		_textureInfo	= B3DTextureInfo(0, 0, 0, 0, "");
        static B3DSpriteVertexData vertice = {0.0f, 0.0f, 0.0f, 255, 255, 255, 255, 0, 0};
        _vertices[0] = vertice;
        _vertices[1] = vertice;
        _vertices[2] = vertice;
        _vertices[3] = vertice;
    }
	
	return self;
}

- (void) dealloc
{
    [self tearDownBuffers];

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
    
    [self createBuffers];
}

- (void) destroy
{
    [self tearDownBuffers];

    [super destroy];
}

#pragma mark - Buffer Handling

- (void) createBuffers
{
    // Creating VAO's must be done on the main thread, see
    // http://stackoverflow.com/questions/7125257/can-vertex-array-objects-vaos-be-shared-across-eaglcontexts-in-opengl-es
    
    dispatch_block_t block = ^(void)
    {
        // Create a buffer and array storage to render a single sprite node
        if (_vertexArrayObject == 0)
        {
            // Create and bind a vertex array object.
            glGenVertexArraysOES(1, &_vertexArrayObject);
            glBindVertexArrayOES(_vertexArrayObject);
            
            GLsizei size = sizeof(B3DSpriteVertexData);
            _bufferSize = size * 4;
            
            // Configure the attributes in the VAO.
            glGenBuffers(1, &_vertexBufferObject);
            glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferObject);
            glBufferData(GL_ARRAY_BUFFER, _bufferSize, NULL, GL_STREAM_DRAW);// GL_DYNAMIC_DRAW);
            
            glEnableVertexAttribArray(B3DVertexAttributesPosition);
            glVertexAttribPointer(B3DVertexAttributesPosition, 3, GL_FLOAT, GL_FALSE, size, BUFFER_OFFSET(0));
//            
//            glEnableVertexAttribArray(B3DVertexAttributesNormal);
//            glVertexAttribPointer(B3DVertexAttributesNormal, 3, GL_FLOAT, GL_FALSE, size, BUFFER_OFFSET(12));
            
            glEnableVertexAttribArray(B3DVertexAttributesColor);
            glVertexAttribPointer(B3DVertexAttributesColor, 4, GL_UNSIGNED_BYTE, GL_TRUE, size, BUFFER_OFFSET(12));
            
            glEnableVertexAttribArray(B3DVertexAttributesTexCoord0);
            glVertexAttribPointer(B3DVertexAttributesTexCoord0, 2, GL_UNSIGNED_SHORT, GL_TRUE, size, BUFFER_OFFSET(16));
            
//            glEnableVertexAttribArray(B3DVertexAttributesTexCoord1);
//            glVertexAttribPointer(B3DVertexAttributesTexCoord1, 2, GL_UNSIGNED_SHORT, GL_TRUE, size, BUFFER_OFFSET(32));
            
            // Bind back to the default state.
            glBindVertexArrayOES(0);
        }
    };
    
    if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

- (void) tearDownBuffers
{
    if (_vertexArrayObject != 0)
    {
        glDeleteBuffers(1, &_vertexBufferObject);
        glDeleteVertexArraysOES(1, &_vertexArrayObject);
    }
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
    if (_transformationDirty)
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
    //[self setScaleToX:size.width andY:size.height andZ:self.scale.z];
    _size = size;
}

- (void) draw
{
    [super draw];

    if (self.isOpaque)
    {
        if (_batchable)
        {
            // Send to renderman for sorting by material and batched rendering
            [_renderMan drawOpaqueSprite:self];
        }
        else
        {
            // If we cannot be batched for any reason, draw sprite immediately
            [self render];
        }
    }
    else
    {
        // We need to z-sort any nodes prior drawing!
        [_renderMan drawTransparentSprite:self];
    }
}

- (void) render
{
    // This call is just for counting!
    [_renderMan renderSprite:self];
    
    // -------------------------------------------------------------------------
    
    // Optimize access to some properties
//    static B3DTexture* texture = nil;
//    texture = self.material.texture;
    B3DShader* shader = self.material.shader;

    // Bind the vertex array storage for single sprite rendering
    glBindVertexArrayOES(_vertexArrayObject);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferObject);
    
//    [_stateManager useProgram:shader.openGlName];
    
    static GLKMatrix4 matrix_mvp;
    if (_useOrtho)
    {
        [self.parentScene useOrthoCamera];
    }
    
    // Create Model-View-Projection-Matrix based on currently used scene camera
    matrix_mvp = GLKMatrix4Multiply(self.parentScene.mainCamera.viewMatrix, [self absoluteTransform]);
    [shader setMatrix4Value:matrix_mvp forUniformNamed:B3DShaderUniformMatrixMVP];
    
    [shader setIntValue:0 forUniformNamed:B3DShaderUniformTextureBase];
    
    [_material enable];
    
    // Transmit the data of the sprite to the buffer
    glBufferData(GL_ARRAY_BUFFER, _bufferSize, NULL, GL_STREAM_DRAW);
    B3DSpriteVertexData* currentElementVertices = (B3DSpriteVertexData*) glMapBufferOES(GL_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
    memcpy(currentElementVertices, [self updateVerticeData], _bufferSize);
    glUnmapBufferOES(GL_ARRAY_BUFFER);
    
    // Finally draw
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    [_material disable];
    
    
//    glBufferData(GL_ARRAY_BUFFER, sizeof(B3DSpriteVertexData) * 4, NULL, GL_STREAM_DRAW);// GL_DYNAMIC_DRAW);
//    glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(B3DSpriteVertexData) * 4, [self updateVerticeData]);

    // http://playcontrol.net/ewing/jibberjabber/opengl_vertex_buffer_object.html
    // http://lists.apple.com/archives/mac-opengl/2008/Feb/msg00029.html
    // ??? APPLE_flush_buffer_range
    //    GLvoid* vbo_buffer = glMapBufferOES(GL_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
    //	// transfer the vertex data to the VBO
    //	memcpy(vbo_buffer, vertices, sizeof(B3DSpriteVertexData) * 4);
    //    glUnmapBufferOES(GL_ARRAY_BUFFER); 

    // Finally draw
//    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4); //GL_POINTS
    
    if (_useOrtho)
    {
        [self.parentScene usePerspectiveCamera];
    }
    
    glBindVertexArrayOES(0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

- (B3DSpriteVertexData*) updateVerticeData
{
    B3DTexture* texture = _material.texture;
    B3DColor* color = _color;
    
    // @TODO: Cache as much as possible of these calculations and assignments!
    
    // Update the positions of the four corner vertices
    // Bottom left corner is left unchanged at 0, 0
    _vertices[0].posX = (0.0f - _origin.x) * _size.width;
    _vertices[0].posY = (0.0f - _origin.y) * _size.height;
    _vertices[0].posZ = 0.0f;
    
    _vertices[1].posX = (1.0f - _origin.x) * _size.width;//_size.width;   // Bottom right
    _vertices[1].posY = (0.0f - _origin.y) * _size.height;   // Bottom right
    _vertices[1].posZ = 0.0f;
    
    _vertices[2].posX = (0.0f - _origin.x) * _size.width;  // Top left
    _vertices[2].posY = (1.0f - _origin.y) * _size.height;  // Top left
    _vertices[2].posZ = 0.0f;

    _vertices[3].posX = (1.0f - _origin.x) * _size.width;   // Top right
    _vertices[3].posY = (1.0f - _origin.y) * _size.height;  // Top right
    _vertices[3].posZ = 0.0f;
    
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
        
        _vertices[0].texCoord0U = xMin;
        _vertices[0].texCoord0V = yMin;
        _vertices[1].texCoord0U = xMax;
        _vertices[1].texCoord0V = yMin;
        _vertices[2].texCoord0U = xMin;
        _vertices[2].texCoord0V = yMax;
        _vertices[3].texCoord0U = xMax;
        _vertices[3].texCoord0V = yMax;
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
        _vertices[i].colR = colors[0];
        _vertices[i].colG = colors[1];
        _vertices[i].colB = colors[2];
        _vertices[i].colA = colors[3];
    }
    
    return _vertices;
}

@end
