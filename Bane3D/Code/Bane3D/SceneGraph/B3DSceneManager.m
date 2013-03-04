//
//  B3DSceneManager.m
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

#import "B3DSceneManager.h"

#import "B3DConstants.h"
#import "B3DScene.h"
#import "B3DAssetManager.h"
#import "B3DAssert.h"


@interface B3DSceneManager ()
{
    @private
        B3DAssetManager*			_assetManager;
        NSMutableDictionary*		_scenes;
        B3DScene*					__weak _currentScene;
}

@end


@implementation B3DSceneManager

@dynamic    scenes;


#pragma mark - Con-/Destructor

- (id) init
{
	self = [super init];
	if (self)
	{
		_scenes			= [[NSMutableDictionary alloc] init];
		_assetManager	= [[B3DAssetManager alloc] init];
	}
	
	return self;
}


#pragma mark - Scene management

- (NSArray*) scenes
{
    return [_scenes allValues];
}

- (void) setRootScene:(B3DScene*)rootScene
{
    [self addScene:rootScene forKey:B3DSceneManagerRootSceneKey];
}

- (B3DScene*) rootScene
{
    return [self sceneForKey:B3DSceneManagerRootSceneKey];
}

- (void) addScene:(B3DScene*)scene
{
    NSString* key = scene.key;
    if (key == nil)
    {
        key = NSStringFromClass([scene class]);
    }
    
    [self addScene:scene forKey:key];
}

- (void) addScene:(B3DScene*)scene forKey:(NSString*)sceneKey
{
	[B3DAssert that:([_scenes objectForKey:sceneKey] == nil)
	errorMessage:@"Adding scene with key already in use. Delete scene in advance if this is intended!"];
	
	LogDebug(@"[INFO] Scene added for key: %@", sceneKey);
	
	[_scenes setObject:scene forKey:sceneKey];
	scene.key = sceneKey;
}

- (B3DScene*) sceneForKey:(NSString*)sceneKey
{
	return [_scenes objectForKey:sceneKey];
}

- (void) deleteSceneForKey:(NSString*)sceneKey
{
	[_scenes removeObjectForKey:sceneKey];
}

- (void) deleteScene:(B3DScene*)scene
{
	for (NSString* sceneKey in [_scenes allKeysForObject:scene])
	{
		[_scenes removeObjectForKey:sceneKey];
	}
}

- (void) loadRootScene
{
    [self loadSceneWithKey:B3DSceneManagerRootSceneKey asynch:NO];
}

- (void) loadSceneWithKey:(NSString*)sceneKey
{
	[self loadScene:[self sceneForKey:sceneKey] asynch:YES];
}

- (void) loadSceneWithKey:(NSString*)sceneKey asynch:(BOOL)asynch
{
	[self loadScene:[self sceneForKey:sceneKey] asynch:asynch];
}

- (void) loadScene:(B3DScene*)scene
{
    [self loadScene:scene asynch:YES];
}

- (void) loadScene:(B3DScene*)scene asynch:(BOOL)asynch
{
    [B3DAssert that:(scene != nil) errorMessage:@"Trying to load nil scene!"];
    
	LogDebug(@"Load scene: %@ asynch: %@", scene.key, (asynch ? @"YES" : @"NO"));
	
	// If scene doesn't care about loading events, we handle 
	// scene switching etc. our self.
	if ([_currentScene isHandlingSceneLoadingEvents])
	{
		_assetManager.delegate = _currentScene;
	}
	else
	{
		_assetManager.delegate = self;
	}
	
	[_assetManager loadAssetsForScene:scene
                               asynch:asynch];
}

- (void) setSceneAsVisible:(B3DScene*)scene
{
	[B3DAssert that:([scene isLoaded])
       errorMessage:@"You must load all assets of a scene prior making it visible! Rather use 'loadScene:' and the according delegates to do so!"];
	
	LogDebug(@"Setting scene visible: %@", scene.key);
	
	B3DScene* oldScene = _currentScene;
	_currentScene = scene;
	// Send message for further initialisation
	[_currentScene becameVisible];
    
	[oldScene didBecomeInactive];
	[_assetManager cleanUpAssetsForScene:oldScene];
}

- (void) sceneLoadingDidFinishSuccessfulForScene:(B3DScene*)scene;
{
	LogDebug(@"Loading successful for scene: %@", scene.key);
	[self setSceneAsVisible:scene];
}

- (void) sceneLoadingForScene:(B3DScene *)scene didAchieveProgress:(float)progress
{
	LogDebug(@"Progress for scene %@: %i%%", scene.key, (int)(100.0f * progress));
}

- (void) sceneLoadingDidFailForScene:(B3DScene*)scene;
{
	// Error message...
	LogDebug(@"Scene loading failed for scene: %@", scene.key);
}

@end
