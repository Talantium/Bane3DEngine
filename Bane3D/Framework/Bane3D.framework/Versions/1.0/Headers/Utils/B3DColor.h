//
//  B3DColor.h
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

#import <OpenGLES/ES2/gl.h>


@interface B3DColor : NSObject <NSCopying>

@property (nonatomic, assign, readwrite) GLfloat r;
@property (nonatomic, assign, readwrite) GLfloat g;
@property (nonatomic, assign, readwrite) GLfloat b;
@property (nonatomic, assign, readwrite) GLfloat a;

+ (B3DColor*) colorWithRed:(GLfloat)red green:(GLfloat)green blue:(GLfloat)blue alpha:(GLfloat)alpha;
+ (B3DColor*) colorWithRGBHex:(NSInteger)color;

+ (B3DColor*) whiteColor;
+ (B3DColor*) blackColor;
+ (B3DColor*) grayColor;
+ (B3DColor*) redColor;
+ (B3DColor*) greenColor;
+ (B3DColor*) blueColor;

- (id) initWithRed:(GLfloat)red green:(GLfloat)green blue:(GLfloat)blue alpha:(GLfloat)alpha;
- (id) initWithIntegerRed:(uint)red green:(uint)green blue:(uint)blue alpha:(uint)alpha;
- (id) initWithRGBHex:(NSInteger)color;

@end
