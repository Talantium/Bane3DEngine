//
//  B3DGLView.m
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

#import <QuartzCore/QuartzCore.h>

#import "B3DGLView.h"


@interface B3DGLView ()

- (void) initialize;

@end


@implementation B3DGLView

// You must implement this method
+ (Class) layerClass
{
    return [CAEAGLLayer class];
}


#pragma mark - Con-/Destructor

- (void) initialize
{
    // Setup the view
    {
        self.userInteractionEnabled = YES;
        self.multipleTouchEnabled	= YES;
    }
    
    // Get layer and set it up
    CAEAGLLayer* eaglLayer = (CAEAGLLayer*)self.layer;
    {
        // Set layer opaque, change later if you need a transparent GLView!
        eaglLayer.opaque = YES;
        
        // Use scaling of main screen to support retina display by default,
        // similar setting of engine might override this later, so set desired 
        // scaling in engine!
        eaglLayer.contentsScale      = [[UIScreen mainScreen] scale];
        
        // Other settings
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking,
                                        kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
                                        nil];
    }    
}

// For creating the view from a nib file. When it's unarchived it's sent -initWithCoder:.
- (id) initWithCoder:(NSCoder*)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        [self initialize];
    }
    
    return self;
}

// For manually creating the view with initWithFrame:
- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initialize];
    }
    
    return self;
}

- (void) layoutSubviews
{
    [_delegate viewDidResize:self];
}

@end
