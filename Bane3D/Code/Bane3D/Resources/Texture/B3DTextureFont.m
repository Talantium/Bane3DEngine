//
//  B3DTextureFont.m
//  Bane3D
//
//  Created by Andreas Hanft on 14.01.13.
//  Copyright (c) 2013 talantium.net. All rights reserved.
//

#import "B3DTextureFont.h"

#import "B3DAssetToken.h"
#import "B3DMathHelper.h"
#import "B3DAsset+Protected.h"
#import "B3DTexture_Protected.h"


const       float   B3DTextureFontGlyphPadding      = 2.0f;
NSString*   const   B3DTextureFontDefaultCharSet    = @" !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~¢£¥¦§¨©«¬­®¯°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþ";


@interface B3DTextureFont ()

@property (nonatomic, strong, readwrite) NSMutableDictionary*       charDict;
@property (nonatomic, strong, readwrite) UIFont*                    font;

+ (NSString*) fontIdentifierForFont:(UIFont*)font;

@end


@implementation B3DTextureFont


#pragma mark - Class Methods

+ (B3DTextureFont*) defaultFontTexture
{
    return [B3DTextureFont textureWithFont:[UIFont systemFontOfSize:B3DLabelDefaultFontSize]];
}

+ (NSString*) fontIdentifierForFont:(UIFont*)font
{
    return [NSString stringWithFormat:@"%@%@%f", font.fontName, font.familyName, font.pointSize];
}

+ (B3DAssetToken*) tokenForFont:(UIFont*)font
{
    B3DAssetToken* token = [[B3DAssetToken alloc] init];
    token.uniqueIdentifier = [B3DAssetToken uniqueIdForAsset:[B3DTextureFont fontIdentifierForFont:font]
                                               withExtension:[[self class] extension]
                                                      ofType:B3DAssetTypeVolatile];
    
    return token;
}

+ (B3DTextureFont*) textureWithFont:(UIFont*)font
{
	B3DTextureFont* texture = [[B3DTextureFont alloc] initWithFont:font];
	return texture;
}

+ (B3DTextureFont*) textureWithFontNamed:(NSString*)name size:(CGFloat)size
{
    return [B3DTextureFont textureWithFont:[UIFont fontWithName:name size:size]];
}


#pragma mark - Con-/Destructor

