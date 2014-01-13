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

#import <CoreMotion/CoreMotion.h>

#import "B3DInputManager.h"

#import "SynthesizeSingleton.h"
#import "B3DNode.h"
#import "B3DConstants.h"
#import "B3DMathHelper.h"


const NSTimeInterval    B3DInputAccelerometerDefaultFrequency       = 60.0f;
const CGFloat           B3DInputAccelerometerDefaultFilterFactor    = 0.1f;


@interface B3DInputManager ()
{
  @private
    NSMutableSet*			_touchResponder;
    NSArray*				_touchResponderZSorted;
    NSMutableArray*         _visibleResponder;
    
    GLfloat                 _accelerationFilterFactor;
}

@property (nonatomic, readwrite, assign) GLKVector3  accelerationRaw;
@property (nonatomic, readwrite, assign) GLKVector3  accelerationFiltered;

@property (nonatomic, readwrite, strong) CMMotionManager* motionManager;

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
        
        _motionManager          = [[CMMotionManager alloc] init];
        
        _accelerationRaw        = GLKVector3Make(0.0f, 0.0f, 0.0f);
        _accelerationFiltered   = GLKVector3Make(0.0f, 0.0f, 0.0f);
        _accelerationFilterFactor = B3DInputAccelerometerDefaultFilterFactor;
	}
	
	return self;
}


#pragma mark - Managing Touch Receivers

- (void) registerForTouchEvents:(B3DNode<B3DTouchResponder>*)node
{
	[_touchResponder addObject:node];
}

- (void) unregisterForTouchEvents:(B3DNode<B3DTouchResponder>*)node
{
	if ([_touchResponder containsObject:node])
	{
		[_touchResponder removeObject:node];
	}
}

- (void) updateReceiverOrder
{
	// Get all visible receiver currently registered
	for (B3DNode<B3DTouchResponder>* responder in _touchResponder)
	{
		if (responder.isHidden == NO)
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
		for (B3DNode<B3DTouchResponder>* responder in _touchResponder)
		{
			if ([responder isHidden] == NO
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
		for (B3DNode<B3DTouchResponder>* responder in _touchResponderZSorted)
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
		for (B3DNode<B3DTouchResponder>* responder in _touchResponderZSorted)
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
		for (B3DNode<B3DTouchResponder>* responder in _touchResponderZSorted)
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
		for (B3DNode<B3DTouchResponder>* responder in _touchResponderZSorted)
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

- (void) startAccelerometerInput
{
	[self startAccelerometerInputWithFrequency:B3DInputAccelerometerDefaultFrequency];
}

- (void) startAccelerometerInputWithFrequency:(NSTimeInterval)accelerometerFrequency
{
    _motionManager.accelerometerUpdateInterval = (1.0 / accelerometerFrequency);
    
    NSOperationQueue *accelerometerQueue = [[NSOperationQueue alloc] init];
    
    __weak typeof(self) weakSelf = self;
    [_motionManager
     startAccelerometerUpdatesToQueue:accelerometerQueue
     withHandler:^(CMAccelerometerData* accelerometerData, NSError* error)
     {
         if (error == nil)
         {
             [weakSelf motionManagerDidProduceAccelerometerData:accelerometerData];
         }
     }];

}

- (void) stopAccelerometerInput
{
    [_motionManager stopAccelerometerUpdates];
}

- (void) motionManagerDidProduceAccelerometerData:(CMAccelerometerData*)accelerometerData
{
	_accelerationRaw.x = accelerometerData.acceleration.x;
	_accelerationRaw.y = accelerometerData.acceleration.y;
	_accelerationRaw.z = accelerometerData.acceleration.z;
	
	// Use a basic low-pass filter to only keep the gravity in the accelerometer values
    CGFloat factor = _accelerationFilterFactor;
    CGFloat inverseFactor = (1.0f - factor);
	_accelerationFiltered.x = _accelerationRaw.x * factor + _accelerationFiltered.x * inverseFactor;
	_accelerationFiltered.y = _accelerationRaw.y * factor + _accelerationFiltered.y * inverseFactor;
	_accelerationFiltered.z = _accelerationRaw.z * factor + _accelerationFiltered.z * inverseFactor;

    _accelerationFiltered.x = fmin(fmax(_accelerationFiltered.x, -1.0), 1.0);
	_accelerationFiltered.y = fmin(fmax(_accelerationFiltered.y, -1.0), 1.0);
	_accelerationFiltered.z = fmin(fmax(_accelerationFiltered.z, -1.0), 1.0);
}


#pragma mark - Singleton methods

SYNTHESIZE_SINGLETON_FOR_CLASS(B3DInputManager, sharedManager)


@end
