//
//  EAGLViewController.m
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

#import "B3DGLViewController.h"

#import "B3DConstants.h"
#import "Bane3DEngine.h"
#import "B3DRenderMan.h"
#import "B3DSceneManager.h"
#import "B3DHelper.h"
#import "B3DGLView.h"
#import "B3DAssert.h"
#import "B3DTime.h"


@interface B3DGLViewController ()
{
    @private
		BOOL                        _animating;
		NSInteger                   _animationFrameInterval;
        CADisplayLink*              _displayLink;
        uint                        _frameCount;
    
        BOOL                        _registeredForNotifications;
}

- (void) initialize;
- (void) registerForNotifications;

@end


@implementation B3DGLViewController

@dynamic    animationFrameInterval;
@dynamic    desiredFPS;


#pragma mark - Con-/Destructor

- (void) initialize
{
    // Set defaults   
    _animating					= NO;
    _animationFrameInterval		= 1;
    
    [B3DTime reset];
    
    // Create barebone engine
    _engine                     = [[Bane3DEngine alloc] init];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_engine tearDownGL];
}

- (void) registerForNotifications
{
    if (_registeredForNotifications == NO)
    {
        NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
        UIApplication* application = [UIApplication sharedApplication];
        
        [center addObserver:self selector:@selector(onApplicationBecomingInactive:) name:UIApplicationWillTerminateNotification object:application];
        [center addObserver:self selector:@selector(onApplicationBecomingInactive:) name:UIApplicationWillResignActiveNotification object:application];
        [center addObserver:self selector:@selector(onApplicationBecomingInactive:) name:UIApplicationDidEnterBackgroundNotification object:application];
        [center addObserver:self selector:@selector(onApplicationBecomingActive:) name:UIApplicationWillEnterForegroundNotification object:application];
        
        _registeredForNotifications = YES;
    }
}

#pragma mark - View Lifecylce

- (void) loadView
{
    // Create an fullscreen EAGLView for drawing the OpenGL content
    self.view = [[B3DGLView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Set reference to viewcontroller so we get notified of any view size changes
    if ([self.view isKindOfClass:[B3DGLView class]])
    {
        B3DGLView* view = (B3DGLView*)self.view;
        view.delegate = self;
        ((CAEAGLLayer*)view.layer).contentsScale = _engine.contentScale;
    }
}

- (void) setupGLforView:(B3DGLView*)view
{
    [_engine setupGL];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setupGLforView:(B3DGLView*)self.view];
    
    [self startGameLoop];
    
    [self registerForNotifications];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self stopGameLoop];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _registeredForNotifications = NO;
    
    [super viewWillDisappear:animated];
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if ([self isViewLoaded] && ([[self view] window] == nil))
    {
        self.view = nil;
        
        [_engine tearDownGL];
    }
    
    // Dispose of any resources that can be recreated.
}

// Override in your custom view controller to support only some orientations!
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

// TODO: TEST ROTATION EVENT FOR SCREEN SUPPORT
//- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
//{
//    if (UIInterfaceOrientationIsLandscape(fromInterfaceOrientation)
//        != UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
//    {
//        
//    }
//}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}


#pragma mark - Application Lifecycle

- (void) onApplicationBecomingInactive:(NSNotification*)notification
{
    [self stopGameLoop];
}

- (void) onApplicationBecomingActive:(NSNotification*)notification
{
    [self startGameLoop];
}


#pragma mark - B3DGLView Delegate

 - (void) viewDidResize:(B3DGLView*)view;
{
    [_engine resizeFromLayer:(CAEAGLLayer*)view.layer];
    
    // TODO: Check if these have any negative side effects eg. during rotation!
    [_engine update];
    [_engine draw];
}


#pragma mark - Touch Handling

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


#pragma mark - Handling the Game Loop

