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
#if DEBUG_PRINT_STATS_BATCHING
        int         _spritesRendered;
        int         _spritesRenderedLastFrame;
#endif
}

@property (nonatomic, strong, readwrite) B3DSpriteBatcher*      spriteBatcher;
@property (nonatomic, weak,   readwrite) B3DGLStateManager*     stateManager;

- (void) createBuffers;
- (void) tearDownBuffers;

@end


@implementation B3DRenderMan

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
}


#pragma mark - Buffer Handling

- (void) createBuffers
{
    [_spriteBatcher createBuffers];
}

- (void) tearDownBuffers
{
    [_spriteBatcher tearDownBuffers];
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
        [_stateManager enableBlending];
        [_transparentNodeSorter render];
        [_stateManager disableBlending];
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
