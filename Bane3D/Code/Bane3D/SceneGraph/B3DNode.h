//
//  B3DNode.h
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
@class B3DNode;
@class B3DScene;
@class B3DAssetToken;


typedef void (^B3DUpdateLoopBlock)(B3DNode* node, double deltaTime);
typedef void (^B3DAwakeBlock)(B3DNode* node);


@interface B3DNode : NSObject <B3DTouchResponder>

+ (instancetype) node;

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
@property (nonatomic, readwrite, assign) GLKMatrix4     transform;
@property (nonatomic, readwrite, assign) GLKVector3     position;
@property (nonatomic, readwrite, assign) GLKVector3     scale;
@property (nonatomic, readwrite, assign) GLKQuaternion  rotation;

@property (nonatomic, readonly,  assign) GLKMatrix4     worldTransform;
@property (nonatomic, readwrite, assign) GLKVector3     worldPosition;
@property (nonatomic, readonly,  assign) GLKVector3     worldScale;
@property (nonatomic, readonly,  assign) GLKQuaternion  worldRotation;

// Input
@property (nonatomic, readwrite, assign, getter=isUserInteractionEnabled) BOOL userInteractionEnabled;

// Scene graph
@property (nonatomic, readwrite, assign, getter=isHidden) BOOL hidden;
@property (nonatomic, readwrite,  weak) B3DScene*       scene;
@property (nonatomic, readonly,   weak) B3DNode*        parent;
@property (nonatomic, readonly, strong) NSArray*        children;

@property (nonatomic, readwrite,  copy) NSString*       name;
@property (nonatomic, readonly,   weak) Bane3DEngine*   engine;

// Blocks
@property (nonatomic, readwrite,  copy) B3DUpdateLoopBlock updateLoopBlock;
@property (nonatomic, readwrite,  copy) B3DAwakeBlock   awakeBlock;


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

// Clean up any items initialized in create, eg. destroy buffers etc.
- (void) destroy;

// Called from within create, should not be called directly
- (void) initAssets;

// Use this to register assets you want to use
- (void) useAssetWithToken:(B3DAssetToken*)token atKeyPath:(NSString*)keyPath;

/**
 *	Misc
 */

- (void) updateTransform;
- (void) viewportDidChangeTo:(CGRect)viewport;
- (void) print;

@end


@interface B3DNode (GameLoop)

- (void) updateWithBlock:(B3DUpdateLoopBlock)updateLoopBlock;

@end


@interface B3DNode (SceneGraph)

- (void) addChild:(B3DNode*)node;
- (BOOL) removeChild:(B3DNode*)node;
- (BOOL) removeFromParent;

- (NSComparisonResult) compareByZValueDescending:(B3DNode*)otherNode;
- (NSComparisonResult) compareByZValueAscending:(B3DNode<B3DTouchResponder>*)otherNode;

@end


@interface B3DNode (Manipulation)

/**
 * Translating the node
 */

- (void) setPositionToX:(GLfloat)xPos y:(GLfloat)yPos z:(GLfloat)zPos;
- (void) translateBy:(GLKVector3)translation;
- (void) translateByX:(GLfloat)xTrans y:(GLfloat)yTrans z:(GLfloat)zTrans;

/**
 * Rotating the node (all angles are in degree)
 */

// Sets rotation to given angle
- (void) setRotationToAngleX:(GLfloat)xAngle y:(GLfloat)yAngle z:(GLfloat)zAngle;
- (void) setRotationToAngle:(GLfloat)angle byAxisX:(GLfloat)xAxis y:(GLfloat)yAxis z:(GLfloat)zAxis;

// Rotates by given x-, y- and z-angle, rotations are applied in the order x * y * z.
// If result is not as expected, try one of the rotateByAngle methods below!
- (void) rotateBy:(GLKVector3)rotation;
- (void) rotateByX:(GLfloat)xRot y:(GLfloat)yRot z:(GLfloat)zRot;

// Rotates by given angle around given axis (as vector or components)
- (void) rotateByAngle:(GLfloat)angle aroundX:(GLfloat)xAxis y:(GLfloat)yAxis z:(GLfloat)zAxis;
- (void) rotateByAngle:(GLfloat)angle aroundAxis:(GLKVector3)axisVector;

/**
 * Scaling the node
 */

- (void) setScaleUniform:(GLfloat)uniformScale;
- (void) setScaleToX:(GLfloat)xScale y:(GLfloat)yScale z:(GLfloat)zScale;

@end
