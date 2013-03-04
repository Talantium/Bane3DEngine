//
//  B3DGLViewController.h
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
#import <Bane3D/Core/iOS/B3DGLView.h>

@class Bane3DEngine;


/**
 *	Controls the EAGL View and is responsible for the game loop
 */
@interface B3DGLViewController : UIViewController <B3DGLViewDelegate>

@property (nonatomic, readwrite, strong)            Bane3DEngine*   engine;
@property (nonatomic, readonly, getter=isAnimating) BOOL            animating;

//
//    Property animationFrameInterval controlls FPS, default is 1.
//
//    Since the display has a refresh rate of 60Hz, an animationFrameInterval setting of
//    1 = 60fps
//    2 = 30fps
//    6 = 10fps
//    etc...
//    
//    Use desiredFPS: to set FPS directly to a value!
//
@property (nonatomic, readwrite, assign)            NSInteger       animationFrameInterval;
@property (nonatomic, readwrite, assign)            NSInteger       desiredFPS;

// Override this method to setup the engine in your B3D controller
- (void) setupGLforView:(B3DGLView*)view;

- (void) startGameLoop;
- (void) stopGameLoop;

@end
