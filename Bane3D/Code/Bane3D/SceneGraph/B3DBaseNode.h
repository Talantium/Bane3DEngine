//
//  B3DBaseNode.h
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

#import <GLKit/GLKit.h>
#import <Bane3D/Input/B3DTouchResponder.h>

@class Bane3DEngine;
@class B3DBaseNode;
@class B3DScene;
@class B3DAssetToken;


typedef void (^B3DUpdateLoopBlock)(B3DBaseNode* node, double deltaTime);
typedef void (^B3DAwakeBlock)(B3DBaseNode* node);


@interface B3DBaseNode : NSObject <B3DTouchResponder>

/**
 *
 *	Transformation properties of node
 *
 *	Use position, rotation and scale properties directly to manipulate
 *	the node (in update). Always manipulate them as a whole or use the 
 *  methods for that, otherwise your change might not be visible since
 *  the underlying transformation matrix is cached.
 *
 *	The transform matrix is only intended to be used for drawing the node
 *	and not guaranteed to represent the current and actual transformation
 *	values! For performance reasons it is only updated when the node will
 *	be drawn.
 *
 */
@property (nonatomic, assign, readonly)					GLKMatrix4			transform;
@property (nonatomic, assign, readonly)					GLKMatrix4			absoluteTransform;
@property (nonatomic, assign, readwrite)                GLKVector3			position;
@property (nonatomic, assign, readonly)					GLKVector3			absolutePosition;
@property (nonatomic, assign, readwrite)                GLKVector3			scale;
@property (nonatomic, assign, readonly)					GLKVector3			absoluteScale;
@property (nonatomic, assign, readwrite)                GLKQuaternion       rotation;
@property (nonatomic, assign, readonly)					GLKQuaternion       absoluteRotation;

// Input
@property (nonatomic, assign, readwrite, getter=isReceivingTouchEvents)     BOOL receivesTouchEvents;

// Scene graph
@property (nonatomic, assign, readwrite, getter=isVisible)	BOOL            visible;
@property (nonatomic, weak, readwrite)                  B3DScene*			parentScene;
@property (nonatomic, weak, readwrite)                  B3DBaseNode*		parentNode;
@property (nonatomic, weak, readonly)					NSSet*				children;
@property (nonatomic, weak, readonly)					Bane3DEngine*		engine;


@property (nonatomic, copy, readwrite)                  NSString*			name;

// Blocks
@property (nonatomic, copy, readwrite)                  B3DUpdateLoopBlock  updateLoopBlock;
@property (nonatomic, copy, readwrite)                  B3DAwakeBlock       awakeBlock;


/**
 *	Initialization
 */

// Called right after asset loading of parent scene has finished and connects 
// the now loaded assets with the node, so make sure to call super if you 
// override. Use this to create any additional OpenGL items like VBO's etc.
- (void) create;
// This is called after the parent scene has been loaded, the node created and all
// assets connected. Use it to do additional setup to the node (eg placement based
// on asset size etc.)
- (void) awake;
- (void) awakeWithBlock:(B3DAwakeBlock)awakeBlock;

// Clean up any items initialized in create, destroy buffers etc.
- (void) destroy;

// Called from within awake, you should not call this directly
- (void) initAssets;
// Use this to register assets you want to use
- (void) useAssetWithToken:(B3DAssetToken*)token atKeyPath:(NSString*)keyPath;

/**
 *	Misc
 */

- (void) updateMatrix;
- (void) viewportDidChangeTo:(CGRect)viewport;
- (void) print;

@end


@interface B3DBaseNode (GameLoop)

- (void) update;
- (void) draw;

- (void) updateWithBlock:(B3DUpdateLoopBlock)updateLoopBlock;

@end


@interface B3DBaseNode (SceneGraph)

- (void) addSubNode:(B3DBaseNode*)node;
- (BOOL) removeSubNode:(B3DBaseNode*)node;
- (BOOL) removeFromParentNode;

@end


@interface B3DBaseNode (Manipulation)

/**
 * Translating the node
 */

- (void) setPositionToX:(GLfloat)xPos andY:(GLfloat)yPos andZ:(GLfloat)zPos;
- (void) translateBy:(GLKVector3)translation;
- (void) translateByX:(GLfloat)xTrans andY:(GLfloat)yTrans andZ:(GLfloat)zTrans;

/**
 * Rotating the node (all angles are in degree)
 */

// Sets rotation to given angle
- (void) setRotationToAngleX:(GLfloat)xAngle andY:(GLfloat)yAngle andZ:(GLfloat)zAngle;
- (void) setRotationToAngle:(GLfloat)angle byAxisX:(GLfloat)xAxis andY:(GLfloat)yAxis andZ:(GLfloat)zAxis;

// Rotates by given x-, y- and z-angle, rotations are applied in the order x * y * z.
// If result is not as expected, try one of the rotateByAngle methods below!
- (void) rotateBy:(GLKVector3)rotation;
- (void) rotateByX:(GLfloat)xRot andY:(GLfloat)yRot andZ:(GLfloat)zRot;

// Rotates by given angle around given axis (as vector or components)
- (void) rotateByAngle:(GLfloat)angle aroundX:(GLfloat)xAxis andY:(GLfloat)yAxis andZ:(GLfloat)zAxis;
- (void) rotateByAngle:(GLfloat)angle aroundAxis:(GLKVector3)axisVector;

/**
 * Scaling the node
 */

- (void) setScaleUniform:(GLfloat)unifor_scale;
- (void) setScaleToX:(GLfloat)xScale andY:(GLfloat)yScale andZ:(GLfloat)zScale;

@end
