//
//  B3DTexture.m
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

#import "B3DTexture.h"

#import "B3DAsset+Protected.h"
#import "B3DTexture_Protected.h"


@implementation B3DTexture

- (id) initWithTexture:(NSString*)name ofType:(NSString*)type
{
	self = [super initWithResourceNamed:name ofType:type];
	if (self != nil)
	{
		_width				= 0;
		_height				= 0;
		_hasAlpha			= NO;
        
        // Invert Y by default, leave X as it is
        _invertX            = NO;
        _invertY            = YES;

		_textureFormat		= B3DTextureFormat_RGBA;
		_bitsPerComponent	= 0;
		_mipCount			= 0;
		
		_imageData			= nil;
	}
	
	return self;
}

- (void) dealloc
{
	_imageData = nil;
	
}


- (void*) imageData
{
	return nil;
}


- (void) enable
{
    [super enable];
    
    [_stateManager bindTexture:_openGlName];
}


@end
