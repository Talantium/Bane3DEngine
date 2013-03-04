//
//  B3DTexturePVR.m
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

#include <algorithm>

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "B3DTexturePVR.h"

#import "B3DAsset+Protected.h"
#import "B3DTexture_Protected.h"



/*!***************************************************************************
						PVR Texture Loading Metadata
 
 (Only required stuff copied from Imagination Technologies Limited code file)
 
 *****************************************************************************/


/*****************************************************************************
 * Misc defs, macros, etc.
 *****************************************************************************/

#define PVRTSIZEASSERT(T, size) typedef int (sizeof_##T)[sizeof(T) == (size)]

typedef unsigned int       PVRTuint32;
PVRTSIZEASSERT(PVRTuint32, 4);

const PVRTuint32 PVRTEX_PIXELTYPE		= 0xff;			// pixel type is always in the last 16bits of the flags


/*****************************************************************************
 * Describes the header of a PVR header-texture
 *****************************************************************************/

struct PVRTextureHeader
{
	PVRTuint32 dwHeaderSize;			/*!< size of the structure */
	PVRTuint32 dwHeight;				/*!< height of surface to be created */
	PVRTuint32 dwWidth;					/*!< width of input surface */
	PVRTuint32 dwMipMapCount;			/*!< number of mip-map levels requested */
	PVRTuint32 dwpfFlags;				/*!< pixel format flags */
	PVRTuint32 dwTextureDataSize;		/*!< Total size in bytes */
	PVRTuint32 dwBitCount;				/*!< number of bits per pixel  */
	PVRTuint32 dwRBitMask;				/*!< mask for red bit */
	PVRTuint32 dwGBitMask;				/*!< mask for green bits */
	PVRTuint32 dwBBitMask;				/*!< mask for blue bits */
	PVRTuint32 dwAlphaBitMask;			/*!< mask for alpha channel */
	PVRTuint32 dwPVR;					/*!< magic number identifying pvr file */
	PVRTuint32 dwNumSurfs;				/*!< the number of surfaces present in the pvr */
};


/*****************************************************************************
 * ENUMS
 *****************************************************************************/

enum PVRPixelType
{
	OGL_RGBA_4444			= 0x10,
	OGL_RGBA_5551,
	OGL_RGBA_8888,
	OGL_RGB_565,
	OGL_RGB_555,
	OGL_RGB_888,
	OGL_I_8,
	OGL_AI_88,
	OGL_PVRTC2,
	OGL_PVRTC4
};


/*****************************************************************************/
/*****************************************************************************/
/*****************************************************************************/


@interface B3DTexturePVR ()
{
    @private
        BOOL				_compressed;
}

- (BOOL) readImageHeader;
- (BOOL) createOpenGLTexture2D;

@end


@implementation B3DTexturePVR

#pragma mark - Class Methods

+ (B3DTexturePVR*) textureNamed:(NSString*)name
{
	B3DTexturePVR* texture = [[B3DTexturePVR alloc] initWithTexture:name];
	return texture;
}

+ (NSString*) extension
{
	return B3DAssetTexturePVRDefaultExtension;
}


#pragma mark - Properties

@synthesize isCompressed        = _compressed;


#pragma mark - Con-/Destructor

- (id) initWithTexture:(NSString*)name
{
	self = [super initWithTexture:name ofType:B3DAssetTexturePVRDefaultExtension];
	if (self != nil)
	{
		_compressed	= NO;
	}
	
	return self;
}


#pragma mark - Asset handling

- (void) cleanUp
{
	_imageData = nil;
	
    if ([_stateManager deleteTexture:_openGlName])
    {
        LogDebug(@"[INFO] Texture %@ (#%u) deleted.", _name, _openGlName);
		_openGlName = 0;
    }
}

- (BOOL) loadContent
{
	if (_loaded)
	{
		return YES;
	}
	
	// Reset properties
	_openGlName     = 0;
	_width			= 0;
	_height			= 0;
	_hasAlpha		= NO;
	
	BOOL success	= NO;
	
	// Load raw image data
	_imageData = [[NSData alloc] initWithContentsOfFile:_path];
	
	if (_imageData)
	{
		if ([self readImageHeader])
		{
            success = [self createOpenGLTexture2D];
		}
	}
	
	_imageData = nil;
	
	_loaded = success;
	
	return success;
}

- (void) unloadContent
{
	if (!_loaded)
	{
		return;
	}
	
	[self cleanUp];
	_loaded = NO;
}


#pragma mark - Image data handling

