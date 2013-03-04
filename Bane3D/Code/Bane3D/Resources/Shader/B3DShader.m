//
//  B3DShader.m
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

#import "B3DShader.h"

#import "B3DAsset.h"
#import "B3DAssert.h"
#import "B3DAssetToken.h"
#import "B3DShaderUnit.h"
#import "B3DShaderUnitVertex.h"
#import "B3DShaderUnitFragment.h"
#import "B3DShaderUniform.h"
#import "B3DConstants.h"
#import "B3DAsset+Protected.h"


@interface B3DShader ()
{
    @private
        NSMutableDictionary*                _attribsToBind;
        NSMutableDictionary*                _uniforms;
}

@property (nonatomic, strong, readwrite) B3DShaderUnit*         vertexShader;
@property (nonatomic, strong, readwrite) B3DShaderUnit*         fragmentShader;
@property (nonatomic, strong, readwrite) NSMutableDictionary*   attribsToBind;
@property (nonatomic, strong, readwrite) NSMutableDictionary*   uniforms;

- (BOOL) loadShaders;
- (BOOL) link;
- (BOOL) validate;
- (void) applyUniformValues;

@end


@implementation B3DShader

@synthesize vertexShader        = _vertexShader;
@synthesize fragmentShader      = _fragmentShader;
@synthesize attribsToBind       = _attribsToBind;
@synthesize uniforms            = _uniforms;


#pragma mark - Class Methods

+ (B3DShader*) shader
{
    return [[[self class] alloc] init];
}

+ (id) shaderNamed:(NSString*)name
{
    return [[[self class] alloc] initWithName:name];
}

+ (B3DAssetToken*) tokenWithName:(NSString*)name
{
    B3DAssetToken* token = [[B3DAssetToken alloc] init];
    token.uniqueIdentifier = [B3DAssetToken uniqueIdForAsset:name
                                               withExtension:[[self class] extension]
                                                      ofType:B3DAssetTypeVolatile];

    return token;
}

+ (NSString*) extension
{
	return @"shader";
}

#pragma mark - Con-/Destructor

- (id) initWithName:(NSString*)name
{
    return [self initWithName:name
                 vertexShader:[B3DShaderUnitVertex shaderUnitNamed:name]
               fragmentShader:[B3DShaderUnitFragment shaderUnitNamed:name]];
}

- (id) initWithName:(NSString*)name vertexShaderSource:(NSString*)vertexSource fragmentShaderSource:(NSString*)fragmentSource
{
    return [self initWithName:name
                 vertexShader:[B3DShaderUnitVertex shaderUnitWithName:name andSource:vertexSource]
               fragmentShader:[B3DShaderUnitFragment shaderUnitWithName:name andSource:fragmentSource]];
}

// Designated initialiser
- (id) initWithName:(NSString*)name
       vertexShader:(B3DShaderUnitVertex*)vertexShader
     fragmentShader:(B3DShaderUnitFragment*)fragmentShader
{
	self = [super initWithVolatileResourceNamed:name];
	if (self != nil)
	{
		self.vertexShader           = vertexShader;
		self.fragmentShader         = fragmentShader;
        
        self.attribsToBind          = [NSMutableDictionary dictionary];
        {
            // Register default attributes for binding

        }
        
        self.uniforms               = [NSMutableDictionary dictionary];
        {
            // Register default uniforms

        }
	}

	return self;
}

- (void) dealloc
{
    _vertexShader = nil;
    _fragmentShader = nil;
    _attribsToBind = nil;
    _uniforms = nil;
    
}

- (void) cleanUp
{
    [_vertexShader unloadContent];
    [_fragmentShader unloadContent];
    
    for (B3DShaderUniform* uniform in [_uniforms allValues])
    {
        [uniform cleanUp];
    }

    if (_openGlName)
    {
        glDeleteProgram(_openGlName);
        _openGlName = 0;
    }
}


