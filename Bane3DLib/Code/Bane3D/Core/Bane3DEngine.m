//
//  Bane3DEngine.m
//  Bane3D
//
//  Created by Andreas Hanft on 06.04.11.
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

#import <QuartzCore/QuartzCore.h>

#import "Bane3DEngine.h"

#import "B3DSceneManager.h"
#import "B3DAssetManager.h"
#import "B3DInputManager.h"
#import "B3DGLStateManager.h"
#import "B3DRenderMan.h"
#import "B3DScene.h"
#import "B3DNode+Protected.h"
#import "B3DFrameBuffer.h"
#import "B3DColor.h"
#import "B3DHelper.h"

#import "UIApplication+ApplicationDimensions.h"


@interface Bane3DEngine ()
{
    @private
        B3DGLStateManager*  __weak      _stateManager;
        B3DInputManager*    __weak      _inputManager;
}

@property (nonatomic, readwrite, strong)    B3DFrameBuffer*     defaultFrameBuffer;

@end


@implementation Bane3DEngine


#pragma mark - Class/Singleton Methods

static Bane3DEngine* sInstance = nil;


+ (Bane3DEngine*) entity
{
	return sInstance;
}

+ (B3DSceneManager*) sceneManager
{
	return sInstance.sceneManager;
}

+ (B3DAssetManager*) assetManager
{
	return sInstance.sceneManager.assetManager;
}

+ (CGPoint) relativeToAbsoluteCoordsFromX:(GLfloat)relativeX y:(GLfloat)relativeY
{
    CGSize viewportSize = [[Bane3DEngine entity] viewportSize];
	return CGPointMake((int) (viewportSize.width * relativeX),
                       (int) (viewportSize.height * relativeY));
}


#pragma mark - Initialization/Dealloc

