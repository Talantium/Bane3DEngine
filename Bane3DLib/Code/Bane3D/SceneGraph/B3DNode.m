//
//  B3DNode.m
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

#import "B3DNode.h"

#import "Bane3DEngine.h"
#import "B3DInputManager.h"
#import "B3DScene.h"
#import "B3DColor.h"
#import "B3DAssetManager.h"
#import "B3DAssetToken.h"
#import "B3DAssert.h"
#import "B3DTime.h"
#import "B3DNode+Protected.h"


@interface B3DNode ()
{
  @private
    BOOL					_sceneGraphHierarchyDirty;
    BOOL                    _oldHidden;
    GLfloat                 _oldWorldZPosition;
}

@property (nonatomic, readwrite,   weak) Bane3DEngine*  engine;
@property (nonatomic, readwrite,   weak) B3DNode*        parent;
@property (nonatomic, readwrite, strong) NSArray*       children;

@end


@implementation B3DNode

+ (instancetype) node
{
    return [[self alloc] init];
}


#pragma mark - Con-/Destructor

// Designated initializer
- (id) init
{
	self = [super init];
	if (self)
	{
        _engine             = [Bane3DEngine entity];
        
		// Reset transformation matrix
		_transform          = GLKMatrix4Identity;
		
		_position           = GLKVector3Make(0.0f, 0.0f, 0.0f);
		_scale              = GLKVector3Make(1.0f, 1.0f, 1.0f);
		_rotation           = GLKQuaternionIdentity;
				
		// Properties
        _assetTokens        = [NSMutableDictionary dictionary];
		
		// Hierarchy
        _children           = @[];
        _childrenMutable    = [NSMutableArray array];
	}
	
	return self;
}


#pragma mark - Node Lifecycle

- (void) create
{
    [self initAssets];
	
    for (B3DNode* node in _children)
	{
		[node create];
	}
}

- (void) awake
{
	_transformDirty = YES;
    _sceneGraphHierarchyDirty = YES;
    
    if (_awakeBlock)
    {
        self.awakeBlock(self);
    }
	
	for (B3DNode* node in _children)
	{
		[node awake];
	}
}

- (void) awakeWithBlock:(B3DAwakeBlock)awakeBlock
{
    self.awakeBlock = awakeBlock;
}

- (void) destroy
{
    for (B3DNode* node in _childrenMutable)
	{
		[node destroy];
	}
}


#pragma mark - Asset Handling

