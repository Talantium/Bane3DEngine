//
//  B3DTexturePNG.m
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

#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

#import "B3DTexturePNG.h"

#import "B3DMathHelper.h"
#import "B3DAsset+Protected.h"
#import "B3DTexture_Protected.h"


@interface B3DTexturePNG ()
{
    @private
        GLfloat             _scale;
}

- (BOOL) readImageHeader:(CGImageRef)cgImage;
- (BOOL) createOpenGLTexture2D;

@end


@implementation B3DTexturePNG

#pragma mark - Class Methods

+ (B3DTexturePNG*) textureNamed:(NSString*)name
{
	B3DTexturePNG* texture = [[B3DTexturePNG alloc] initWithTexture:name];
	return texture;
}

+ (NSString*) extension
{
	return B3DAssetTexturePNGDefaultExtension;
}


#pragma mark - Properties

@synthesize originalWidth			= _originalWidth;
@synthesize originalHeight			= _originalHeight;


#pragma mark - Con-/Destructor

- (id) initWithTexture:(NSString*)name
{
	self = [super initWithTexture:name ofType:B3DAssetTexturePNGDefaultExtension];
	if (self != nil)
	{
		_originalWidth			= 0;
		_originalHeight			= 0;
		_scale                  = 1.0f;
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
	_originalWidth	= 0;
	_originalHeight	= 0;
	_hasAlpha		= NO;
	
	BOOL success	= NO;
	
	// Load raw image data
	UIImage* uiImage = [[UIImage alloc] initWithContentsOfFile:_path];
	CGImageRef cgImage = uiImage.CGImage;
    _scale = uiImage.scale;
	
	CFDataRef dataRef = CGDataProviderCopyData(CGImageGetDataProvider(cgImage));
	_imageData = [[NSData alloc] initWithData:(__bridge NSData*)dataRef];
	CFRelease(dataRef);
	
	if (_imageData)
	{
		if ([self readImageHeader:cgImage])
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

- (BOOL) readImageHeader:(CGImageRef)cgImage
{
	if (cgImage == nil)
	{
		return NO;
	}
	
    // Get information about alpha usage in the PNG. It seems we have to 
    // distinguish between the actual use of alpha in the image and the 
    // presence of the alpha component in the bytes of the image data!? Otherwise
    // there might be render errors with some tetures. Not 100% sure about that one...
    CGImageAlphaInfo info = CGImageGetAlphaInfo(cgImage); 
	_hasAlpha = !(info == kCGImageAlphaNone || info == kCGImageAlphaNoneSkipFirst || info == kCGImageAlphaNoneSkipLast);
    BOOL hasAlphaComponent = (info != kCGImageAlphaNone);
	
	CGColorSpaceRef colorSpace = CGImageGetColorSpace(cgImage);
	switch (CGColorSpaceGetModel(colorSpace))
	{
		case kCGColorSpaceModelMonochrome:
			_textureFormat = (hasAlphaComponent ? B3DTextureFormat_GrayAlpha : B3DTextureFormat_Gray);
			break;
			
		case kCGColorSpaceModelRGB:
			_textureFormat = (hasAlphaComponent ? B3DTextureFormat_RGBA : B3DTextureFormat_RGB);
			break;
			
		default:
			
			LogDebug(@"Loading PNG image data failed: unsupported format");
			return NO;
			
			break;
	}

	_width				= CGImageGetWidth(cgImage);
	_height				= CGImageGetHeight(cgImage);
	_originalWidth		= _width / _scale;
	_originalHeight		= _height / _scale;
    
	_mipCount			= 0; // PNGs do not support mipmaps
	_bitsPerComponent	= CGImageGetBitsPerComponent(cgImage);
	
	return YES;
}

- (BOOL) createOpenGLTexture2D
{
	// Get raw data for upload
	void* data = [self imageData];
	
	// Create local copies of properties
	int width			= _width;
	int height			= _height;
	GLuint texName		= 0;
	GLint lastTexName	= 0;
	
	// OpenGL error
	GLenum err;
	
	// Get correct format for upload
    GLenum format;
    switch (_textureFormat)
	{
        case B3DTextureFormat_Gray:
			format = GL_LUMINANCE;
			break;
			
        case B3DTextureFormat_GrayAlpha:
			format = GL_LUMINANCE_ALPHA;
			break;
			
        case B3DTextureFormat_RGB:
			format = GL_RGB;
			break;
			
        case B3DTextureFormat_RGBA:
			format = GL_RGBA;
			break;
            
        default:
			format = GL_RGBA;
			break;
    }
    
	// Get image type
    GLenum type;
    switch (_bitsPerComponent)
	{
        case 8:
			type = GL_UNSIGNED_BYTE;
			break;
			
        case 4:
            if (format == GL_RGBA)
			{
                type = GL_UNSIGNED_SHORT_4_4_4_4;
                break;
            }
            // intentionally fall through
			
		default:
			
			LogDebug(@"Loading PNG image data failed: unsupported format");
			return NO;
			
			break;
    }
	
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
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR); //GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR); //GL_NEAREST);
        glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
	}
	
    /*
     NPOT textures are supported on PowerVR SGX hardware, but have restrictions.
     NPOT textures cannot use mipmaps, must be 2D (no cube-maps or 3D textures) 
     and must use the GL_CLAMP_TO_EDGE for texture wrapping in both dimensions;
     this is supported by default in OpenGL ES 2.0 and under ES 1.1 by the
     extension GL_APPLE_texture_2D_limited_npot
     */
    
	// Check if current implementation supports non power of two textures,
	// in case image file is nPOT we otherwise have to increase dimensions.
    BOOL nonPowerOfTwoTextureSupport = YES;
    /*
	const char* extensions = (char*)glGetString(GL_EXTENSIONS);
	BOOL nonPowerOfTwoTextureSupport = (std::strstr(extensions, "GL_APPLE_texture_2D_limited_npot") != 0);
	*/
	if (nonPowerOfTwoTextureSupport == NO)
	{
		width		= nextPowerOfTwo(_originalWidth);
		height		= nextPowerOfTwo(_originalHeight);
	}
    
	// Upload texture
    
    /*
     glTexImage2D loads the texture data into the texture object.
     void glTexImage2D( GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height,
     GLint border, GLenum format, GLenum type, const GLvoid *pixels );
     target must be GL_TEXTURE_2D.
     level specify the mipmap level we want to upload.
     internalformat and format must be the same. Here we use GL_RGBA for 4 component colors (r,g,b,a).
     We could use GL_RGB, GL_ALPHA, GL_LUMINANCE, GL_LUMINANCE_ALPHA to use different color component combinations.
     width, height specify the size of the texture. Both of the dimensions must be power of 2.
     border must be 0.
     type specify the format of the data. We use GL_UNSIGNED_BYTE to describe a color component as an unsigned byte.
     So a pixel is described by a 32bits integer.
     We could also use GL_UNSIGNED_SHORT_5_6_5, GL_UNSIGNED_SHORT_4_4_4_4, and GL_UNSIGNED_SHORT_5_5_5_1
     to specify the size of all 3 (or 4) color components. If we used any of these 3 constants,
     a pixel would then be described by a 16bits integer.
     */

	glTexImage2D(GL_TEXTURE_2D, _mipCount, format, width, height, 0, format, type, data);
	
	// Check for any errors
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		LogDebug(@"Error uploading PNG texture: %d (%@). glError: 0x%04X", texName, _name, err);
		
		return NO;
	}
	
	_openGlName     = texName;
	_width			= width / _scale;
	_height			= height / _scale;
	
	// Reenable last texture
	[_stateManager bindTexture:lastTexName];
	
	LogDebug(@"Texture created from PNG with name: %u", _openGlName);

    return YES;
}

- (void*) imageData
{
	return (void*)[_imageData bytes];
}


@end