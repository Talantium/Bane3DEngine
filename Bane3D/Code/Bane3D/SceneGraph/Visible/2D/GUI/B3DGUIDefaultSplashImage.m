//
//  B3DGUIDefaultSplashImage.m
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

#import "B3DGUIDefaultSplashImage.h"

#import "B3DTexturePNG.h"
#import "UIApplication+ApplicationDimensions.h"


@implementation B3DGUIDefaultSplashImage

+ (NSString*) defaultTextureName
{
    return ([UIApplication usingTalliPhoneScreen] ? @"Default-568h@2x" : @"Default");
}


+ (B3DGUIDefaultSplashImage*) image
{   
    B3DGUIDefaultSplashImage* image = [[self alloc] initWithTexture:[self defaultTextureName]
                                                             ofType:[B3DTexturePNG extension]];
    image.userInteractionEnabled = NO;
    
    return image;
}

+ (B3DGUIDefaultSplashImage*) landscapeImage
{
    B3DGUIDefaultSplashImage* image = [self image];
    CGSize size = [UIApplication currentSize];
    [image setPositionToX:0 y:size.height z:-9123.0f];
    [image rotateByX:0.0f y:0.0f z:-90.0f];
    
    return image;
}

+ (B3DGUIDefaultSplashImage*) portraitImage
{
    B3DGUIDefaultSplashImage* image = [self image];
    [image setPositionToX:0 y:0 z:-9123.0f];
    
    return image;
}

@end
