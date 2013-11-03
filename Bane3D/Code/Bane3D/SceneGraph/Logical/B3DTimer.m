//
//  B3DTimer.m
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

#import "B3DTimer.h"

#import "B3DTime.h"
#import "B3DNode+Protected.h"


@interface B3DTimer ()
{
    @private
        id						_target;
        id						_object;
        SEL						_action;
        
        BOOL					_repeats;
        double					_delay;
        
        double					_timeElapsed;
}

@end


@implementation B3DTimer

#pragma mark - Con-/Destructor

- (id) initWithTarget:(id)target
               action:(SEL)action
               object:(id)object
                delay:(double)delay
              repeats:(BOOL)isRepeating
{
	self = [super init];
	if (self)
	{
		if (target != nil && delay > 0)
		{
			_target		= target; // Keep only weak link to target
			_action		= action;
			_object		= object;
			_delay		= delay;
			_repeats	= isRepeating;
		}
		else
		{
			self = nil;
		}
	}
	
	return self;
}

- (void) updateWithSceneGraphInfo:(B3DSceneGraphInfo)info
{
    if (_hidden == NO)
    {
        [super updateWithSceneGraphInfo:info];
        
        _timeElapsed += [B3DTime deltaTime];
        
        if (_timeElapsed >= _delay)
        {
            if ([_target respondsToSelector:_action])
            {
                if (_object)
                {
                    B3DSuppressPerformSelectorLeakWarning([_target performSelector:_action withObject:_object]);
                }
                else
                {
                    B3DSuppressPerformSelectorLeakWarning([_target performSelector:_action]);
                }
            }
            
            if (_repeats)
            {
                _timeElapsed = 0;
            }
            else
            {
                [self removeFromParent];
            }
        }
    }
}


- (NSString*) description
{
	return [NSString stringWithFormat:@"%@ @ {%.2f, %.2f, %.2f} (Repeats: %@, Delay: %0.3f)", (_name ? _name : @"Timer"), self.position.x, self.position.y, self.position.z, (_repeats ? @"YES" : @"NO"), _delay];
}

@end
