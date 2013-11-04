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


@interface B3DScene ()
{
    @private
        NSMutableDictionary*        _mutableCameras;
        BOOL                        _handleSceneLoadingEvents;
}

@property (nonatomic, strong, readwrite) B3DAssetSet*        assets;

- (void) registerRecursivelyForTouchHandling:(B3DNode*)node;
- (void) unregisterRecursivelyFromTouchHandling:(B3DNode*)node;

@end


@implementation B3DScene

@dynamic    defaultPerspectiveCamera;
@dynamic    defaultOrthoCamera;
@dynamic    cameras;
@dynamic    isLoaded;
@dynamic    sceneManager;


#pragma mark - Con-/Destructor

- (id) init
{
	self = [super init];
	if (self)
	{
		_hidden                     = YES;
		self.key                    = NSStringFromClass([self class]);
		_handleSceneLoadingEvents   = NO;
		self.assets                 = [[B3DAssetSet alloc] init];
		_scene                      = self;
        
        // Create default scene cameras
        _mutableCameras = [[NSMutableDictionary alloc] init];
        {
            // First camera for regular perspective drawing
            B3DCamera* camera = [[B3DCameraPerspective alloc] init];
            {
                // Also set this camera as the default main camera
                _mainCamera = camera;
            }
            [self addCamera:camera forKey:B3DSceneCameraDefaultPerspectiveKey];
        
            // Default camera setup for ortho drawing (usually GUI and 
            // other 2D sprites etc.)
            camera = [[B3DCameraOrtho alloc] init];
            [self addCamera:camera forKey:B3DSceneCameraDefaultOrthoKey];
        }
		
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
	return [_assets isLoaded];
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
	[_assets addAsset:asset];
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
    GLKMatrixStackRef matrixStack = GLKMatrixStackCreate(kCFAllocatorDefault);
    
    B3DSceneGraphInfo info;
    info.matrixStack    = matrixStack;
    info.deltaTime      = [B3DTime deltaTime];
    
    [self updateWithSceneGraphInfo:info];
    CFRelease(matrixStack);
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


#pragma mark - Camera Management

- (NSDictionary*) cameras
{
    return [[NSDictionary alloc] initWithDictionary:_mutableCameras];
}

- (B3DCamera*) defaultPerspectiveCamera
{
    return [_mutableCameras objectForKey:B3DSceneCameraDefaultPerspectiveKey];
}

- (B3DCamera*) defaultOrthoCamera
{
    return [_mutableCameras objectForKey:B3DSceneCameraDefaultOrthoKey];
}

- (void) addCamera:(B3DCamera*)camera forKey:(NSString*)key
{
    [_mutableCameras setObject:camera forKey:key];
    [self addChild:camera];
}

- (void) removeCameraWithKey:(NSString*)key
{
    B3DCamera* camera = [_mutableCameras objectForKey:key];
    if (camera)
    {
        [_mutableCameras removeObjectForKey:key];
        [self removeChild:camera];
    }
}

- (BOOL) useCameraWithKey:(NSString*)key
{
    B3DCamera* camera = [_mutableCameras objectForKey:key];
    if (camera && _mainCamera != camera)
    {
        _mainCamera = camera;
        
        return YES;
    }
    
    return NO;
}

- (void) usePerspectiveCamera
{
    [self useCameraWithKey:B3DSceneCameraDefaultPerspectiveKey];
}

- (void) useOrthoCamera
{
    [self useCameraWithKey:B3DSceneCameraDefaultOrthoKey];
}

- (void) viewportDidChangeTo:(CGRect)viewport
{
	for (B3DCamera* camera in [_mutableCameras allValues])
	{
		[camera viewportDidChangeTo:viewport];
	}
    
    [super viewportDidChangeTo:viewport];
}


@end
