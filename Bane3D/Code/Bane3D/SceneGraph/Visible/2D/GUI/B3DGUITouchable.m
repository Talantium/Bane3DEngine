//
//  B3DGUITouchable.m
//  Bane3D
//
//  Created by Andreas Hanft on 28.04.11.
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

#import "B3DGUITouchable.h"

#import "Bane3DEngine.h"
#import "B3DBaseNode+Protected.h"


@implementation B3DGUITouchable

@dynamic	touched;
@dynamic	multitouched;

@dynamic    firstTouch;
@dynamic    secondTouch;
@dynamic    thirdTouch;


#pragma mark - Con-/Destructor

- (id) initWithTexture:(NSString*)textureName ofType:(NSString*)type
{
	self = [super initWithTexture:textureName ofType:type];
	if (self != nil)
	{
		self.receivesTouchEvents	= YES;
	}
	
	return self;
}

- (void) dealloc
{
    for (int i = 0; i < B3DGUITouchableTouchesCount; i++)
    {
        _touches[i] = nil;
    }
	
}


#pragma mark - Properties

- (BOOL) touched
{
	return (_touchCount > 0);
}

- (BOOL) multitouched
{
	return (_touchCount > 1);
}

- (UITouch*) firstTouch
{
    return _touches[B3DGUITouchableFirstTouch];
}

- (UITouch*) secondTouch
{
    return _touches[B3DGUITouchableSecondTouch];
}

- (UITouch*) thirdTouch
{
    return _touches[B3DGUITouchableThirdTouch];
}


#pragma mark - Helper

- (BOOL) rectContainsTouch:(UITouch*)touch forView:(UIView*)view
{
    CGPoint location = [touch locationInView:view];
    // Invert touch y to conform to OpenGL coords
    location.y = _engine.viewportSize.height - location.y;
    // @TODO: Cache own rect for better perf
    CGRect rect = CGRectMake(self.absolutePosition.x, self.absolutePosition.y, _size.width, _size.height);

    return (CGRectContainsPoint(rect, location));
}


#pragma mark - Touch Handling

- (BOOL) handleTouchesBegan:(UITouch*)touch forView:(UIView*)parentView
{
	if (!_touches[B3DGUITouchableFirstTouch]
        && [self rectContainsTouch:touch forView:parentView])
	{
        _touches[B3DGUITouchableFirstTouch] = touch;
        _touchCount = 1;

        return YES;
	}
    else if (_multitouchEnabled
             && _touchCount < B3DGUITouchableTouchesCount
             && [self rectContainsTouch:touch forView:parentView])
    {
        _touches[_touchCount] = touch;
        _touchCount++;
        
        return YES;
    }

	return NO;
}

- (BOOL) handleTouchesMoved:(UITouch*)touch forView:(UIView*)parentView
{
    for (int i = 0; i < _touchCount; i++)
    {
        if (_touches[i] == touch)
        {
            _touchInside[i] = [self rectContainsTouch:touch forView:parentView];
            
            return YES;
        }
    }
	
	return NO;
}

- (BOOL) touchDidEndOrCancel:(UITouch*)touch
{
    if (_touchCount == 0)
        return NO;
    
    for (int i = 0; i < _touchCount; i++)
    {
        if (_touches[i] == touch)
        {
            _touches[i] = nil;
            _touchInside[i] = NO;
            _touchCount--;
            
            // Shift back all other touches in array
            for (int j = i; j < B3DGUITouchableTouchesCount; j++)
            {
                if (j < _touchCount)
                {
                    _touches[j]     = _touches[j+1];
                    _touchInside[j] = _touchInside[j+1];;
                }
                else
                {
                    _touches[j]     = nil;
                    _touchInside[j] = NO;
                }
            }
            
            return YES;
        }
    }

	return NO;
}

- (BOOL) handleTouchesEnded:(UITouch*)touch forView:(UIView*)parentView
{
	return [self touchDidEndOrCancel:touch];
}

- (BOOL) handleTouchesCancelled:(UITouch*)touch forView:(UIView*)parentView
{
	return [self touchDidEndOrCancel:touch];
}


@end