- (void) gameLoop:(id)sender
{
#if DEBUG_PERFOMANCE
    NSDate* startTime = [NSDate date];
#endif
    
	_frameCount++;
	
    // Calculate time it took to render last frame
    [B3DTime tick];
    
	// Yield to system calls (touches, etc.)
	while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.002f, FALSE) == kCFRunLoopRunHandledSource);
	
    // Update engine
	[_engine update];
    
    // Draw all nodes
    [_engine draw];
    
#if DEBUG
    double deltaTime = [B3DTime deltaTime];
	static double frameTimeHistory = 0;
    static double timeSinceLastFpsOutput = 0;
    frameTimeHistory += deltaTime;
    timeSinceLastFpsOutput += deltaTime;
    frameTimeHistory /= 2;
    if (timeSinceLastFpsOutput > 4)
    {
        LogEcho(@"[INFO] FPS: %0.f", 1/frameTimeHistory);
        timeSinceLastFpsOutput = 0;
    }
    
    checkGLError();
#endif
    
#if DEBUG_PERFOMANCE
    NSDate* endTime = [NSDate date];
    NSTimeInterval duration = [endTime timeIntervalSinceDate:startTime];
    const double filterFactor = 0.08;
    static double durationHistory = 0;
    static double deltaTimeHistory = 0;

    durationHistory = duration * filterFactor + durationHistory * (1.0 - filterFactor);
    deltaTimeHistory = [B3DTime deltaTime] * filterFactor + deltaTimeHistory * (1.0 - filterFactor);
    
    int cycle = 1200;
    if (_frameCount%cycle == 0)
    {
        LogEcho(@"[PERF] Frame time: %f (dt %f) (avg. over last %i frames)", durationHistory, deltaTimeHistory, cycle);
#if DEBUG_PRINT_STATS_BATCHING
        [_engine.renderMan printDebugStats];
#endif
    }
#endif
}


- (NSInteger) animationFrameInterval
{
    return _animationFrameInterval;
}

- (void) setAnimationFrameInterval:(NSInteger)frameInterval
{
    // Frame interval defines how many display frames must pass between each time the
    // display link fires. The display link will only fire 30 times a second when the
    // frame internal is two on a display that refreshes 60 times a second. The default
    // frame interval setting of one will fire 60 times a second when the display refreshes
    // at 60 times a second. A frame interval setting of less than one results in undefined
    // behavior.
    if (frameInterval >= 1 && frameInterval != _animationFrameInterval)
    {
        _animationFrameInterval = frameInterval;
		
        if (_animating)
        {
            [self stopGameLoop];
            [self startGameLoop];
        }
    }
}

- (NSInteger) desiredFPS
{
    return B3DEngineMaxFps / _animationFrameInterval;
}

- (void) setDesiredFPS:(NSInteger)fps
{
	if (fps <= 0 || fps > B3DEngineMaxFps)
	{
		fps = B3DEngineMaxFps;
	}
	
	[self setAnimationFrameInterval:B3DEngineMaxFps/fps];
}

- (void) startGameLoop
{
    if (!_animating)
    {
        [B3DAssert that:(self.view != nil)
           errorMessage:@"View may not be nil at this point!"];
        
        [B3DAssert that:([self.view isKindOfClass:[B3DGLView class]])
           errorMessage:@"View must be or inherit from B3DGLView!"];
        
        [B3DAssert that:([self.engine.sceneManager rootScene] != nil)
           errorMessage:[NSString stringWithFormat:@"No root scene set! Override 'setupGLforView:' in %@ and set it there!", NSStringFromClass([self class])]];
        
		LogDebug(@"Starting Game Loop with desired FPS: %f", B3DEngineMaxFps / (float)_animationFrameInterval);
        
        // Setup display link
        _displayLink = [[UIScreen mainScreen] displayLinkWithTarget:self
                                                           selector:@selector(gameLoop:)];
        [_displayLink setFrameInterval:_animationFrameInterval];
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		
        [B3DTime reset];
        _animating          = YES;
    }
}

- (void) stopGameLoop
{
    if (_animating)
    {
        [_displayLink invalidate];
        _displayLink = nil;

        _animating = NO;
    }
}


@end