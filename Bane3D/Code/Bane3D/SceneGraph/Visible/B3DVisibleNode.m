//
//  B3DVisibleNode.m
//  Bane3D
//
//  Created by Andreas Hanft on 13.04.11.
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

#import "B3DVisibleNode.h"

#import "B3DDefaultMaterial.h"
#import "B3DGLStateManager.h"
#import "B3DColor.h"
#import "B3DRenderMan.h"
#import "Bane3DEngine.h"
#import "B3DShader.h"
#import "B3DTexture.h"
#import "B3DNode+Protected.h"
#import "B3DVisibleNode+Protected.h"


@implementation B3DVisibleNode

#pragma mark - Con-/Destructor

// Designated initializer
- (id) init
{
	self = [super init];
	if (self)
	{
        // Use built in default material as global fallback material
        [self useAssetWithToken:[B3DDefaultMaterial token]
                      atKeyPath:@"material"];
        
        // For performance reasons we cache the pointer to the global renderman
        _renderMan      = _engine.renderMan;
        _stateManager   = [B3DGLStateManager sharedManager];
        _opaque         = YES;
        self.color      = [B3DColor whiteColor];
	}
	
	return self;
}

- (void) useShaderNamed:(NSString*)name
{
    [self useAssetWithToken:[B3DShader tokenWithName:name]
                  atKeyPath:@"material.shader"];
}

- (void) useShader:(B3DAssetToken*)shaderToken
{
    [self useAssetWithToken:shaderToken
                  atKeyPath:@"material.shader"];
}

- (void) create
{
	[super create];
    
    [self.material updateRenderID];
    
    _opaque = (_opaque == YES && self.material.texture.hasAlpha == NO);
}

- (void) render
{
    // Nothing to render...
}

#pragma mark - Properties

- (BOOL) isOpaque
{
	return (_color.a == 1.0f) && _opaque;
}

@end
