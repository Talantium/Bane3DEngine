//
//  B3DCamera.h
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

#import <Bane3D/SceneGraph/B3DBaseNode.h>


@interface B3DCamera : B3DBaseNode

@property (nonatomic, readonly) GLKMatrix4      viewMatrix;
@property (nonatomic, readonly) CGRect          viewport;
@property (nonatomic, assign)   GLfloat         near;
@property (nonatomic, assign)   GLfloat         far;
@property (nonatomic, assign)   GLfloat         fov;
@property (nonatomic, assign, getter = isOrtho) BOOL ortho;

- (id) initAsOrtho:(BOOL)ortho;
- (id) initAsOrtho:(BOOL)ortho withNear:(GLfloat)near andFar:(GLfloat)far andFov:(GLfloat)fov;

@end
