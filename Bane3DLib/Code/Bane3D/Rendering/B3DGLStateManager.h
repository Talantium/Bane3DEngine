//
//  B3DGLStateManager.h
//  Bane3D
//
//  Created by Andreas Hanft on 20.04.11.
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

@class EAGLContext;
@class B3DColor;


@interface B3DGLStateManager : NSObject

@property (nonatomic, weak, readonly)   EAGLContext*        currentContext;

+ (B3DGLStateManager*) sharedManager;

- (BOOL) setCurrentContext:(EAGLContext*)context;
- (void) setClearColor:(B3DColor*)color;

- (void) enableBlending;
- (void) disableBlending;

- (void) bindTexture:(GLuint)textureName;
- (BOOL) deleteTexture:(GLuint)textureName;
- (void) readTextureStateFromOpenGL;

- (void) useProgram:(GLuint)shaderProgramName;

// Vertex Buffer Handling
- (void) bindBuffer:(GLuint)bufferName;
- (void) bindIndexBuffer:(GLuint)bufferName;
- (void) clearBufferBindings;
- (BOOL) deleteBuffer:(GLuint)bufferName;
- (BOOL) deleteIndexBuffer:(GLuint)bufferName;

// Frame Buffer Handling
- (void) bindFrameBuffer:(GLuint)frameBuffer;
- (void) bindRenderBuffer:(GLuint)renderBuffer;

@end
