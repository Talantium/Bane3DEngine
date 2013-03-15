//
//  MandelbrotNode.m
//  SampleGame
//
//  Created by Andreas Hanft on 21.04.11.
//  Copyright 2011 talantium.net All rights reserved.
//

#import "MandelbrotNode.h"

#import "Mandelbrot.h"


@interface MandelbrotNode ()
{
    @private
        GLfloat                 _zoom;
        GLKVector2              _fractCenter;
}

@end


@implementation MandelbrotNode

- (id) init
{
    self = [super initWithPNGTexture:@"fract_palette"];
    if (self)
    {
        [self useShader:[Mandelbrot token]];
        
        CGSize screenSize = [UIApplication currentSize];
        self.size = screenSize;
        
        [self setPositionToX:0 andY:0 andZ:-50.0f];
        
        self.multitouchEnabled  = YES;
        self.batchable          = NO;

        _zoom                   = 1.0f;
        _fractCenter            = GLKVector2Make(0.6f, 0.0f);
    }
    
    return self;
}

- (void) update
{
    [super update];
    
    static float deltaTime = 0;
    deltaTime = [B3DTime deltaTime];
    static float angle = 0;
    angle += 10 * deltaTime;

    B3DShader* shader = self.material.shader;
    [shader setVector2Value:_fractCenter forUniformNamed:[Mandelbrot uniformCenter]];
    [shader setFloatValue:_zoom forUniformNamed:[Mandelbrot uniformScale]];
}


#pragma mark - Touch Handling

static GLfloat lastDistance = 0;

- (BOOL) handleTouchesBegan:(UITouch*)touch forView:(UIView*)parentView
{
    if ([super handleTouchesBegan:touch forView:parentView])
    {
        if (self.multitouched)
        {
            CGPoint location01 = [_touches[B3DGUITouchableFirstTouch] locationInView:parentView];            
            CGPoint location02 = [_touches[B3DGUITouchableSecondTouch] locationInView:parentView];
            
            lastDistance = distanceBetweenPoints(location01, location02);
        }
        
        return YES;
    }
	
	return NO;
}


- (BOOL) handleTouchesMoved:(UITouch*)touch forView:(UIView*)parentView
{
    if ([super handleTouchesMoved:touch forView:parentView])
    {
        CGSize size = self.size;

        if (self.multitouched == NO)
        {
            CGPoint location = [touch locationInView:parentView];            
            CGPoint previousLocation = [touch previousLocationInView:parentView];
            
            GLfloat deltaX = location.x - previousLocation.x;
            GLfloat deltaY = location.y - previousLocation.y;
            
            _fractCenter.x += (deltaX/size.width) * 1.7f * _zoom;
            _fractCenter.y += (deltaY/size.height) * 1.7f * _zoom;
        }
        else if (self.multitouched && _touches[B3DGUITouchableFirstTouch] == touch)
        {
            CGPoint location01 = [_touches[B3DGUITouchableFirstTouch] locationInView:parentView];            
            CGPoint location02 = [_touches[B3DGUITouchableSecondTouch] locationInView:parentView];
            
            GLfloat distance = distanceBetweenPoints(location01, location02);
            _zoom += (distance/size.width) * (distance > lastDistance ? -0.1f : 0.1f);
            _zoom = clamp(_zoom, 0.01f, 2.0f);
            
            lastDistance = distance;
        }
        
        return YES;
    }
    
	return NO;
}

@end
