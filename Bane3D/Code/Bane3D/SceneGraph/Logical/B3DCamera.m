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
#import "B3DNode+Protected.h"


// Scene Camera Defaults
const       GLfloat B3DCameraOrthoDefaultNear               = -1000.0f;
const       GLfloat B3DCameraOrthoDefaultFar                = 1000.0f;

const       GLfloat B3DCameraPerspectiveDefaultNear         = 0.01f;
const       GLfloat B3DCameraPerspectiveDefaultFar          = 10000.0f;
const       GLfloat B3DCameraPerspectiveDefaultFov          = 60.0f;


@interface B3DCamera ()
{
    @protected
        GLKMatrix4                  _projectionMatrix;
        GLKMatrix4                  _viewMatrix;
        
        CGRect                      _viewport;
        
        GLfloat                     _near;
        GLfloat                     _far;
                
        BOOL						_ortho;
        BOOL                        _projectionMatrixDirty;
}

- (GLKMatrix4) projectionMatrix;

@end


@implementation B3DCamera


#pragma mark - Con-/Destructor

// Designated initializer
- (id) init
{
    self = [super init];
    if (self)
    {
        // Reset view matrix
        _projectionMatrix       = GLKMatrix4Identity;
		_viewMatrix             = GLKMatrix4Identity;
        
        _viewport               = CGRectZero;
        
        _projectionMatrixDirty  = YES;
    }
    
    return self;
}

- (void) viewportDidChangeTo:(CGRect)viewport
{
    _viewport = viewport;
    _projectionMatrixDirty = YES;
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

- (GLKMatrix4) projectionMatrix
{
    return GLKMatrix4Identity;
}

- (void) updateProjectionMatrix
{
    if (_projectionMatrixDirty)
    {
        _projectionMatrix = [self projectionMatrix];
        _projectionMatrixDirty = NO;
    }
}

- (void) updateMatrix
{
    [super updateMatrix];
    
    [self updateProjectionMatrix];
        
    _viewMatrix = GLKMatrix4Multiply(_projectionMatrix, self.worldTransform);
}

- (GLKMatrix4) viewMatrix
{
    [self updateMatrix];
    
    return _viewMatrix;
}

@end


@implementation B3DCameraPerspective

- (id) init
{
    return [self initWithFov:B3DCameraPerspectiveDefaultFov
                        near:B3DCameraPerspectiveDefaultNear
                         far:B3DCameraPerspectiveDefaultFar];
}

- (id) initWithFov:(GLfloat)fov near:(GLfloat)near far:(GLfloat)far
{
    self = [super init];
    if (self)
    {
        _ortho                  = NO;
        _near                   = near;
        _far                    = far;
        _fov                    = fov;
    }
    
    return self;
}

- (void) setFov:(GLfloat)fov
{
    _fov = fov;
    _projectionMatrixDirty = YES;
}

- (GLKMatrix4) projectionMatrix
{
    [B3DAssert that:(CGRectIsEmpty(_viewport) == NO)
       errorMessage:@"Setting Camera with zero viewport rect!"];
    
    GLKMatrix4 matrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(_fov),
                                                  (_viewport.size.width / _viewport.size.height),
                                                  _near,
                                                  _far);

    return matrix;
}

- (void) updateMatrix
{
    [self.parentNode updateMatrix];
    
//    GLKMatrix4 absTrans = self.parentNode.worldTransform;
    GLKMatrix4 absTrans = GLKMatrix4MakeWithQuaternion(self.parentNode.worldRotation);
    GLKVector3 eye = GLKVector3Add(self.parentNode.worldPosition, GLKMatrix4MultiplyVector3(absTrans, self.position));// self.worldPosition;
//    NSLog(@"%@ --- %@", NSStringFromGLKMatrix4(absTrans), NSStringFromGLKVector3(eye));
//    eye = self.worldPosition;
    GLKVector3 center;
    GLKVector3 up;
    GLKMatrix4 rotation;
    
    if (!_target || !_up)
        rotation = GLKMatrix4MakeWithQuaternion(self.rotation);
    
    if (_target)
    {
        center = _target.worldPosition;
        if (GLKVector3AllEqualToVector3(eye, center)) LogWarning(@"Camera target must not be camera position");
    }
    else
    {
        center = GLKVector3Add(eye, GLKMatrix4MultiplyVector3(rotation, GLKVector3Make(0.0f, 0.0f, -1.0f)));
    }
    
    if (_up)
    {
        up = GLKVector3Subtract(eye, _up.worldPosition);
        if (GLKVector3AllEqualToVector3(eye, up)) LogWarning(@"Camera up must not be camera position");
    }
    else
    {
        up = GLKMatrix4MultiplyVector3(rotation, GLKVector3Make(0.0f, -1.0f, 0.0f));
    }
    
    if (_target && _up)
        if (GLKVector3AllEqualToVector3(center, up)) LogWarning(@"Camera target must not be camera up");
    
    GLKMatrix4 lookAtMatrix = GLKMatrix4MakeLookAt(eye.x, eye.y, eye.z,
                                                   center.x, center.y, center.z,
                                                   -up.x, -up.y, -up.z);

    [self updateProjectionMatrix];
    
    _viewMatrix = GLKMatrix4Multiply(_projectionMatrix, lookAtMatrix);
}

@end


@implementation B3DCameraOrtho

- (id) init
{
    return [self initWithNear:B3DCameraOrthoDefaultNear
                          far:B3DCameraOrthoDefaultFar];
}

- (id) initWithNear:(GLfloat)near far:(GLfloat)far
{
    self = [super init];
    if (self)
    {
        _ortho                  = YES;
        _near                   = near;
        _far                    = far;
    }
    
    return self;
}

- (GLKMatrix4) projectionMatrix
{
    [B3DAssert that:(CGRectIsEmpty(_viewport) == NO)
       errorMessage:@"Setting Camera with zero viewport rect!"];

    GLKMatrix4 matrix = GLKMatrix4MakeOrtho(0.0f,
                                            _viewport.size.width,
                                            0.0f,
                                            _viewport.size.height,
                                            _near,
                                            _far);
    
    return matrix;
}

@end