- (id) initWithFont:(UIFont*)font
{
    NSString* fontIdentifier = [B3DTextureFont fontIdentifierForFont:font];
	self = [super initWithTexture:fontIdentifier ofType:B3DAssetTypeVolatile];
	if (self != nil)
	{
        self.font       = font;
        _charDict       = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}


#pragma mark - Asset handling

- (void) cleanUp
{
	_imageData = nil;
    [_charDict removeAllObjects];
	
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
	_openGlName         = 0;
	_width              = 0;
	_height             = 0;
	_hasAlpha           = NO;
	
	BOOL success        = NO;
    
    // Get the chars for rendering and put them in an array buffer to access them individually
    NSString* charSet = self.charSet;
    unsigned int charSetLength = charSet.length;
    unichar buffer[charSetLength + 1];
    [charSet getCharacters:buffer range:NSMakeRange(0, charSetLength)];
    
    // First get the size of all chars so we can calculate required size of texture
    double totalSize = 0;
    // Array for the single char strings to iterate throu later
    NSMutableArray* charsAsStrings = [[NSMutableArray alloc] initWithCapacity:charSetLength];

    // First step: get size info for every char and save to a B3DTextureFontCharMapInfo
    NSString* currentCharAsString = nil;
    B3DTextureFontCharMapInfo info;
    for (int i = 0; i < charSetLength; ++i)
    {
        info.index = i;
        info.singleChar = buffer[i];
        
        currentCharAsString = [[NSString alloc] initWithCharacters:&info.singleChar length:1];
        [charsAsStrings addObject:currentCharAsString];
        
        info.size = [currentCharAsString sizeWithFont:_font];
        [_charDict setObject:[NSValue value:&info withObjCType:@encode(B3DTextureFontCharMapInfo)] forKey:currentCharAsString];
        
        totalSize += ((info.size.width + B3DTextureFontGlyphPadding) * info.size.height);
    }

    // Calculate optimum size and round up to next power of two
    double bestWidth = nextPowerOfTwo(sqrt(totalSize));
    double bestHeight = bestWidth; // Use a square area, gets cropped later after all chars have been drawn
    
    // Create Canvas, considering retina
    GLfloat scaleFactor = [[UIScreen mainScreen] scale];
    int maxWidth        = bestWidth;
    int maxHeight       = bestHeight;
    int maxWidthScaled  = maxWidth * scaleFactor;
    int maxHeightScaled = maxHeight * scaleFactor;
    
    const int bitsPerElement = 8;
    int sizeInBytes     = maxWidthScaled *  maxHeightScaled;
    int texturePitch    = maxWidthScaled;
    void* data          = malloc(sizeInBytes);
    memset(data, 0x00, sizeInBytes);
    
    // See "CGBitmapContextCreate Supported Color Spaces" http://developer.apple.com/library/mac/#qa/qa1037/_index.html
    CGColorSpaceRef colorSpace = NULL;//CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(data,
                                                 maxWidthScaled,
                                                 maxHeightScaled,
                                                 bitsPerElement,
                                                 texturePitch,
                                                 colorSpace,
                                                 kCGImageAlphaOnly);
    
    // Apply scale factor (for retina screens) and flip context vertically
    CGContextScaleCTM(context, scaleFactor, scaleFactor);
    CGContextTranslateCTM(context, 0.0f, maxHeight);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    
    UIGraphicsPushContext(context);
    {
        // Second step: Draw chars on full size canvas and save pos to the B3DTextureFontCharMapInfo
        CGPoint currentPos  = CGPointZero;
        B3DTextureFontCharMapInfo info;
        for (NSString* charAsString in charsAsStrings)
        {
            [[_charDict objectForKey:charAsString] getValue:&info];
            
            info.position = currentPos;
            
            currentPos.x += info.size.width + B3DTextureFontGlyphPadding;
            if (currentPos.x >= maxWidth)
            {
                currentPos.x = 0;
                currentPos.y += info.size.height;
            }
            
            if (info.position.x + info.size.width > maxWidth)
            {
                info.position = currentPos;
                currentPos.x += info.size.width + B3DTextureFontGlyphPadding;
            }
            
            [charAsString drawAtPoint:info.position withFont:_font];
            
            [_charDict setObject:[NSValue value:&info withObjCType:@encode(B3DTextureFontCharMapInfo)] forKey:charAsString];
        }
        
        // Get the height used from the last char so we know how much space has
        // been used and how much we can crop
        maxHeight = info.position.y + info.size.height + B3DTextureFontGlyphPadding;
        maxHeightScaled = maxHeight * scaleFactor;
    }
    UIGraphicsPopContext();
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);

    
    // Third step: Calculate UV coords based on cropped texture
    for (NSString* charAsString in charsAsStrings)
    {
        [[_charDict objectForKey:charAsString] getValue:&info];
        
        info.textCoords[0] = CGPointMake(info.position.x / (float)maxWidth,
                                         ((info.position.y + info.size.height) / (float)maxHeight));
        info.textCoords[1] = CGPointMake((info.position.x + info.size.width) / (float)maxWidth,
                                         ((info.position.y + info.size.height) / (float)maxHeight));
        info.textCoords[2] = CGPointMake(info.position.x / (float)maxWidth,
                                         (info.position.y / (float)maxHeight));
        info.textCoords[3] = CGPointMake((info.position.x + info.size.width) / (float)maxWidth,
                                         (info.position.y / (float)maxHeight));
        
        [_charDict setObject:[NSValue value:&info withObjCType:@encode(B3DTextureFontCharMapInfo)] forKey:charAsString];
    }
    
    
    GLuint  textureName		= 0;
	GLint   lastTextureName	= 0;
    
	// Setup OpenGL state for NPOT texture upload
	{
		// Save last texture
		glGetIntegerv(GL_TEXTURE_BINDING_2D, &lastTextureName);
		// Get new name
		glGenTextures(1, &textureName);
		[_stateManager bindTexture:textureName];
        
        // Texture state
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
	}
    
    // Upload texture
    {
        glTexImage2D(GL_TEXTURE_2D, 0, GL_ALPHA, maxWidthScaled, maxHeightScaled, 0, GL_ALPHA, GL_UNSIGNED_BYTE, data);
        
        free(data);

        // Check for any OpenGL errors
        GLenum err = glGetError();
        if (err != GL_NO_ERROR)
        {
            LogDebug(@"Error uploading font texture: %d (%@). glError: 0x%04X", textureName, _name, err);
            
            return NO;
        }
        else
        {
            success         = YES;
            _openGlName     = textureName;
            _width			= maxWidthScaled;
            _height			= maxHeightScaled;
            _hasAlpha       = YES;
        }
    }
    	
	// Reenable last texture
	[_stateManager bindTexture:lastTextureName];
    
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


#pragma mark - Properties

- (NSString*) charSet
{
    if (_charSet == nil)
    {
        return B3DTextureFontDefaultCharSet;
    }
    
    return _charSet;
}


@end
