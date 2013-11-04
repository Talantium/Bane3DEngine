//
//  B3DInputManager.h
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

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>


@class B3DNode;
@protocol B3DTouchResponder;


// Default polling frequency of accelerometer input, same as display refresh (60Hz)
extern const NSTimeInterval B3DInputAccelerometerDefaultFrequency;      //!< 60.0
extern const CGFloat        B3DInputAccelerometerDefaultFilterFactor;   //!< 0.1


@interface B3DInputManager : NSObject

+ (B3DInputManager*) sharedManager;

- (void) updateReceiverOrder;

- (void) registerForTouchEvents:(B3DNode<B3DTouchResponder>*)node;
- (void) unregisterForTouchEvents:(B3DNode<B3DTouchResponder>*)node;

@end


@interface B3DInputManager (Touch)

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event forView:(UIView*)parentView;
- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event forView:(UIView*)parentView;
- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event forView:(UIView*)parentView;
- (void) touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event forView:(UIView*)parentView;

@end


@interface B3DInputManager (Acceleration)

@property (nonatomic, readonly,  assign) GLKVector3  accelerationRaw;
@property (nonatomic, readonly,  assign) GLKVector3  accelerationFiltered;
@property (nonatomic, readwrite, assign) GLfloat     accelerationFilterFactor;

- (void) startAccelerometerInput;
- (void) startAccelerometerInputWithFrequency:(NSTimeInterval)acclerometerFrequency;
- (void) stopAccelerometerInput;

@end
