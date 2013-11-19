//
//  Bane3DEngine.h
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

#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/gl.h>
#import <CoreGraphics/CoreGraphics.h>

@class B3DColor;
@class B3DInputManager;
@class B3DScene;
@class B3DSceneManager;
@class B3DAssetManager;
@class B3DRenderMan;
@class B3DGLStateManager;
@class B3DFrameBuffer;

@class CAEAGLLayer;
@class EAGLContext;
@class GLKView;


@interface Bane3DEngine : NSObject

@property (nonatomic, readonly,  strong)    B3DSceneManager*    sceneManager;
@property (nonatomic, readonly,  strong)    B3DRenderMan*       renderMan;
@property (nonatomic, readonly,  strong)    B3DFrameBuffer*     defaultFrameBuffer;

// Clearing the buffer every frame is costly, if you draw fullscreen
// consider switching it off to improve performance!
@property (nonatomic, readwrite, assign)    BOOL                clearBuffer;    //!< Default: YES
@property (nonatomic, readwrite, assign)    GLbitfield          clearMask;      //!< Default: GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT
@property (nonatomic, readwrite, strong)    B3DColor*           clearColor;     //!< Default: [B3DColor grayColor]

@property (nonatomic, readwrite, strong)    EAGLContext*        context;
@property (nonatomic, readwrite, assign)    GLfloat             contentScale;   //!< By default 1 on normal, 2 on retina devices, set to 1 if you want to force lower res on retina devices
@property (nonatomic, readonly,  assign)    CGSize              viewportSize;   //!< The viewport size (the size of the unscaled window)
@property (nonatomic, readonly,  assign)    CGSize              backingSize;    //!< The size of the rendering backing, on retina its double the viewportSize


/**
 *	Shared access for convience
 */
+ (Bane3DEngine*) entity;
+ (B3DSceneManager*) sceneManager;
+ (B3DAssetManager*) assetManager;
+ (CGPoint) relativeToAbsoluteCoordsFromX:(GLfloat)relativeX y:(GLfloat)relativeY;

@end


/**
 *	Scene Management
 */
@interface Bane3DEngine (SceneManagement)

- (void) setAndLoadRootScene:(B3DScene*)rootScene;
- (void) addScene:(B3DScene*)scene;

@end


/**
 *	Gameloop and Drawing
 */
@interface Bane3DEngine (Gameloop)

- (void) update;
- (void) draw;

- (void) setupGL;
- (void) tearDownGL;

- (BOOL) resizeFromLayer:(CAEAGLLayer*)layer;

// GLKitViewController Support
- (void) viewDidResize:(GLKView*)view;

@end


/**
 *	Input
 */
@interface Bane3DEngine (Input)

- (void) startAccelerometer;
- (void) stopAccelerometer;

- (void) handleTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event forView:(UIView*)parentView;
- (void) handleTouchesMoved:(NSSet*)touches withEvent:(UIEvent*)event forView:(UIView*)parentView;
- (void) handleTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event forView:(UIView*)parentView;
- (void) handleTouchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event forView:(UIView*)parentView;

@end
