//
//  B3DFrameBuffer.h
//  Bane3D
//
//  Created by Andreas Hanft on 08.01.13.
//  Copyright (c) 2013 talantium.net. All rights reserved.
//

#import <OpenGLES/EAGLDrawable.h>


@interface B3DFrameBuffer : NSObject

@property (nonatomic, readwrite, assign)    BOOL        depthBufferEnabled;     //!< Default: YES
@property (nonatomic, readwrite, assign)    BOOL        stencilBufferEnabled;   //!< Default: NO

// The OpenGL ES names for the frame-, render-, depth- and stencilbuffer
@property (nonatomic, readonly,  assign)    GLuint      framebuffer;
@property (nonatomic, readonly,  assign)    GLuint      colorRenderbuffer;
@property (nonatomic, readonly,  assign)    GLuint      depthRenderbuffer;
@property (nonatomic, readonly,  assign)    GLuint      stencilRenderbuffer;

// Discard unused buffer components as a performance hint to OpenGL
- (void) discard;

- (CGSize) createFrameBufferFromDrawable:(id<EAGLDrawable>)drawable inContext:(EAGLContext*)context;
- (void) destroy;

@end