- (id) init
{
    self = [super init];
    if (self)
    {
        // Setup
        {
			// Access to shared instance, singleton for the poor ;)
			sInstance			= self;
            
            _clearBuffer		= YES;
            self.clearColor		= [B3DColor grayColor];
            _clearMask          = ( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
			
            _contentScale       = [[UIScreen mainScreen] scale];
			
			_inputManager		= [B3DInputManager sharedManager];
            _stateManager       = [B3DGLStateManager sharedManager];
			_sceneManager		= [[B3DSceneManager alloc] init];
            _renderMan          = [[B3DRenderMan alloc] init];
            _defaultFrameBuffer = [[B3DFrameBuffer alloc] init];
        }
    }
    
    return self;
}

- (void) dealloc
{
    [self clearContext];
    
	_stateManager   = nil;
    _inputManager   = nil;
    
    sInstance       = nil;
}


#pragma mark - Scene Management

- (void) setAndLoadRootScene:(B3DScene*)rootScene
{
    [_sceneManager setRootScene:rootScene];
    [_sceneManager loadRootScene];
}

- (void) addScene:(B3DScene*)scene
{
    [_sceneManager addScene:scene];
}


#pragma mark - Game Loop

- (void) update
{	
	// Update Scene
	[_sceneManager.currentScene update];
	
	// Update touch receiver order for input events, must happen every frame
    // since they could move!
	[_inputManager updateReceiverOrder];
}

- (void) draw
{
    [_stateManager setCurrentContext:_context];	
    [_stateManager bindFrameBuffer:_defaultFrameBuffer.framebuffer];
    
	if (_clearBuffer)
    {
        [_stateManager setClearColor:_clearColor];
        
		glClear(_clearMask);
    }
    
	// Draw current scene
    [_sceneManager.currentScene draw];
	
    // Let the renderman draw the optimized nodes
//	[_renderMan render];

    // Rebind in case framebuffer changed
    [_stateManager bindFrameBuffer:_defaultFrameBuffer.framebuffer];
    [_defaultFrameBuffer discard];
	    
    [_stateManager bindRenderBuffer:_defaultFrameBuffer.colorRenderbuffer];

    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void) setupGL
{
    if (_context == nil)
    {
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        if (_context == nil || ![[B3DGLStateManager sharedManager] setCurrentContext:_context])
        {
            LogError(@"Failed to create context!");
            
            return;
        }
    }

    // Basic OpenGL settings
    {
        // Enable culling
        glCullFace(GL_BACK);
        glEnable(GL_CULL_FACE);

        // Blending/Alpha setting to one minus alpha
        [_stateManager enableBlending];
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

        // Default depth sort function
        glEnable(GL_DEPTH_TEST);
        glDepthFunc(GL_LEQUAL);

        // No stencil test required by default
        glDisable(GL_STENCIL_TEST);
    }

    [_renderMan createBuffers];

#if DEBUG
    checkGLError();
#endif
}

- (void) tearDownGL
{
    [_renderMan tearDownBuffers];
    [self clearContext];
}


#pragma mark - Manage Context

- (BOOL) resizeFromLayer:(CAEAGLLayer*)layer
{
    [_stateManager setCurrentContext:_context];
    
    // Clear old buffer
    [_defaultFrameBuffer destroy];
	
    // Create new
    CGSize backingSize = [_defaultFrameBuffer createFrameBufferFromDrawable:layer inContext:_context];
    if (CGSizeEqualToSize(backingSize, CGSizeZero))
    {
        LogDebug(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        
        return NO;
    }

	// Set viewport size
	glViewport(0, 0, backingSize.width, backingSize.height);

    // Remember dimensions
    _viewportSize = CGSizeMake(backingSize.width / _contentScale, backingSize.height / _contentScale);
    _backingSize = backingSize;
    
    for (B3DScene* scene in _sceneManager.scenes)
    {
        [scene viewportDidChangeTo:CGRectMake(0, 0, _viewportSize.width, _viewportSize.height)];
    }
    
    LogDebug(@"Created viewport - _viewportSize: %@ _backingSize: %@ (Scale: %f)",
             NSStringFromCGSize(_viewportSize),
             NSStringFromCGSize(_backingSize),
             _contentScale);
	
    return YES;
}

- (void) clearContext
{
    [_defaultFrameBuffer destroy];
	
    // Tear down context
    if ([EAGLContext currentContext] == _context)
	{
		[_stateManager setCurrentContext:nil];
	}
    _context = nil;
}


#pragma mark - GLKitViewController Support

- (void) viewDidResize:(GLKView*)view
{
    CGSize backingSize = CGSizeMake(view.drawableWidth, view.drawableHeight);
    _contentScale = view.layer.contentsScale;
    
    if (view.drawableWidth == 0 || view.drawableHeight == 0)
    {
        // In early states, drawable area of view might still be unknown, to prevent
        // a possible flicker, use application size for layout.
        CGSize size = [UIApplication currentSize];
        
        backingSize.width = size.width * _contentScale;
        backingSize.height = size.height * _contentScale;
    }
    
    _viewportSize = CGSizeMake(_backingSize.width / _contentScale, _backingSize.height / _contentScale);
    _backingSize = backingSize;
    
    for (B3DScene* scene in _sceneManager.scenes)
    {
        [scene viewportDidChangeTo:CGRectMake(0, 0, _viewportSize.width, _viewportSize.height)];
    }
    
    LogDebug(@"Created viewport - _viewportSize: %@ _backingSize: %@ (Scale: %f)",
             NSStringFromCGSize(_viewportSize),
             NSStringFromCGSize(_backingSize),
             _contentScale);
}


#pragma mark - Touch/Accelerometer Input Handling

- (void) enableAccelerometerInput
{
	[_inputManager startAccelerometerInput];
}

- (void) disableAccelerometerInput
{
	[_inputManager stopAccelerometerInput];
}


- (void) handleTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event forView:(UIView*)parentView
{
	[_inputManager touchesBegan:touches withEvent:event forView:parentView];
}

- (void) handleTouchesMoved:(NSSet*)touches withEvent:(UIEvent*)event forView:(UIView*)parentView;
{
	[_inputManager touchesMoved:touches withEvent:event forView:parentView];
}

- (void) handleTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event forView:(UIView*)parentView
{
	[_inputManager touchesEnded:touches withEvent:event forView:parentView];
}

- (void) handleTouchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event forView:(UIView*)parentView
{
	[_inputManager touchesCancelled:touches withEvent:event forView:parentView];
}

@end
