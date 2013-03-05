//
//  B3DFrameBuffer.h
//  Bane3D
//
//  Created by Andreas Hanft on 09.12.11.
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
