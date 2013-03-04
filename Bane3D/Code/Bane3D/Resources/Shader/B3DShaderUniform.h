//
//  B3DShaderUniform.h
//  Bane3D
//
//  Created by Andreas Hanft on 16.08.12.
//  Copyright (c) 2012 talantium.net. All rights reserved.
//

#import <GLKit/GLKit.h>
@class B3DColor;


@interface B3DShaderUniform : NSObject <NSCopying>

@property (nonatomic, readonly, copy)     NSString*         name;
@property (nonatomic, readonly, assign)   GLint             location;

+ (B3DShaderUniform*) uniformNamed:(NSString*)name;

- (void) bindToShader:(GLuint)name;
- (void) applyValue;
- (void) cleanUp;

- (void) setIntValue:(GLint)value;
- (void) setFloatValue:(GLfloat)value;
- (void) setMatrix3Value:(GLKMatrix3)value;
- (void) setMatrix4Value:(GLKMatrix4)value;
- (void) setVector2Value:(GLKVector2)value;
- (void) setVector3Value:(GLKVector3)value;
- (void) setVector4Value:(GLKVector4)value;
- (void) setColorValue:(B3DColor*)value;

@end
