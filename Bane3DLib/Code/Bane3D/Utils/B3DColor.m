//
//  B3DColor.m
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

#import "B3DColor.h"

#import "B3DMathHelper.h"


/*
 // TODO: lerp color blending
 // TODO: Byte interleaved return value
 // TODO: HUE creation
 
 //static inline Color3D Color3DInterpolate(Color3D color1, Color3D color2, GLfloat percent)
 //{
 //	Color3D ret;
 //	ret.red = color1.red + ((color2.red - color1.red) * percent);
 //	ret.blue = color1.blue + ((color2.blue - color1.blue) * percent);
 //	ret.green = color1.green + ((color2.green - color1.green) * percent);
 //	ret.alpha = color1.alpha + ((color2.alpha - color1.alpha) * percent);
 //	
 //	if (ret.red > 1.0)
 //		ret.red -= 1.0;
 //	if (ret.green > 1.0)
 //		ret.green -= 1.0;
 //	if (ret.blue > 1.0)
 //		ret.blue -= 1.0;
 //	if (ret.alpha > 1.0)
 //		ret.alpha = 1.0;
 //	if (ret.red < 0.0)
 //		ret.red += 1.0;
 //	if (ret.green < 0.0)
 //		ret.green += 1.0;
 //	if (ret.blue < 0.0)
 //		ret.blue += 1.0;
 //	if (ret.alpha < 0.0)
 //		ret.alpha += 1.0;
 //	
 //	return ret;
 //}
 
 */


@interface B3DColor ()
{
    @private
        GLfloat				_red;
        GLfloat				_green;
        GLfloat				_blue;
        GLfloat				_alpha;
}

@end


@implementation B3DColor

@synthesize r       = _red;
@synthesize g       = _green;
@synthesize b       = _blue;
@synthesize a       = _alpha;


#pragma mark - Class Methods

+ (B3DColor*) colorWithRed:(GLfloat)red green:(GLfloat)green blue:(GLfloat)blue alpha:(GLfloat)alpha
{
	return [[self alloc] initWithRed:red green:green blue:blue alpha:alpha];
}

+ (B3DColor*) colorWithRGBHex:(NSInteger)color
{
	return [[self alloc] initWithRGBHex:color];
}

+ (B3DColor*) whiteColor
{
	return [[B3DColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
}

+ (B3DColor*) blackColor
{
	return [[B3DColor alloc] initWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
}

+ (B3DColor*) grayColor
{
	return [[B3DColor alloc] initWithRed:0.5f green:0.5f blue:0.5f alpha:1.0f];
}

+ (B3DColor*) redColor
{
	return [[B3DColor alloc] initWithRed:1.0f green:0.0f blue:0.0f alpha:1.0f];
}

+ (B3DColor*) greenColor
{
	return [[B3DColor alloc] initWithRed:0.0f green:1.0f blue:0.0f alpha:1.0f];
}

+ (B3DColor*) blueColor
{
	return [[B3DColor alloc] initWithRed:0.0f green:0.0f blue:1.0f alpha:1.0f];
}


#pragma mark - Con-/Destructor

// Designated initializer
- (id) initWithRed:(GLfloat)red green:(GLfloat)green blue:(GLfloat)blue alpha:(GLfloat)alpha
{
	self = [super init];
	if (self != nil)
	{
		_red    = clamp01(red);
		_blue   = clamp01(blue);
		_green  = clamp01(green);
		_alpha  = clamp01(alpha);
	}
	
	return self;
}

- (id) initWithIntegerRed:(uint)red green:(uint)green blue:(uint)blue alpha:(uint)alpha
{
	self = [self initWithRed:red/255.0f 
					   green:green/255.0f
						blue:blue/255.0f
					   alpha:alpha/255.0f];
	return self;
}

- (id) initWithRGBHex:(NSInteger)color
{
    self = [self initWithRed:((float)((color & 0xFF0000) >> 16))/255.0
					   green:((float)((color & 0xFF00) >> 8))/255.0
						blue:((float)(color & 0xFF))/255.0
					   alpha:1.0];
	return self;
}


#pragma mark - Comparing

- (BOOL) isEqual:(id)otherObject
{
    if ([otherObject isKindOfClass:[B3DColor class]])
    {
        B3DColor* otherColor = (B3DColor*)otherObject;
        if (   _red     == otherColor.r
            && _green   == otherColor.g
            && _blue    == otherColor.b
            && _alpha   == otherColor.a)
        {
            return YES;
        }
    }
    
    return NO;
}

- (NSUInteger) hash;
{
    return [[NSNumber numberWithFloat:_red] hash]
         ^ [[NSNumber numberWithFloat:_green] hash]
         ^ [[NSNumber numberWithFloat:_blue] hash]
         ^ [[NSNumber numberWithFloat:_alpha] hash];
}


#pragma mark - NSCopying

- (id) copyWithZone:(NSZone*)zone
{
    B3DColor* copy = (B3DColor*)[[[self class] allocWithZone:zone] initWithRed:_red
                                                              green:_green
                                                               blue:_blue
                                                              alpha:_alpha];
    
    return copy;
}

@end