- (void) initAssets
{
	// Use this method as a place to get the now readily loaded resources from
    // the asset manager. Every asset has an uniqe ID generated by its (file)name.
    // This is used to identify assets and enable, for example, asset sharing between
    // scenes.
    // Example:
	// self.texture = [[Bane3DEngine assetManager] assetForId:someTextureId];
    
    // Setting assets by their token
    NSArray* assetsSortedByKeyPath = [[_assetTokens allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    for (NSString* keyPath in assetsSortedByKeyPath)
    {
        B3DAssetToken* token = [_assetTokens objectForKey:keyPath];
//        LogDebug(@"Assigning asset %@ to keypath %@", token.uniqueIdentifier, keyPath);
        [self setValue:[[Bane3DEngine assetManager] assetForId:token.uniqueIdentifier]
            forKeyPath:keyPath];
    }
}

- (void) useAssetWithToken:(B3DAssetToken*)token atKeyPath:(NSString*)keyPath
{
    // Actually not needed but set keyPath in token for reference.
    token.keyPath = keyPath;
    [_assetTokens setObject:token forKey:keyPath];
}


#pragma mark - Update/Drawing

- (void) updateSceneGraphHierarchy
{
    _children = [NSArray arrayWithArray:_childrenMutable];
    _sceneGraphHierarchyDirty = NO;
}

- (void) recursivelyUpdateSceneGraphHierarchy
{
    [self updateSceneGraphHierarchy];

    for (B3DNode* node in _children)
	{
		[node recursivelyUpdateSceneGraphHierarchy];
	}
}

- (void) updateWithSceneGraphInfo:(B3DSceneGraphInfo)info
{  
    if (_sceneGraphHierarchyDirty)
    {
        [self updateSceneGraphHierarchy];
        _hasSceneGraphChanges = YES;
    }

    if (_transformDirty)
        [self updateTransform];
    
    GLKMatrixStackRef matrixStack = info.matrixStack;
    GLKMatrixStackPush(matrixStack);
    GLKMatrixStackMultiplyMatrix4(matrixStack, _transform);
    
    _worldTransform = GLKMatrixStackGetMatrix4(matrixStack);
    
    GLKVector4 translation = GLKMatrix4GetColumn(_worldTransform, 3);
    _worldPosition  = GLKVector3Make(translation.x, translation.y, translation.z);

    if (_oldWorldZPosition != _worldPosition.z)
    {
        _oldWorldZPosition = _worldPosition.z;
        _hasSceneGraphChanges = YES;
    }

    _parentHidden = info.parentHidden;
    if (_oldHidden != self.hidden)
    {
        _oldHidden = self.hidden;
        _hasSceneGraphChanges = YES;
    }

    if (_updateLoopBlock)
    {
        self.updateLoopBlock(self, info.deltaTime);
    }

    info.parentHidden = self.isHidden;
    for (B3DNode* node in _children)
    {
        [node updateWithSceneGraphInfo:info];
    }
    info.parentHidden = _parentHidden;
    
    GLKMatrixStackPop(matrixStack);
}

- (void) updateWithBlock:(B3DUpdateLoopBlock)updateLoopBlock
{
    self.updateLoopBlock = updateLoopBlock;
}


#pragma mark - Scene Graph

#pragma mark > Visibility

- (BOOL) isHidden
{
	if (_scene == nil)
	{
		return YES;
	}
	
	return (_hidden || _parentHidden);
}

- (BOOL) hasSceneGraphChanges
{
    return _hasSceneGraphChanges;
}

- (void) sceneGraphChangesWereCommited
{
    _hasSceneGraphChanges = NO;
}

#pragma mark > Sorting

- (NSComparisonResult) compareByZValueDescending:(B3DNode*)otherNode
{
	float selfZ = abs(self.worldPosition.z);
	float otherZ = abs(otherNode.worldPosition.z);
	if (selfZ < otherZ)
	{
		return NSOrderedDescending;
	}
	else if (selfZ > otherZ)
	{
		return NSOrderedAscending;
	}
	else
	{
		return NSOrderedSame;
	}
}

- (NSComparisonResult) compareByZValueAscending:(B3DNode<B3DTouchResponder>*)otherNode
{
	float selfZ = abs(self.worldPosition.z);
	float otherZ = abs(otherNode.worldPosition.z);
	if (selfZ < otherZ)
	{
		return NSOrderedAscending;
	}
	else if (selfZ > otherZ)
	{
		return NSOrderedDescending;
	}
	else
	{
		return NSOrderedSame;
	}
}

#pragma mark > Altering Hierarchy

- (void) addChild:(B3DNode*)node
{
	[B3DAssert that:(node != self) errorMessage:@"Adding Node to self as child!"];
	
    [node removeFromParent];
    
	[_childrenMutable addObject:node];
	node.parent = self;
	node.scene  = _scene;
	node.layer  = _layer;
    
    _sceneGraphHierarchyDirty = YES;
}


- (BOOL) removeChild:(B3DNode*)node
{
	// Is given node a child of this node?
    NSUInteger index = [_childrenMutable indexOfObject:node];
	if (index == NSNotFound)
    {
		return NO;
	}
    else
	{
		node.parent = nil;
		node.scene  = nil;
		node.layer  = nil;
		[_childrenMutable removeObjectAtIndex:index];
        
        _sceneGraphHierarchyDirty = YES;
		
		return YES;
	}
}

- (BOOL) removeFromParent
{
	if (_parent)
	{
		return [_parent removeChild:self];
	}
	
	return NO;
}

- (void) setScene:(B3DScene*)scene
{
	if (_scene)
	{
		[_scene lazyCleanUpNode:self];
	}
	
	if (scene)
	{
		[scene lazyInitNode:self];
	}
	
	_scene = scene;

	for (B3DNode* node in _childrenMutable)
	{
		node.scene = _scene;
	}
}

- (void) setLayer:(B3DLayer*)layer
{
    if (layer == nil)
    {
        [_layer nodeWasRemovedFromSceneGraph:self];
    }
    _layer = layer;
    
    [_layer nodeWasAddedToSceneGraph:self];
    
    for (B3DNode* node in _childrenMutable)
	{
		node.layer = _layer;
	}
}


#pragma mark - Manipulation

- (void) setPosition:(GLKVector3)position
{
    _position = position;
    _transformDirty = YES;
}

- (void) setRotation:(GLKQuaternion)rotation
{
    _rotation = rotation;
    _transformDirty = YES;
}

- (void) setScale:(GLKVector3)scale
{
    _scale = scale;
    _transformDirty = YES;
}

- (GLKVector3) worldScale
{
	if (_parent)
	{
		return GLKVector3Multiply(_parent.worldScale, _scale);
	}
	else
	{
		return _scale;
	}
}

- (GLKQuaternion) worldRotation
{
	if (_parent)
	{
		return GLKQuaternionMultiply(_parent.worldRotation, _rotation);
	}
	else
	{
		return _rotation;
	}
}

- (void) updateTransform
{
    // The order of multiplication is important to ensure
    // correct accumulation of transformations!
    // _transform = ident * pos * rot * scale;
    
    GLKMatrix4 position = GLKMatrix4MakeTranslation(_position.x, _position.y, _position.z);
    GLKMatrix4 rotation = GLKMatrix4Multiply(position, GLKMatrix4MakeWithQuaternion(_rotation));
    _transform          = GLKMatrix4Multiply(rotation, GLKMatrix4MakeScale(_scale.x, _scale.y, _scale.z));
    
    _transformDirty     = NO;
}

- (void) setPositionToX:(GLfloat)xPos y:(GLfloat)yPos z:(GLfloat)zPos
{
	_position = GLKVector3Make(xPos, yPos, zPos);
    _transformDirty = YES;
}

- (void) translateBy:(GLKVector3)translation
{
	_position = GLKVector3Add(_position, translation);
    _transformDirty = YES;
}

- (void) translateByX:(GLfloat)xTrans y:(GLfloat)yTrans z:(GLfloat)zTrans
{
	_position = GLKVector3Add(_position, GLKVector3Make(xTrans, yTrans, zTrans));
    _transformDirty = YES;
}

- (void) setRotationToAngleX:(GLfloat)xAngle y:(GLfloat)yAngle z:(GLfloat)zAngle
{
    GLKQuaternion quadRot = GLKQuaternionIdentity;
    if (xAngle != 0.0f)
    {
        quadRot = GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(xAngle), 1.0f, 0.0f, 0.0f);
    }
    
    if (yAngle != 0.0f)
    {
        quadRot = GLKQuaternionMultiply(quadRot, GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(yAngle), 0.0f, 1.0f, 0.0f));
    }
    
    if (zAngle != 0.0f)
    {
        quadRot = GLKQuaternionMultiply(quadRot, GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(zAngle), 0.0f, 0.0f, 1.0f));
    }
    
    _rotation = quadRot;    
    _transformDirty = YES;
}

