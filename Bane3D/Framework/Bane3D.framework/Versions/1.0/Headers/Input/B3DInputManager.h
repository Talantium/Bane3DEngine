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


@class B3DBaseNode;
@protocol B3DTouchResponder;


@interface B3DInputManager : NSObject <UIAccelerometerDelegate>

@property (nonatomic, readonly) GLKVector3  rawAcceleration;
@property (nonatomic, readonly) GLKVector3  filteredAcceleration;
@property (nonatomic, assign)   GLfloat     accelerometerFilterFactor;

+ (B3DInputManager*) sharedManager;

- (void) updateReceiverOrder;

- (void) registerForTouchEvents:(B3DBaseNode<B3DTouchResponder>*)node;
- (void) unregisterForTouchEvents:(B3DBaseNode<B3DTouchResponder>*)node;

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event forView:(UIView*)parentView;
- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event forView:(UIView*)parentView;
- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event forView:(UIView*)parentView;
- (void) touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event forView:(UIView*)parentView;

- (void) enableAccelerometerInput;
- (void) enableAccelerometerInput:(float)acclerometerFrequency;


@end
