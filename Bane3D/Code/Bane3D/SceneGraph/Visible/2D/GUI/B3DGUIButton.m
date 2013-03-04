//
//  B3DGUIButton.m
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

#import "B3DGUIButton.h"


@interface B3DGUITouchable (ProtectedMethods)

- (BOOL) touchDidEndOrCancel:(UITouch*)touch;

@end


@interface B3DGUIButton ()

@property (nonatomic, readwrite, weak)   id                 target;
@property (nonatomic, readwrite, assign) SEL                action;
@property (nonatomic, readwrite, weak)   id                 object;

@property (nonatomic, readwrite, assign) B3DGUIButtonState  buttonState;

@end


@implementation B3DGUIButton

- (void) setAction:(SEL)action forTarget:(id)target withObject:(id)object
{
    self.action = action;
    self.target = target;
    self.object = object;
}


#pragma mark - Extended Touch Handling

- (BOOL) handleTouchesBegan:(UITouch*)touch forView:(UIView*)parentView
{    
	if ([super handleTouchesBegan:touch forView:parentView])
	{
        _buttonState = B3DGUIButtonStatePressedInside;
        
        // TESTING
        // self.color = [B3DColor redColor];
        
        return YES;
    }
	
	return NO;
}

- (BOOL) handleTouchesMoved:(UITouch*)touch forView:(UIView*)parentView
{
    BOOL handled = [super handleTouchesMoved:touch forView:parentView];
    if (handled)
    {
        _buttonState = (_touchInside[B3DGUITouchableFirstTouch] ? B3DGUIButtonStatePressedInside : B3DGUIButtonStatePressedOutside);
    }

	return handled;
}

- (BOOL) touchDidEndOrCancel:(UITouch*)touch
{
    BOOL handled = [super touchDidEndOrCancel:touch];
    if (handled)
    {
        if (_buttonState == B3DGUIButtonStatePressedInside)
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
        }
        
        _buttonState = B3DGUIButtonStateNormal;
        
		// TESTING
		// self.color = [B3DColor whiteColor];
    }
    
	return handled;
}

@end
