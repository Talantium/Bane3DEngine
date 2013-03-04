//
//  B3DShaderUniform.m
//  Bane3D
//
//  Created by Andreas Hanft on 16.08.12.
//  Copyright (c) 2012 talantium.net. All rights reserved.
//

#import "B3DShaderUniform.h"

#import "B3DColor.h"


typedef enum
{
    B3DShaderUniformTypeUnknown,
    B3DShaderUniformTypeInt,
    B3DShaderUniformTypeFloat,
    B3DShaderUniformTypeMatrix3x3,
    B3DShaderUniformTypeMatrix4x4,
    B3DShaderUniformTypeVector2,
    B3DShaderUniformTypeVector3,
    B3DShaderUniformTypeVector4
}
B3DShaderUniformType;


@interface B3DShaderUniform ()
{
    @private
        B3DShaderUniformType            _type;
    
        GLint                           _intValue;
        GLfloat                         _floatValue;
        GLKMatrix3                      _matrix3Value;
        GLKMatrix4                      _matrix4Value;
        GLKVector2                      _vector2Value;
        GLKVector3                      _vector3Value;
        GLKVector4                      _vector4Value;
}

@property (nonatomic, readwrite, copy)     NSString*            name;
@property (nonatomic, readwrite, assign)   GLint                location;

@end


@implementation B3DShaderUniform

@synthesize name        = _name;
@synthesize location    = _location;

+ (B3DShaderUniform*) uniformNamed:(NSString*)name
{
    B3DShaderUniform* uniform = [[B3DShaderUniform alloc] init];
    uniform.name = name;
    
    return uniform;
}


- (void) bindToShader:(GLuint)name
{
    _location = glGetUniformLocation(name, [_name UTF8String]);

#if DEBUG
    if (_location >= 0)
    {
        LogDebug(@"Attaching uniform %@ with index %i", _name, _location);
    }
    else
    {
        LogDebug(@"Could not attach uniform %@ (invalid location %i)", _name, _location);
    }
#endif
}

- (void) applyValue
{
    if (_location >= 0)
    {
        switch (_type)
        {
            case B3DShaderUniformTypeInt:
                glUniform1i(_location, _intValue);
                break;
                
            case B3DShaderUniformTypeFloat:
                glUniform1f(_location, _floatValue);
                break;
                
            case B3DShaderUniformTypeMatrix3x3:
                glUniformMatrix3fv(_location, 1, GL_FALSE, _matrix3Value.m);
                break;
                
            case B3DShaderUniformTypeMatrix4x4:
                glUniformMatrix4fv(_location, 1, GL_FALSE, _matrix4Value.m);
                break;
                
            case B3DShaderUniformTypeVector2:
                glUniform2fv(_location, 1, _vector2Value.v);
                break;
                
            case B3DShaderUniformTypeVector3:
                glUniform3fv(_location, 1, _vector3Value.v);
                break;
                
            case B3DShaderUniformTypeVector4:
                glUniform4fv(_location, 1, _vector4Value.v);
                break;
                
            default:
                break;
        }
    }
}

- (void) cleanUp
{
    _location = 0;
    _type = B3DShaderUniformTypeUnknown;
}


- (void) setIntValue:(GLint)value
{
    _intValue = value;
    _type = B3DShaderUniformTypeInt;
}

- (void) setFloatValue:(GLfloat)value
{
    _floatValue = value;
    _type = B3DShaderUniformTypeFloat;
}

- (void) setMatrix3Value:(GLKMatrix3)value
{
    _matrix3Value = value;
    _type = B3DShaderUniformTypeMatrix3x3;
}

- (void) setMatrix4Value:(GLKMatrix4)value
{
    _matrix4Value = value;
    _type = B3DShaderUniformTypeMatrix4x4;
}

- (void) setVector2Value:(GLKVector2)value
{
    _vector2Value = value;
    _type = B3DShaderUniformTypeVector2;
}

- (void) setVector3Value:(GLKVector3)value
{
    _vector3Value = value;
    _type = B3DShaderUniformTypeVector3;
}

- (void) setVector4Value:(GLKVector4)value
{
    _vector4Value = value;
    _type = B3DShaderUniformTypeVector4;
}

- (void) setColorValue:(B3DColor*)value;
{
    [self setVector4Value:GLKVector4Make(value.r, value.g, value.b, value.a)];
}


#pragma mark - Copying

- (id) copyWithZone:(NSZone*)zone
{
    B3DShaderUniform* copy = [[[self class] allocWithZone:zone] init];
    
    copy.name       = _name;
    copy.location   = _location;
    
    return copy;
}

@end
