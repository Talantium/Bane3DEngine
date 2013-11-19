//
//  B3DGLStateManager.m
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

#import <OpenGLES/EAGL.h>

#import "B3DGLStateManager.h"

#import "B3DColor.h"
#import "SynthesizeSingleton.h"


@interface B3DGLStateManager ()
{
    @private
        EAGLContext*                    __weak _currentContext;

        GLuint                          _currentTexture;
        GLuint                          _currentShaderProgram;
        GLuint                          _currentBuffer;
        GLuint                          _currentIndexBuffer;
    
        GLuint                          _currentFrameBuffer;
        GLuint                          _currentRenderBuffer;
    
        BOOL                            _blendingEnabled;
}

@property (nonatomic, strong, readwrite) B3DColor*     currentClearColor;

@end


@implementation B3DGLStateManager

- (BOOL) setCurrentContext:(EAGLContext*)context
{
    if (_currentContext != context)
    {
        BOOL success = [EAGLContext setCurrentContext:context];
        if (success)
        {
            _currentContext = context;
        }
        
        return success;
    }
    
    return YES;
}

- (void) setClearColor:(B3DColor*)color
{
    if ([color isEqual:_currentClearColor] == NO)
    {
        glClearColor(color.r, color.g, color.b, color.a);
        self.currentClearColor = color;
    }
}

- (void) enableBlending
{
    if (_blendingEnabled == NO)
    {
        glEnable(GL_BLEND);

        _blendingEnabled = YES;
    }
}

- (void) disableBlending
{
    if (_blendingEnabled == YES)
    {
        glDisable(GL_BLEND);

        _blendingEnabled = NO;
    }
}

- (void) bindTexture:(GLuint)textureName
{
	if (_currentTexture != textureName)
	{
        // glActiveTexture(GL_TEXTURE0);
		glBindTexture(GL_TEXTURE_2D, textureName);
		_currentTexture = textureName;
	}
}

- (BOOL) deleteTexture:(GLuint)textureName
{
    if (textureName != 0)
	{
		glDeleteTextures(1, &textureName);
        if (_currentTexture == textureName)
        {
            [self bindTexture:0];
        }

        return YES;
    }
    
    return NO;
}

- (void) readTextureStateFromOpenGL
{
    GLint currentTextureName(0);
    glGetIntegerv(GL_TEXTURE_BINDING_2D, &currentTextureName);
    _currentTexture = currentTextureName;
}

- (void) useProgram:(GLuint)shaderProgramName
{
    if (_currentShaderProgram != shaderProgramName)
	{
        glUseProgram(shaderProgramName);
		_currentShaderProgram = shaderProgramName;
	}
}

- (void) bindBuffer:(GLuint)bufferName
{
    if (_currentBuffer != bufferName)
	{
        glBindBuffer(GL_ARRAY_BUFFER, bufferName);
		_currentBuffer = bufferName;
	}
}

- (void) bindIndexBuffer:(GLuint)bufferName
{
    if (_currentIndexBuffer != bufferName)
	{
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, bufferName);
		_currentIndexBuffer = bufferName;
	}
}

- (void) clearBufferBindings
{
    if (_currentBuffer != 0)
	{
        glBindBuffer(GL_ARRAY_BUFFER, 0);
		_currentBuffer = 0;
	}
    
    if (_currentIndexBuffer != 0)
	{
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
		_currentIndexBuffer = 0;
	}
}

- (BOOL) deleteBuffer:(GLuint)bufferName
{
    if (bufferName != 0)
    {
        glDeleteBuffers(1, &bufferName);
        if (_currentBuffer == bufferName)
        {
            glBindBuffer(GL_ARRAY_BUFFER, 0);
            _currentBuffer = 0;
        }
        
        return YES;
    }
    
    return NO;
}

- (BOOL) deleteIndexBuffer:(GLuint)bufferName
{
    if (bufferName != 0)
    {
        glDeleteBuffers(1, &bufferName);
        if (_currentIndexBuffer == bufferName)
        {
            glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
            _currentIndexBuffer = 0;
        }
        
        return YES;
    }
    
    return NO;
}

- (void) bindFrameBuffer:(GLuint)frameBuffer
{
    if (_currentFrameBuffer != frameBuffer)
	{
        glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
		_currentFrameBuffer = frameBuffer;
	}
}

- (void) bindRenderBuffer:(GLuint)renderBuffer
{
    if (_currentRenderBuffer != renderBuffer)
	{
        glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
		_currentRenderBuffer = renderBuffer;
	}
}


#pragma mark - Singleton methods

SYNTHESIZE_SINGLETON_FOR_CLASS(B3DGLStateManager, sharedManager)


@end