- (BOOL) loadContent
{
	if (_loaded)
	{
		return YES;
	}
    
    BOOL success        = NO;
    
    success = [self loadShaders];

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


#pragma mark - Shader Management

- (BOOL) loadShaders
{
    // Create shader program.
    _openGlName = glCreateProgram();
    
    // Create and compile vertex shader.
    if ([_vertexShader loadContent] == NO)
    {
        LogDebug(@"Failed to load and compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    if ([_fragmentShader loadContent] == NO)
    {
        LogDebug(@"Failed to load and compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_openGlName, _vertexShader.openGlName);
    
    // Attach fragment shader to program.
    glAttachShader(_openGlName, _fragmentShader.openGlName);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    GLuint index;
    NSString* attribute;
    for (NSNumber* attributeIndex in [[_attribsToBind allKeys] sortedArrayUsingSelector:@selector(compare:)])
    {
        index = [attributeIndex unsignedIntValue];
        attribute = [_attribsToBind objectForKey:attributeIndex];
        LogDebug(@"Attaching attribute %@ to index %u", attribute, index);
        
        glBindAttribLocation(_openGlName, index, [attribute UTF8String]);
    }

    // Link program.
    if (![self link])
    {
        LogDebug(@"Failed to link program: %d", _openGlName);
        
        [self cleanUp];
        
        return NO;
    }
    
    // Get uniform locations
    for (B3DShaderUniform* uniform in [_uniforms allValues])
    {
        [uniform bindToShader:_openGlName];
    }
    
    // Release vertex and fragment shaders, as they are now saved in the program
    [_vertexShader cleanUp];
    [_fragmentShader cleanUp];

    return YES;
}

- (BOOL) link
{
    GLint status;
    
    glLinkProgram(_openGlName);
    
#if DEBUG
    GLint logLength;
    glGetProgramiv(_openGlName, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar* log = (GLchar*)malloc(logLength);
        glGetProgramInfoLog(_openGlName, logLength, &logLength, log);
        LogDebug(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(_openGlName, GL_LINK_STATUS, &status);
    if (status == 0)
        return NO;
    
    return YES;
}

- (BOOL) validate
{
    GLint logLength, status;
    
    glValidateProgram(_openGlName);
    glGetProgramiv(_openGlName, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar* log = (GLchar*)malloc(logLength);
        glGetProgramInfoLog(_openGlName, logLength, &logLength, log);
        LogDebug(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(_openGlName, GL_VALIDATE_STATUS, &status);
    if (status == 0)
        return NO;
    
    return YES;
}

- (void) enable
{
    [super enable];
    
    [_stateManager useProgram:_openGlName];
    
    [self applyUniformValues];
}

- (void) bindAttributeNamed:(NSString*)attribute toIndex:(uint)index
{
    if ([_attribsToBind count] < B3DShaderMaxAttribs)
    {
        [_attribsToBind setObject:attribute
                           forKey:[NSNumber numberWithUnsignedInt:index]];
    }
    else
    {
        LogDebug(@"Warning: maximum number of attribs reached! New attrib named '%@' not added", attribute);
    }
}

- (BOOL) addUniformNamed:(NSString*)uniform
{
    if (_loaded)
    {
        NSAssert(NO, @"Cannot add uniform after shader has been compiled!");
    }
    
    if ([self uniformNamed:uniform] == nil && [_uniforms count] < B3DShaderMaxUniforms)
    {
        [_uniforms setObject:[B3DShaderUniform uniformNamed:uniform] forKey:uniform];
        
        return YES;
    }
    else
    {
        LogDebug(@"Warning: maximum number of uniforms reached! New uniform named '%@' not added", uniform);
        
        return NO;
    }
}

- (void) applyUniformValues
{
    for (B3DShaderUniform* uniform in [_uniforms allValues])
    {
        [uniform applyValue];
    }
}

- (B3DShaderUniform*) uniformNamed:(NSString*)name
{
    return [_uniforms objectForKey:name];
}

- (void) setIntValue:(GLint)value forUniformNamed:(NSString*)uniform
{
    [[self uniformNamed:uniform] setIntValue:value];
}

- (void) setFloatValue:(GLfloat)value forUniformNamed:(NSString*)uniform
{
    [[self uniformNamed:uniform] setFloatValue:value];
}

- (void) setMatrix3Value:(GLKMatrix3)value forUniformNamed:(NSString*)uniform
{
    [[self uniformNamed:uniform] setMatrix3Value:value];
}

- (void) setMatrix4Value:(GLKMatrix4)value forUniformNamed:(NSString*)uniform
{
    [[self uniformNamed:uniform] setMatrix4Value:value];
}

- (void) setVector2Value:(GLKVector2)value forUniformNamed:(NSString*)uniform
{
    [[self uniformNamed:uniform] setVector2Value:value];
}

- (void) setVector3Value:(GLKVector3)value forUniformNamed:(NSString*)uniform
{
    [[self uniformNamed:uniform] setVector3Value:value];
}

- (void) setVector4Value:(GLKVector4)value forUniformNamed:(NSString*)uniform
{
    [[self uniformNamed:uniform] setVector4Value:value];
}

- (void) setColorValue:(B3DColor*)value forUniformNamed:(NSString*)uniform
{
    [[self uniformNamed:uniform] setColorValue:value];
}


#pragma mark - Copying

- (id) copyWithZone:(NSZone*)zone
{
    B3DShader* copy = [super copyWithZone:zone];
    
    copy.vertexShader       = _vertexShader;
    copy.fragmentShader     = _fragmentShader;
    copy.attribsToBind      = _attribsToBind;
    copy.uniforms           = [[NSMutableDictionary alloc] initWithDictionary:_uniforms copyItems:YES];
    
    return copy;
}

- (NSString*) description
{
    return [NSString stringWithFormat:@"%@ (%@, %@), %@", _name, _vertexShader, _fragmentShader, [super description]];
}


@end
