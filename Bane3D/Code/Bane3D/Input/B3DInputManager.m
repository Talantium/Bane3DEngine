//
//  B3DInputManager.m
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

#import "B3DInputManager.h"

#import "SynthesizeSingleton.h"
#import "B3DBaseNode.h"
#import "B3DConstants.h"


@interface B3DInputManager ()
{
    @private
        NSMutableSet*			_touchResponder;
        NSArray*				_touchResponderZSorted;
        NSMutableArray*         _visibleResponder;
        GLKVector3              _rawAcceleration;
        GLKVector3              _filteredAcceleration;
        GLfloat                 _accFilterFactor;
}

@end


@implementation B3DInputManager

#pragma mark - Con-/Destructor

- (id) init
{
	self = [super init];
	if (self)
	{
		_touchResponder         = [[NSMutableSet alloc] init];
		_touchResponderZSorted  = nil;
		_visibleResponder       = [[NSMutableArray alloc] init];
        
        _rawAcceleration        = GLKVector3Make(0.0f, 0.0f, 0.0f);
        _filteredAcceleration   = GLKVector3Make(0.0f, 0.0f, 0.0f);
        _accFilterFactor        = B3DInputAccelerometerDefaultFilterFactor;
	}
	
	return self;
}


#pragma mark - Managing Touch Receivers

- (void) registerForTouchEvents:(B3DBaseNode<B3DTouchResponder>*)node
{
	[_touchResponder addObject:node];
}

- (void) unregisterForTouchEvents:(B3DBaseNode<B3DTouchResponder>*)node
{
	if ([_touchResponder containsObject:node])
	{
		[_touchResponder removeObject:node];
	}
}

- (void) updateReceiverOrder
{
	// Get all visible receiver currently registered
	for (B3DBaseNode<B3DTouchResponder>* responder in _touchResponder)
	{
		if (responder.isVisible)
		{
			[_visibleResponder addObject:responder];
		}
	}
	
	_touchResponderZSorted = [_visibleResponder sortedArrayUsingSelector:@selector(compareByZValueAscending:)];
	[_visibleResponder removeAllObjects];
}


#pragma mark - Handling Touches

/*
 *	Alternate touch processing with lesser repetitive code but
 *	annoying need to return [NSNumber numberWithBool:...];
 *	(Maybe use a #define to mask that... )
 *
 
- (void) iterateResponderPerformSelector:(SEL)selector withTouces:(NSSet*)touches andView:(UIView*)view
{
	for (UITouch* touch in touches)
	{
		for (B3DBaseNode<B3DTouchResponder>* responder in _touchResponder)
		{
			if ([responder isVisible]
				&& [responder respondsToSelector:selector])
			{
				BOOL handled = [(NSNumber*)[responder performSelector:selector 
														   withObject:touch 
														   withObject:view] boolValue];
				if (handled)
				{
					break;
				}
			}
		}
	}
}

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event forView:(UIView*)parentView
{
	[self iterateResponderPerformSelector:@selector(handleTouchesBegan:forView:)
							   withTouces:touches
								  andView:parentView];
}
*/

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event forView:(UIView*)parentView
{
	for (UITouch* touch in touches)
	{
		for (B3DBaseNode<B3DTouchResponder>* responder in _touchResponderZSorted)
		{
			if ([responder respondsToSelector:@selector(handleTouchesBegan:forView:)])
			{
				if ([responder handleTouchesBegan:touch forView:parentView])
				{
					break;
				}
			}
		}
	}
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event forView:(UIView*)parentView
{
	for (UITouch* touch in touches)
	{
		for (B3DBaseNode<B3DTouchResponder>* responder in _touchResponderZSorted)
		{
			if ([responder respondsToSelector:@selector(handleTouchesMoved:forView:)])
			{
				if ([responder handleTouchesMoved:touch forView:parentView])
				{
					break;
				}
			}
		}
	}	
}

- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event forView:(UIView*)parentView
{
	for (UITouch* touch in touches)
	{
		for (B3DBaseNode<B3DTouchResponder>* responder in _touchResponderZSorted)
		{
			if ([responder respondsToSelector:@selector(handleTouchesEnded:forView:)])
			{
				if ([responder handleTouchesEnded:touch forView:parentView])
				{
					break;
				}
			}
		}
	}	
}

- (void) touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event forView:(UIView*)parentView
{
	for (UITouch* touch in touches)
	{
		for (B3DBaseNode<B3DTouchResponder>* responder in _touchResponderZSorted)
		{
			if ([responder respondsToSelector:@selector(handleTouchesCancelled:forView:)])
			{
				if ([responder handleTouchesCancelled:touch forView:parentView])
				{
					break;
				}
			}
		}
	}	
}


#pragma mark - Accelerometer Input

- (void) enableAccelerometerInput
{
	[self enableAccelerometerInput:B3DInputAccelerometerDefaultFrequency];
}

- (void) enableAccelerometerInput:(float)accelerometerFrequency
{
	// Configure and start accelerometer
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / accelerometerFrequency)];
	[[UIAccelerometer sharedAccelerometer] setDelegate:self];
}

- (void) accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{
	_rawAcceleration.x = acceleration.x;
	_rawAcceleration.y = acceleration.y;
	_rawAcceleration.z = acceleration.z;
	
	// Use a basic low-pass filter to only keep the gravity in the accelerometer values
	_filteredAcceleration.x = acceleration.x * _accFilterFactor + _filteredAcceleration.x * (1.0f - _accFilterFactor);
	_filteredAcceleration.y = acceleration.y * _accFilterFactor + _filteredAcceleration.y * (1.0f - _accFilterFactor);
	_filteredAcceleration.z = acceleration.z * _accFilterFactor + _filteredAcceleration.z * (1.0f - _accFilterFactor);
}


#pragma mark - Singleton methods

SYNTHESIZE_SINGLETON_FOR_CLASS(B3DInputManager, sharedManager)


@end
