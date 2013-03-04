//
//  B3DRenderMan.m
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

#import "B3DRenderMan.h"

#import "B3DGLStateManager.h"
#import "B3DSpriteBatcher.h"
#import "B3DOpaqueSpriteSorter.h"
#import "B3DTransparentNodeSorter.h"
#import "B3DSprite.h"
#import "B3DLabel.h"


@interface B3DRenderMan ()
{
    @private
        B3DSpriteBatcher*           _spriteBatcher;
        B3DOpaqueSpriteSorter*      _opaqueSpriteSorter;
        B3DTransparentNodeSorter*   _transparentNodeSorter;
        B3DGLStateManager*          _stateManager;
        //
        //        GLuint                      _singleSpriteVertexArrayObject;
        //        GLuint                      _singleSpriteVertexBufferObject[SINGLESPRITEBUFFERCOUNT];
        //    
        //    B3DVertexData               _vertexArray[4];

#if DEBUG_PRINT_STATS_BATCHING
        int         _spritesRendered;
        int         _spritesRenderedLastFrame;
#endif
}

- (void) createBuffers;
- (void) tearDownBuffers;

@end


@implementation B3DRenderMan

@synthesize opaqueSpriteSorter          = _opaqueSpriteSorter;
@synthesize transparentNodeSorter       = _transparentNodeSorter;


#pragma mark - Con-/Destructor

- (id) init
{
    self = [super init];
    if (self)
    {
        _spriteBatcher              = [[B3DSpriteBatcher alloc] init];
        _opaqueSpriteSorter         = [[B3DOpaqueSpriteSorter alloc] initWithSharedBatcher:_spriteBatcher];
        _transparentNodeSorter      = [[B3DTransparentNodeSorter alloc] initWithSharedBatcher:_spriteBatcher];
        _stateManager               = [B3DGLStateManager sharedManager];
    }
    
    return self;
}

- (void) dealloc
{
    [self tearDownBuffers];
    
    _opaqueSpriteSorter = nil;
    _transparentNodeSorter = nil;
    _spriteBatcher = nil;
    
}


#pragma mark - Buffer Handling

- (void) createBuffers
{
    [_spriteBatcher createBuffers];
    
    // Create a buffer and array storage to render a single sprite node
//    {
//        // Create and bind a vertex array object.
//        glGenVertexArraysOES(1, &_singleSpriteVertexArrayObject);
//        glBindVertexArrayOES(_singleSpriteVertexArrayObject);
//        
//        int size = sizeof(B3DVertexData);
//        
//        // Configure the attributes in the VAO.
//        glGenBuffers(SINGLESPRITEBUFFERCOUNT, _singleSpriteVertexBufferObject);
//        for (int i = 0; i < SINGLESPRITEBUFFERCOUNT; i++)
//        {
//            glBindBuffer(GL_ARRAY_BUFFER, _singleSpriteVertexBufferObject[i]);
//            glBufferData(GL_ARRAY_BUFFER, size * 4, NULL, GL_STREAM_DRAW);// GL_DYNAMIC_DRAW);
//        }
//        
//        glEnableVertexAttribArray(B3DVertexAttributesPosition);
//        glVertexAttribPointer(B3DVertexAttributesPosition, 3, GL_FLOAT, GL_FALSE, size, BUFFER_OFFSET(0));
//        
//        glEnableVertexAttribArray(B3DVertexAttributesNormal);
//        glVertexAttribPointer(B3DVertexAttributesNormal, 3, GL_FLOAT, GL_FALSE, size, BUFFER_OFFSET(12));
//        
//        glEnableVertexAttribArray(B3DVertexAttributesColor);
//        glVertexAttribPointer(B3DVertexAttributesColor, 4, GL_UNSIGNED_BYTE, GL_TRUE, size, BUFFER_OFFSET(24));
//        
//        glEnableVertexAttribArray(B3DVertexAttributesTexCoord0);
//        glVertexAttribPointer(B3DVertexAttributesTexCoord0, 2, GL_UNSIGNED_SHORT, GL_TRUE, size, BUFFER_OFFSET(28));
//        
//        glEnableVertexAttribArray(B3DVertexAttributesTexCoord1);
//        glVertexAttribPointer(B3DVertexAttributesTexCoord1, 2, GL_UNSIGNED_SHORT, GL_TRUE, size, BUFFER_OFFSET(32));
//        
//        // Bind back to the default state.
//        glBindVertexArrayOES(0);
//    }
}

- (void) tearDownBuffers
{
    [_spriteBatcher tearDownBuffers];
    
//    for (int i = 0; i < SINGLESPRITEBUFFERCOUNT; i++)
//    {
//        glDeleteBuffers(1, &_singleSpriteVertexBufferObject[i]);
//    }
//    
//    glDeleteVertexArraysOES(1, &_singleSpriteVertexArrayObject);
}

#pragma mark - Drawing
    
- (void) drawOpaqueSprite:(B3DSprite*)sprite
{
    [_opaqueSpriteSorter addSprite:sprite];
}

- (void) drawTransparentSprite:(B3DSprite*)sprite
{
    [_transparentNodeSorter addNode:sprite];
}

- (void) drawTransparentLabel:(B3DLabel*)label
{
    [_transparentNodeSorter addNode:label];
}

- (void) render
{	
    // Render all opaque sprite that could be batched into stripes with same
    // renderID (= same texture/shader/material)
    [_opaqueSpriteSorter render];
    
    // Enable blending for transparent sprites
    if (_transparentNodeSorter.hasNodes)
    {
        glEnable(GL_BLEND);
        [_transparentNodeSorter render];
        glDisable(GL_BLEND);
    }
    
#if DEBUG_PRINT_STATS_BATCHING
    _spritesRenderedLastFrame = _spritesRendered;
    _spritesRendered = 0;
#endif
}

- (void) renderModel:(B3DBaseModelNode*)model
{
    // @TODO: Implement counting of models...
    
}

- (void) renderSprite:(B3DSprite*)sprite
{
#if DEBUG_PRINT_STATS_BATCHING
    _spritesRendered++;
    //LogEcho(@"[INFO] [RenderMan] %i Rendered single sprite with renderID %i", spritesRendered, sprite.material.renderID);
#endif
}

- (void) printDebugStats
{
#if DEBUG_PRINT_STATS_BATCHING
    
    LogEcho(@"[INFO] [RenderMan] ########################################");
    LogEcho(@"[INFO] [RenderMan] Render Stats Sprites: Opague[Single:%i Batched:%i (in %i batches)] - Transp[Total:%i Single:%i Batched:%i]",
            _spritesRenderedLastFrame,
            _opaqueSpriteSorter.spriteCountLastFrame,
            _opaqueSpriteSorter.arrayCountLastFrame,
            _transparentNodeSorter.nodeCountLastFrame,
            _transparentNodeSorter.nodeCountSingleLastFrame,
            _transparentNodeSorter.nodeCountBatchedLastFrame);
    LogEcho(@"[INFO] [RenderMan] ########################################");

#else
    LogEcho(@"[INFO] [RenderMan] Cannot print stats, none being collected! Set DEBUG_PRINT_STATS_BATCHING to 1!");
#endif
}

@end
