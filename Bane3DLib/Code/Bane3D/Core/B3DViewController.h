//
//  B3DViewController.h
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

#import <GLKit/GLKit.h>

@class Bane3DEngine;


/**
 *  This view controller implementation makes use of the new GLKViewController.
 *  After initial successful testing a major caveat has surfaced: there is a brief
 *  flash of an empty framebuffer as the very first frame rendered after launching
 *  the app. As I could not fix this problem after some testing, I discontinued
 *  using this new controller and went back to the old one as there were no real
 *  benefits in using this one.
 *  You know, never change a running system ;)
 *
 */


@interface B3DViewController : GLKViewController <GLKViewControllerDelegate>

@property (nonatomic, readonly, strong) Bane3DEngine*   engine;
@property (nonatomic, readonly, strong) EAGLContext*    context;

// Override this to setup the engine, scenes and any GLKView properties.
// Do not forget to call super first!
- (void) setupGLforView:(GLKView*)view;

@end