- (void) setRotationToAngle:(GLfloat)angle byAxisX:(GLfloat)xAxis y:(GLfloat)yAxis z:(GLfloat)zAxis
{
    _rotation = GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(angle), xAxis, yAxis, zAxis);
    _transformDirty = YES;
}

- (void) rotateBy:(GLKVector3)rotation
{
	[self rotateByX:rotation.x y:rotation.y z:rotation.z];
}

// Expects euler angles
- (void) rotateByX:(GLfloat)xRot y:(GLfloat)yRot z:(GLfloat)zRot
{
    if (xRot != 0.0f)
    {
        _rotation = GLKQuaternionMultiply(_rotation, GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(xRot), 1.0f, 0.0f, 0.0f));
    }
    
    if (yRot != 0.0f)
    {
        _rotation = GLKQuaternionMultiply(_rotation, GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(yRot), 0.0f, 1.0f, 0.0f));
    }
    
    if (zRot != 0.0f)
    {
        _rotation = GLKQuaternionMultiply(_rotation, GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(zRot), 0.0f, 0.0f, 1.0f));
    }
    
    _transformDirty = YES;
}

- (void) rotateByAngle:(GLfloat)angle aroundX:(GLfloat)xAxis y:(GLfloat)yAxis z:(GLfloat)zAxis
{
    _rotation = GLKQuaternionMultiply(_rotation, GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(angle), xAxis, yAxis, zAxis));
    _transformDirty = YES;
}

- (void) rotateByAngle:(GLfloat)angle aroundAxis:(GLKVector3)axisVector
{
    [self rotateByAngle:angle aroundX:axisVector.v[0] y:axisVector.v[1] z:axisVector.v[2]];
}

- (void) setScaleUniform:(GLfloat)uniformScale
{
    _scale = GLKVector3Make(uniformScale, uniformScale, uniformScale);
    _transformDirty = YES;
}

- (void) setScaleToX:(GLfloat)xScale y:(GLfloat)yScale z:(GLfloat)zScale
{
    _scale = GLKVector3Make(xScale, yScale, zScale);
    _transformDirty = YES;
}


#pragma mark - Touch

- (void) setUserInteractionEnabled:(BOOL)userInteractionEnabled
{
	_userInteractionEnabled = userInteractionEnabled;
	
	// If we change reveiving state while we are in a scene graph
	// an the scene is also visible, we directly communicate with
	// the input manager and (un)register us.
	// All other cases are handled by the scene itself we are connected
	// to when it becomes visible/unloaded or when we connect during
	// runtime.
	if (_scene && _scene.isHidden == NO)
	{
		if (_userInteractionEnabled)
		{
			[[B3DInputManager sharedManager] registerForTouchEvents:self];
		}
		else
		{
			[[B3DInputManager sharedManager] unregisterForTouchEvents:self];
		}		
	}
}


#pragma mark - Misc

- (void) viewportDidChangeTo:(CGRect)viewport
{
	for (B3DNode* node in _childrenMutable)
	{
		[node viewportDidChangeTo:viewport];
	}
}

- (void) print
{
	B3DNode* parent = self.parent;
	NSMutableString* depth = [[NSMutableString alloc] initWithString:@""];
	while (parent)
	{
		[depth appendString:@"\t"];
		parent = parent.parent;
	}
	
	LogDebug(@"%@%@%@", depth, ([depth length] > 0 ? @"|-> " : @""), [self description]);
	
	for (B3DNode* node in self.children)
	{
		[node print];
	}
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"%@ @ {%.2f, %.2f, %.2f} {%.2f, %.2f, %.2f}", (_name ? _name : @"Node"), _position.x, _position.y, _position.z, self.worldPosition.x, self.worldPosition.y, self.worldPosition.z];
}


@end
