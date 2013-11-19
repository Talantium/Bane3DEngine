//
//  B3DShaderUnit.m
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

#import "B3DShaderUnit.h"

#import "B3DConstants.h"
#import "B3DAssert.h"
#import "NSString+Utils.h"
#import "B3DAsset+Protected.h"


@implementation B3DShaderUnit

#pragma mark - Class Methods

+ (id) shaderUnitNamed:(NSString*)name
{
	id shader = [[[self class] alloc] initWithResourceNamed:name ofType:[[self class] extension]];
	return shader;
}

+ (id) shaderUnitWithName:(NSString*)name andSource:(NSString*)source
{
    id shader = [[[self class] alloc] initWithName:name andSource:source];
	return shader;
}

+ (GLenum) shaderUnitType
{
    [B3DAssert that:(NO) errorMessage:@"You must override this in a concrete subclass!"];
    
    return 0;
}


#pragma mark - Con-/Destructor

- (id) initWithName:(NSString*)name andSource:(NSString*)source
{
	self = [super initWithVolatileResourceNamed:name];
	if (self != nil)
	{
		_source = [source copy];
	}
	
	return self;
}

- (void) dealloc
{    
    _source = nil;
	
}


#pragma mark - Asset handling

- (BOOL) loadContent
{
	if (_loaded)
	{
		return YES;
	}
    
    if (_source == nil)
    {
        if (_internalType == B3DAssetTypeVolatile)
        {
            LogDebug(@"Tried to load shader of type %@ with no shader source provided! You must set it in init!", _internalType);
            
            return NO;
        }
        else if (_internalType == B3DAssetTypeRemote)
        {
            // Quick and dirty synch remote loading of shader source
            _source = [NSString stringWithContentsOfURL:[NSURL URLWithString:_path]
                                                encoding:NSUTF8StringEncoding error:nil];
        }
        else
        {
            _source = [NSString stringWithContentsOfFile:_path encoding:NSUTF8StringEncoding error:nil];
        }
    }
    
    if ([_source isEmptyOrWhitespace])
    {
        LogDebug(@"Failed to load shader of type %@, no shader source available!", _internalType);
        
        return NO;
    }
    
    const GLchar* source = (GLchar*)[_source UTF8String];
	GLint status;
    
    GLenum shaderType = [[self class] shaderUnitType];
    _openGlName = glCreateShader(shaderType);
    glShaderSource(_openGlName, 1, &source, NULL);
    glCompileShader(_openGlName);
    
#if DEBUG
    GLint logLength;
    glGetShaderiv(_openGlName, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(_openGlName, logLength, &logLength, log);
        LogDebug(@"Shader unit compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(_openGlName, GL_COMPILE_STATUS, &status);
    if (status == 0)
    {
        glDeleteShader(_openGlName);
        
        return NO;
    }

	_loaded = YES;
	
	return YES;
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

- (void) cleanUp
{
	if (_openGlName != 0)
	{
        glDeleteShader(_openGlName);
        LogDebug(@"DELETED shader unit: %u", _openGlName);
        _openGlName = 0;
	}
}


@end