- (BOOL) readImageHeader
{
	if (_imageData == nil)
	{
		return NO;
	}
	
	PVRTextureHeader* header = (PVRTextureHeader*) [_imageData bytes];
	_hasAlpha = (header->dwAlphaBitMask ? YES : NO);
	_bitsPerComponent = 0; // Not always required
	
	switch (header->dwpfFlags & PVRTEX_PIXELTYPE)
	{
		case OGL_RGB_565:
			_textureFormat = B3DTextureFormat_565;
			break;
			
		case OGL_RGBA_5551:
			_textureFormat = B3DTextureFormat_5551;
			break;
			
		case OGL_RGBA_4444:
			_textureFormat = B3DTextureFormat_RGBA;
			_bitsPerComponent = 4;
			break;
			
		case OGL_RGBA_8888:
			_textureFormat = B3DTextureFormat_RGBA;
			_bitsPerComponent = 8;
			break;
			
		case OGL_PVRTC2:    
			_textureFormat = (_hasAlpha ? B3DTextureFormat_PVRTC_RGBA2 : B3DTextureFormat_PVRTC_RGB2);
			break;
			
		case OGL_PVRTC4:
			_textureFormat = (_hasAlpha ? B3DTextureFormat_PVRTC_RGBA4 : B3DTextureFormat_PVRTC_RGB4);
			break;
			
		default:
			
			LogDebug(@"Loading PVR image data failed: unsupported format");
			return NO;
			
			break;
	}
	
	_width		= header->dwWidth;
	_height		= header->dwHeight;
	_mipCount	= header->dwMipMapCount;
	
	return YES;
}

- (BOOL) createOpenGLTexture2D
{
	// Get raw data for upload
	unsigned char* data = (unsigned char*)[self imageData];
	
	// Create local copies of properties
	int width			= _width;
	int height			= _height;
	GLuint texName		= 0;
	GLint lastTexName	= 0;
	
	// OpenGL error
	GLenum err;
	
	// Setup OpenGL state for texture upload
	{
		// Save last texture
		glGetIntegerv(GL_TEXTURE_BINDING_2D, &lastTexName);
		// Get new name
		glGenTextures(1, &texName);
		[_stateManager bindTexture:texName];
        
        // Texture state
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE); // GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE); // GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
	}
	
	// Read out previously gathered information of texture for upload
	_compressed = YES;
	int bitsPerPixel;
	GLenum format;
	
	// First test compressed PVR formats
    switch (_textureFormat)
	{
        case B3DTextureFormat_PVRTC_RGBA2:
            bitsPerPixel = 2;
            format = GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG;
            break;
			
        case B3DTextureFormat_PVRTC_RGB2:
            bitsPerPixel = 2;
            format = GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG;
            break;
			
        case B3DTextureFormat_PVRTC_RGBA4:
            bitsPerPixel = 4;
            format = GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG;
            break;
			
        case B3DTextureFormat_PVRTC_RGB4:
            bitsPerPixel = 4;
            format = GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG;
            break;
			
        default:
			// Uncompressed format used
            _compressed = NO;
            break;
    }
	
    if (_compressed)
	{
		// Upload any compressed image data for every mipmap level
        for (int level = 0; level <= _mipCount; ++level)
		{
            GLsizei size = std::max(32, width * height * bitsPerPixel / 8);
            glCompressedTexImage2D(GL_TEXTURE_2D, level, format, width, height, 0, size, data);
            data += size;
            width >>= 1; height >>= 1;
        }
    }
	else
	{
        GLenum type;
        switch (_textureFormat)
		{
            case B3DTextureFormat_RGBA:
				{
					if (_bitsPerComponent == 4) // RGBA4444
					{
						format = GL_RGBA;
						type = GL_UNSIGNED_SHORT_4_4_4_4;
						bitsPerPixel = 16;
					}
					else						// RGBA8888
					{
						format = GL_RGBA;
						type = GL_UNSIGNED_BYTE;
						bitsPerPixel = 32;	
					}
					
				}
                break;
				
            case B3DTextureFormat_565:
                format = GL_RGB;
                type = GL_UNSIGNED_SHORT_5_6_5;
                bitsPerPixel = 16;
                break;
				
            case B3DTextureFormat_5551:
                format = GL_RGBA;
                type = GL_UNSIGNED_SHORT_5_5_5_1;
                bitsPerPixel = 16;
                break;
                
            default:
                format = GL_RGBA;
                type = GL_UNSIGNED_BYTE;
                bitsPerPixel = 32;	
                break;
        }
		
		// Upload any uncompressed image data for every mipmap level
        for (int level = 0; level <= _mipCount; ++level)
		{
            glTexImage2D(GL_TEXTURE_2D, level, format, width, height, 0, format, type, data);
            GLsizei size = width * height * bitsPerPixel / 8;
            data += size;
            width >>= 1; height >>= 1;
        }
    }
	
	// Check for any errors
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		LogDebug(@"Error texture: %d (%@). glError: 0x%04X", texName, _name, err);
		
		return NO;
	}
	
	_openGlName = texName;
	
	// Reenable last texture
	[_stateManager bindTexture:lastTexName];
	
	LogDebug(@"Texture created with name: %u", _openGlName);
    
    return YES;
}

- (void*) imageData
{
	PVRTextureHeader* header = (PVRTextureHeader*) [_imageData bytes];
	char* data = (char*) [_imageData bytes];
	unsigned int headerSize = header->dwHeaderSize;
	
	return data + headerSize;
}


@end
