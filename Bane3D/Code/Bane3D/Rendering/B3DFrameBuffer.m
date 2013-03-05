//
//  B3DFrameBuffer.m
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

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <CoreGraphics/CoreGraphics.h>

#import "B3DFrameBuffer.h"


@implementation B3DFrameBuffer

- (id) init
{
    self = [super init];
    if (self)
    {
        // Default settings
        _depthBufferEnabled         = YES;
        _stencilBufferEnabled       = NO;
        
    }
    
    return self;
}

- (void) discard
{
    const GLenum discards[]  = { GL_DEPTH_ATTACHMENT, GL_STENCIL_ATTACHMENT };
    glDiscardFramebufferEXT(GL_FRAMEBUFFER, 2, discards);
}

- (CGSize) createFrameBufferFromDrawable:(id<EAGLDrawable>)drawable inContext:(EAGLContext*)context
{
    // Create default frame/renderbuffer objects
    glGenFramebuffers(1, &_framebuffer);
    glGenRenderbuffers(1, &_colorRenderbuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
    
    // Allocate color buffer backing based on the current layer size
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:drawable];
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderbuffer);
    
    // Get size of backing/viewport
    int backingWidth, backingHeight;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    
    // Enables depth buffer for drawing with given z-order instead of drawing order
	if (_depthBufferEnabled)
	{
        glEnable(GL_DEPTH_TEST);
        
		glGenRenderbuffers(1, &_depthRenderbuffer);
		glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderbuffer);
		glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, backingWidth, backingHeight);
		glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderbuffer);
	}
    
    if (_stencilBufferEnabled)
	{
        // TODO: Enable stencil buffer... 
	}
	
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
    {
        return CGSizeZero;
    }
    
    return CGSizeMake(backingWidth, backingHeight);
}

- (void) destroy
{
    if (_framebuffer)
    {
        glDeleteFramebuffers(1, &_framebuffer);
        _framebuffer = 0;
    }
	
    if (_colorRenderbuffer)
    {
        glDeleteRenderbuffers(1, &_colorRenderbuffer);
        _colorRenderbuffer = 0;
    }
	
	if (_depthRenderbuffer)
	{
		glDeleteRenderbuffers(1, &_depthRenderbuffer);
        _depthRenderbuffer = 0;
	}
    
    if (_stencilRenderbuffer)
	{
		glDeleteRenderbuffers(1, &_stencilRenderbuffer);
        _stencilRenderbuffer = 0;
	}
}

@end
