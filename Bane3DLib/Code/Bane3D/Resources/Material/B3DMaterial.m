//
//  B3DMaterial.m
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

#import "B3DMaterial.h"

#import "NSString+MD5.h"
#import "B3DColor.h"
#import "B3DTexture.h"
#import "B3DShader.h"
#import "B3DAsset+Protected.h"
#import "B3DConstants.h"


@interface B3DMaterial ()
{
    @private
        uint                    _renderID;
        B3DTexture*				_texture;
        B3DShader*              _shader;
        
        B3DColor*               _baseColor;
        B3DColor*               _ambientColor;
        B3DColor*               _diffuseColor;
}

- (uint) generateUniqueRenderID;

@end


@implementation B3DMaterial

#pragma mark - Class Methods

+ (B3DMaterial*) materialNamed:(NSString*)name
{
  	B3DMaterial* material = [[[self class] alloc] initWithVolatileResourceNamed:name];
	return material;  
}


#pragma mark - Con-/Destructor

- (id) initWithResource:(NSString*)resource ofType:(NSString*)type
{
    self = [super initWithResource:resource ofType:type];
    if (self) 
    {
        self.baseColor      = [B3DColor whiteColor];
        self.ambientColor   = [B3DColor whiteColor];
        self.diffuseColor   = [B3DColor whiteColor];
    }
    
    return self;
}


#pragma mark - Asset handling

- (BOOL) loadContent
{
	if (_loaded)
	{
		return YES;
	}
    
    BOOL success = NO;
    
    if (_texture != nil)
    {
        success = [_texture loadContent];
        if (success == NO) return NO;
    }
    
    success = [_shader loadContent];
    if (success == NO) return NO;

	_loaded = success;

	return _loaded;
}

- (void) unloadContent
{
	if (!_loaded)
	{
		return;
	}
	
    [_texture unloadContent];
    [_shader unloadContent];
    
	_loaded = NO;
}

- (void) updateRenderID
{
    _renderID = [self generateUniqueRenderID];
}

- (uint) generateUniqueRenderID
{
    // @TODO: At some point, check if this call might cause performance problems
    // if executed too often!
    
    NSString* names = [[NSString stringWithFormat:@"%@%@%@", _name, _texture.name, _shader.name] md5];

    uint result = 0;
    NSUInteger weight = names.length;
    for (int i = 0; i < names.length; i++)
    {
        unichar number = [names characterAtIndex:i];
        result += number * (weight - i);
    }

    return result;
}


#pragma mark - Properties

- (void) setTexture:(B3DTexture*)texture
{
    if (_texture != texture)
    {
        _texture = texture;
        
        [self updateRenderID];
    }
}

- (void) setShader:(B3DShader*)shader
{
    if (_shader != shader)
    {
        _shader = [shader copy];
        
        [self updateRenderID];
    }
}

- (void) enable
{
    [super enable];
    
    if (_texture)
    {
        [_texture enable];
    }
    else
    {
        [_stateManager bindTexture:0];
    }
    
    [_shader setColorValue:_baseColor forUniformNamed:B3DShaderUniformColorBase];
    [_shader setColorValue:_ambientColor forUniformNamed:B3DShaderUniformColorAmbient];
    [_shader setColorValue:_diffuseColor forUniformNamed:B3DShaderUniformColorDiffuse];
    [_shader enable];
}

- (void) disable
{
    [_shader disable];
    [_texture disable];
    
    [super disable];
}


#pragma mark - Copying

- (id) copyWithZone:(NSZone*)zone
{
    B3DMaterial* copy = [super copyWithZone:zone];
    
    copy.renderID           = _renderID;
    copy.texture            = _texture;
    copy.shader             = _shader; // Copied
    copy.baseColor          = [_baseColor copy];
    copy.ambientColor       = [_ambientColor copy];
    copy.diffuseColor       = [_diffuseColor copy];
    
    return copy;
}

@end
