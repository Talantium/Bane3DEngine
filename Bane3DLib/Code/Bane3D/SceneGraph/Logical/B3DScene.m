//
//  B3DScene.m
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

#import "B3DScene.h"

#import "Bane3DEngine.h"
#import "B3DInputManager.h"
#import "B3DConstants.h"
#import "B3DCamera.h"
#import "B3DSceneManager.h"
#import "B3DAsset.h"
#import "B3DAssetSet.h"
#import "B3DDefaultMaterial.h"
#import "B3DShaderDefaultBaseColor.h"
#import "B3DShaderDefaultSimpleColor.h"
#import "B3DNode+Protected.h"
#import "B3DTime.h"
#import "B3DAssert.h"


@interface B3DScene ()
{
    @private
        BOOL                        _handleSceneLoadingEvents;
}

@property (nonatomic, readwrite, strong) B3DAssetSet* assetSet;

- (void) registerRecursivelyForTouchHandling:(B3DNode*)node;
- (void) unregisterRecursivelyFromTouchHandling:(B3DNode*)node;

@end


@implementation B3DScene

@dynamic    isLoaded;
@dynamic    sceneManager;

+ (instancetype) sceneWithLayers:(NSArray*)layers
{
    return [[self alloc] initWithLayers:layers];
}


#pragma mark - Con-/Destructor

- (id) initWithLayers:(NSArray*)layers
{
	self = [super init];
	if (self)
	{
		_hidden                     = YES;
        _parentHidden               = NO;
		self.key                    = NSStringFromClass([self class]);
		_handleSceneLoadingEvents   = NO;
		_assetSet                   = [[B3DAssetSet alloc] init];
		_scene                      = self;
        
        [self setLayers:layers];
		
        // Default material and some default shaders that must be present in all
        // scenes and are used by builtin nodes.
        // B3DDefaultMaterial loads B3DShaderDefaultAmbient by default and thus
        // it must not be preloaded or registered as an asset!
        [self registerAssetForUse:[[B3DDefaultMaterial alloc] init]];
//        [self registerAssetForUse:[[[B3DShaderDefaultAmbient alloc] init] autorelease]]; NOT NECESSARY
        [self registerAssetForUse:[[B3DShaderDefaultBaseColor alloc] init]];
        [self registerAssetForUse:[[B3DShaderDefaultSimpleColor alloc] init]];
		[self assetList];
	}
	
	return self;
}

- (BOOL) isLoaded
{
	return [_assetSet isLoaded];
}

- (BOOL) isHidden
{
	return _hidden;
}


#pragma mark - Loading/Asset Management

- (void) assetList
{
	// Override in scene to build up asset set list
}

- (void) registerAssetForUse:(B3DAsset*)asset
{
	[_assetSet addAsset:asset];
}

- (void) assetLoadingDidComplete
{
    [self updateSceneGraphHierarchy];
    
    for (B3DNode* node in _children)
	{
		[node create];
	}
}

// Called after all assets registered for this scene have
// been loaded and initialized.
- (void) didLoad
{
	for (B3DNode* node in _children)
	{
		[node awake];
	}
}

// Called after this scene has become the visible and
// currently rendered scene.
- (void) becameVisible
{
	LogDebug(@"Scene '%@' was made visible", self.key);
	
	for (B3DNode* child in _children)
	{
		[self registerRecursivelyForTouchHandling:child];
	}
	
	_hidden = NO;
}

// Called right after the scene is no more the visible scene
- (void) didBecomeInactive
{
	LogDebug(@"Cleaning up scene '%@'", self.key);
	
	_hidden = YES;
	
	for (B3DNode* child in _children)
	{
		[self unregisterRecursivelyFromTouchHandling:child];
        [child destroy];
	}
}


// This method is used to initialize nodes that are added to 
// scene graph after the scene has been loaded and became visible.
- (void) lazyInitNode:(B3DNode*)node
{
	// Only init if scene is already visible
	if (self.isHidden == NO)
	{
		[node initAssets];
		[self registerRecursivelyForTouchHandling:node];
	}
}

// This methods gets called if a node is removed from scene graph
// while the scene is still visible and loaded and can be used to 
// do required clean up work that would otherwise be called when
// scene receives the didBecomeInactive call.
- (void) lazyCleanUpNode:(B3DNode*)node
{
	// LogDebug(@"Scene: %@ - lazyCleanUpNode: %@", _sceneKey, node);
	if (self.isHidden == NO)
	{
		[self unregisterRecursivelyFromTouchHandling:node];
	}
}

- (void) registerRecursivelyForTouchHandling:(B3DNode*)node
{
	if (node.isUserInteractionEnabled)
	{
		[[B3DInputManager sharedManager] registerForTouchEvents:node];
	}
	
	for (B3DNode* childNode in node.children)
	{
		[self registerRecursivelyForTouchHandling:childNode];
	}
}

- (void) unregisterRecursivelyFromTouchHandling:(B3DNode*)node
{
	if (node.isUserInteractionEnabled)
	{
		[[B3DInputManager sharedManager] unregisterForTouchEvents:node];
	}
	
	for (B3DNode* childNode in node.children)
	{
		[self unregisterRecursivelyFromTouchHandling:childNode];
	}
}


- (void) update
{
    for (B3DLayer* layer in _layers)
	{
        GLKMatrixStackRef matrixStack = GLKMatrixStackCreate(kCFAllocatorDefault);

        B3DSceneGraphInfo info;
        info.matrixStack    = matrixStack;
        info.deltaTime      = [B3DTime deltaTime];
        info.parentHidden   = _hidden;
        
        [layer updateWithSceneGraphInfo:info];
        
        CFRelease(matrixStack);
	}
}

- (void) draw
{
    for (B3DLayer* layer in _layers)
	{
        glClear(GL_DEPTH_BUFFER_BIT);

		[layer draw];        
	}
}

#pragma mark - Scene Management / Scene Loading Delegates

- (B3DSceneManager*) sceneManager
{
    return [Bane3DEngine sceneManager];
}

- (void) sceneLoadingDidFinishSuccessfulForScene:(B3DScene*)scene;
{
	[self.sceneManager setSceneAsVisible:scene];
}

- (void) sceneLoadingDidFailForScene:(B3DScene*)scene;
{
	LogError(@"Scene loading for scene %@ did fail...", scene);
}


#pragma mark - Layer Management

- (void) setLayers:(NSArray*)layers
{
    for (B3DLayer* layer in _layers)
    {
        [self removeChild:layer];
    }
    
    for (B3DLayer* layer in layers)
    {
        [self addChild:layer];
    }
    
    _layers = layers;
}

- (void) addLayer:(B3DLayer*)layer
{
    NSMutableArray* array = [NSMutableArray arrayWithArray:_layers];
    [array addObject:layer];
    [self addChild:layer];
    _layers = [NSArray arrayWithArray:array];
}

- (void) addChild:(B3DNode*)node
{
	[B3DAssert that:([node isKindOfClass:[B3DLayer class]]) errorMessage:@"Can only add B3DLayer objects as direct children of a scene!"];
    
    [super addChild:node];
    
    node.layer = (B3DLayer*)node;
}


#pragma mark - Camera Management

- (void) viewportDidChangeTo:(CGRect)viewport
{
	for (B3DLayer* layer in _layers)
	{
		[layer.camera viewportDidChangeTo:viewport];
	}
    
    [super viewportDidChangeTo:viewport];
}


@end
