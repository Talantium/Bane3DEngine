//
//  UIApplication+ApplicationDimensions.m
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

#import "UIApplication+ApplicationDimensions.h"


@implementation UIApplication (ApplicationDimensions)

+ (BOOL) usingRetina
{
    if ([UIScreen instancesRespondToSelector:@selector(scale)])
    {
        CGFloat scale = [[UIScreen mainScreen] scale];
        
        if (scale > 1.0)
        {
            // Retina screen
            return YES;
        }
        else
        {
            // Regular screen
            return NO;
        }
    }
    
    return NO;
}

+ (BOOL) usingTalliPhoneScreen
{
    return (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double)568) < DBL_EPSILON);
}

+ (CGSize) currentSize
{
    return [UIApplication sizeInOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

+ (CGSize) sizeInOrientation:(UIInterfaceOrientation)orientation
{
    CGSize size = [UIScreen mainScreen].bounds.size;
    UIApplication* application = [UIApplication sharedApplication];
    
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        size = CGSizeMake(size.height, size.width);
    }

    BOOL usesNewStatusBarBehaviour = [UIViewController instancesRespondToSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    if (usesNewStatusBarBehaviour == NO && application.statusBarHidden == NO)
    {
        size.height -= MIN(application.statusBarFrame.size.width, application.statusBarFrame.size.height);
    }
    
    return size;
}

@end