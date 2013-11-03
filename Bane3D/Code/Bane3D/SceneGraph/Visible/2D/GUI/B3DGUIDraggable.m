//
//  B3DGUIDraggable.m
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


#import "B3DGUIDraggable.h"

#import "Bane3DEngine.h"
#import "B3DColor.h"
#import "B3DNode+Protected.h"


@interface B3DGUIDraggable ()
{
   @private 
    
        GLKVector2				_momentum;
        BOOL					_momentumEnabled;
        BOOL					_resizeEnabled;
        GLfloat					_friction;
}

@end


@implementation B3DGUIDraggable

@synthesize	momentumEnabled     = _momentumEnabled;
@synthesize	resizeEnabled       = _resizeEnabled;
@synthesize friction            = _friction;


#pragma mark - Con-/Destructor

- (id) initWithTexture:(NSString*)textureName ofType:(NSString*)type
{
	self = [super initWithTexture:textureName ofType:type];
	if (self != nil)
	{
        // This class can handle multiple touches but for efficiency we 
        // disable multitouch by default
        self.multitouchEnabled  = NO;
		_friction               = 0.888f;
	}
	
	return self;
}


#pragma mark - Game Loop

- (void) updateWithSceneGraphInfo:(B3DSceneGraphInfo)info
{
	[super updateWithSceneGraphInfo:info];
	
	if (_momentumEnabled && GLKVector2Length(_momentum) > 0.01f)
	{
		[self translateByX:_momentum.x y:_momentum.y z:0];
		_momentum = GLKVector2MultiplyScalar(_momentum, _friction);
	}
}


#pragma mark - Extended Touch Handling

- (CGPoint) locationOfTouch:(UITouch*)touch inView:(UIView*)view
{
    CGPoint location = [touch locationInView:view];
    location.y = _engine.viewportSize.height - location.y;
    
    return location;
}

- (CGPoint) previousLocationOfTouch:(UITouch*)touch inView:(UIView*)view
{
    CGPoint location = [touch previousLocationInView:view];
    location.y = _engine.viewportSize.height - location.y;
    
    return location;
}

- (CGPoint) movementDeltaForTouch:(UITouch*)touch inView:(UIView*)view
{
    CGPoint location = [self locationOfTouch:touch inView:view];    
    CGPoint previousLocation = [self previousLocationOfTouch:touch inView:view];
    
    return CGPointMake(location.x - previousLocation.x, location.y - previousLocation.y);
}

- (BOOL) handleTouchesBegan:(UITouch*)touch forView:(UIView*)parentView
{    
	if ([super handleTouchesBegan:touch forView:parentView])
	{
        if (touch == self.firstTouch)
        {
            _momentum = GLKVector2Make(0, 0);
        }

        return YES;
    }
	
	return NO;
}

- (BOOL) handleTouchesMoved:(UITouch*)touch forView:(UIView*)parentView
{
    if ([super handleTouchesMoved:touch forView:parentView])
    {
        if (_touchCount == 1 || _resizeEnabled == NO)
        {
            if (touch == self.firstTouch)
            {
                CGPoint delta = [self movementDeltaForTouch:touch inView:parentView];
                [self translateByX:delta.x y:delta.y z:0];
            }
        }
        else
        {
            // This aint a perfect implementation of resizing the draggable with a multitouch
            // like in the photos app but it gets the job done. As a generic implementation
            // this should be ok for testing and some simple cases.
            CGPoint firstLocation = [self locationOfTouch:self.firstTouch inView:parentView];
            CGPoint secondLocation = [self locationOfTouch:self.secondTouch inView:parentView];
            
            UITouch* primaryTouch = self.firstTouch;
            UITouch* secondaryTouch = self.secondTouch;
            
            if (firstLocation.x > secondLocation.x && firstLocation.y > secondLocation.y)
            {
                primaryTouch = self.secondTouch;
                secondaryTouch = self.firstTouch;
            }
            
            CGPoint delta = [self movementDeltaForTouch:touch inView:parentView];
            if (touch == primaryTouch)
            {
                [self translateByX:delta.x y:delta.y z:0];
            }
            
            if (touch == secondaryTouch
                && _resizeEnabled)
            {
                CGSize size = CGSizeMake(self.size.width + delta.x, self.size.height + delta.y);
                self.size = size;
            }
        }
        
        return YES;
    }
	
	return NO;
}

- (BOOL) handleTouchesEnded:(UITouch*)touch forView:(UIView*)parentView
{
    BOOL wasFirstTouch = (touch == self.firstTouch);
    
	if ([super handleTouchesEnded:touch forView:parentView])
	{
		if (wasFirstTouch && _momentumEnabled)
		{
            // @TODO: Sample over the last few touches to get a smooth fade out

			CGPoint location = [touch locationInView:parentView];
			location.y = _engine.viewportSize.height - location.y;
            
			CGPoint previousLocation = [touch previousLocationInView:parentView];
			previousLocation.y = _engine.viewportSize.height - previousLocation.y;
			
			_momentum.x = location.x - previousLocation.x;
			_momentum.y = location.y - previousLocation.y;
		}
		
		return YES;
    }
	
	return NO;
}

- (BOOL) handleTouchesCancelled:(UITouch*)touch forView:(UIView*)parentView
{
    if ([super handleTouchesCancelled:touch forView:parentView])
    {
		return YES;
    }
	
	return NO;
}


@end
