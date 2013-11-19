//
//  B3DViewController.m
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

#import "B3DViewController.h"

#import "Bane3DEngine.h"
#import "B3DSceneManager.h"
#import "B3DTime.h"
#import "B3DAssert.h"


@interface B3DViewController ()
{
    @private
        CGRect              _drawRect;
}

@property (nonatomic, readwrite, strong) Bane3DEngine*  engine;
@property (nonatomic, readwrite, strong) EAGLContext*   context;

@end


@implementation B3DViewController

#pragma mark - Con-/Destructor

- (void) initialize
{
    // Set defaults
    [B3DTime reset];
    _drawRect                   = CGRectZero;
    
    // Create barebone engine
    _engine                     = [[Bane3DEngine alloc] init];
    
    // Set delegate to self so we get pause information
    self.delegate               = self;
}

// For creating view controller manually
- (id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self != nil)
    {
        [self initialize];
    }
    
    return self;
}

// When instantiated from a nib file
- (void) awakeFromNib
{
    [self initialize];
}

- (void) dealloc
{    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context)
    {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void) loadView
{
    // Create context and fullscreen GLKView for drawing the OpenGL content
    EAGLContext* context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    {
        GLKView* view = [[GLKView alloc] initWithFrame:[[UIScreen mainScreen] bounds]
                                               context:context];
        {
            view.drawableColorFormat    = GLKViewDrawableColorFormatRGBA8888;
            view.drawableDepthFormat    = GLKViewDrawableDepthFormat24;
            view.drawableMultisample    = GLKViewDrawableMultisampleNone;
            view.drawableStencilFormat  = GLKViewDrawableStencilFormatNone;
        }
        self.view = view;
    }
    self.context = context;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if ([self isViewLoaded] && ([[self view] window] == nil))
    {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context)
        {
            [EAGLContext setCurrentContext:nil];
        }
        
        self.context = nil;
    }
    
    // Dispose of any resources that can be recreated.
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

- (void) setupGLforView:(GLKView*)view
{
    [EAGLContext setCurrentContext:self.context];
        
    _engine.context = self.context;
    [_engine setupGL];
    
    if (CGRectEqualToRect(_drawRect, view.frame) == NO)
    {
//        LogDebug(@"GLKView size=%@, drawingWidth=%d drawingHeight=%d, scale=%f", NSStringFromCGRect(view.frame), view.drawableWidth, view.drawableHeight, view.layer.contentsScale);
        
        [_engine viewDidResize:view];
        
        _drawRect = view.frame;
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setupGLforView:(GLKView*)self.view];
    
    [B3DAssert that:([self.engine.sceneManager rootScene] != nil)
       errorMessage:[NSString stringWithFormat:@"No root scene of engine set! Override 'setupGLforView:' in %@ and set it there!", NSStringFromClass([self class])]];
}

- (void) tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    [_engine tearDownGL];
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void) update
{
    // Calculate time it took to render last frame
    [B3DTime tick];
    
    // Update engine
	[_engine update];
}

- (void) glkView:(GLKView*)view drawInRect:(CGRect)rect
{
    if (CGRectEqualToRect(_drawRect, rect) == NO)
    {
//        LogDebug(@"GLKView size=%@, drawingWidth=%d drawingHeight=%d, scale=%f, drawRect=%@", NSStringFromCGRect(view.frame), view.drawableWidth, view.drawableHeight, view.layer.contentsScale, NSStringFromCGRect(rect));
        
        [_engine viewDidResize:view];
        
        _drawRect = rect;
    }
    
    // Draw all nodes
    [_engine draw];
}

// Required but not called since we subclass and implement update
- (void) glkViewControllerUpdate:(GLKViewController*)controller
{}

- (void) glkViewController:(GLKViewController*)controller willPause:(BOOL)pause
{
    // Reset timing when resuming from pause
    if (pause == NO)
    {
        [B3DTime reset];
    }
}

#pragma mark - Touch handling

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
	[_engine handleTouchesBegan:touches withEvent:event forView:self.view];
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
	[_engine handleTouchesMoved:touches withEvent:event forView:self.view];
}

- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
	[_engine handleTouchesEnded:touches withEvent:event forView:self.view];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[_engine handleTouchesCancelled:touches withEvent:event forView:self.view];
}



@end
