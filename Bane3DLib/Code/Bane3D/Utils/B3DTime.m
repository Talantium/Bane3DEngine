//
//  B3DTime.m
//  Bane3D
//
//  Created by Andreas Hanft on 07.04.11.
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

#import <QuartzCore/QuartzCore.h>

#import "B3DTime.h"


@implementation B3DTime

static double _sDeltaTime;
static double _sTimeElapsed;
static double _sTimeScale;
static double _sTimeSinceLastFrame;

+ (void) initialize
{
    _sDeltaTime = 0.0;
    _sTimeScale = 1.0;
    _sTimeElapsed = 1.0;
    [self reset];
}

+ (void) tick
{
    double currentTime = CACurrentMediaTime();
	_sDeltaTime = (currentTime - _sTimeSinceLastFrame) * _sTimeScale;
    _sTimeElapsed += _sDeltaTime;
	_sTimeSinceLastFrame = currentTime;
}

+ (void) reset
{
    _sTimeSinceLastFrame = CACurrentMediaTime();
}

+ (double) deltaTime
{
    return _sDeltaTime;
}

+ (double) timeElapsed
{
    return _sTimeElapsed;
}

+ (double) timeScale
{
    return _sTimeScale;
}

+ (void) setTimeScale:(double)timeScale
{
    _sTimeScale = timeScale;
}

@end
