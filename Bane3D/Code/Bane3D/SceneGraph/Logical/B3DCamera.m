//
//  B3DCamera.m
//  Bane3D
//
//  Created by Andreas Hanft on 15.04.11.
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

#import <GLKit/GLKit.h>

#import "B3DCamera.h"

#import "B3DConstants.h"
#import "B3DAssert.h"
#import "B3DBaseNode+Protected.h"


// Scene Camera Defaults
const       GLfloat B3DCameraDefaultNearOrtho               = -1000.0f;
const       GLfloat B3DCameraDefaultFarOrtho                = 1000.0f;

const       GLfloat B3DCameraDefaultNearPerspective         = 0.01f;
const       GLfloat B3DCameraDefaultFarPerspective          = 10000.0f;

const       GLfloat B3DCameraDefaultFov                     = 60.0f;


@interface B3DCamera ()
{
    @private
        GLKMatrix4                  _projectionMatrix;
        GLKMatrix4                  _viewMatrix;
        
        CGRect                      _viewport;
        
        GLfloat                     _near;
        GLfloat                     _far;
        
        GLfloat                     _fov;
        
        BOOL						_ortho;
        BOOL                        _projectionMatrixDirty;
}

- (GLKMatrix4) projectionMatrixWithCurrentCameraSetup;

@end


@implementation B3DCamera


#pragma mark - Con-/Destructor

- (id) init
{
    return [self initAsOrtho:NO];
}

- (id) initAsOrtho:(BOOL)ortho
{
    return [self initAsOrtho:ortho
                    withNear:(ortho ? B3DCameraDefaultNearOrtho : B3DCameraDefaultNearPerspective)
                      andFar:(ortho ? B3DCameraDefaultFarOrtho : B3DCameraDefaultFarPerspective)
                      andFov:B3DCameraDefaultFov];
}

// Designated initializer
- (id) initAsOrtho:(BOOL)ortho withNear:(GLfloat)near andFar:(GLfloat)far andFov:(GLfloat)fov
{
    self = [super init];
    if (self)
    {
        // Reset view matrix
        _projectionMatrix       = GLKMatrix4Identity;
		_viewMatrix             = GLKMatrix4Identity;
        
        _ortho                  = ortho;
        _near                   = near;
        _far                    = far;
        _fov                    = fov;
        _viewport               = CGRectZero;
        
        _projectionMatrixDirty  = YES;
    }

    return self;
}


- (GLKMatrix4) projectionMatrixWithCurrentCameraSetup
{
    [B3DAssert that:(CGRectIsEmpty(_viewport) == NO)
       errorMessage:@"Setting Camera with zero viewport rect!"];
    
    GLKMatrix4 matrix;
    if (_ortho)
    {
        matrix = GLKMatrix4MakeOrtho(0.0f,
                                     _viewport.size.width,
                                     0.0f,
                                     _viewport.size.height,
                                     _near,
                                     _far);
    }
    else
    {
        matrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(_fov),
                                           (_viewport.size.width / _viewport.size.height),
                                           _near,
                                           _far);
    }
    
    return matrix;
}

- (void) viewportDidChangeTo:(CGRect)viewport
{
    _viewport = viewport;
    _projectionMatrixDirty = YES;
}

- (void) setOrtho:(BOOL)ortho
{
    if (_ortho != ortho)
    {
        _ortho = ortho;
        
        if (CGRectIsEmpty(_viewport) == NO)
        {
            _projectionMatrixDirty = YES;
        }
    }
}

- (void) setNear:(GLfloat)near
{
    _near = near;
    _projectionMatrixDirty = YES;
}

- (void) setFar:(GLfloat)far
{
    _far = far;
    _projectionMatrixDirty = YES;
}

- (void) setFov:(GLfloat)fov
{
    _fov = fov;
    _projectionMatrixDirty = YES;
}

- (void) updateMatrix
{
    [super updateMatrix];
    
    if (_projectionMatrixDirty)
    {
        _projectionMatrix = [self projectionMatrixWithCurrentCameraSetup];
    }
    
    if (_transformationDirty || _projectionMatrixDirty)
    {
        _viewMatrix = GLKMatrix4Multiply(_projectionMatrix, self.transform);
        _projectionMatrixDirty = NO;
    }
}

- (GLKMatrix4) viewMatrix
{
    if (_projectionMatrixDirty)
    {
        [self updateMatrix];
    }
    
    return _viewMatrix;
}

@end
