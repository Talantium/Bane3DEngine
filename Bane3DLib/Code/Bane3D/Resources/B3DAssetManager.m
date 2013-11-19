//
//  B3DAssetManager.m
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

#import "B3DAssetManager.h"

#import "Bane3DEngine.h"
#import "NSString+MD5.h"
#import "B3DScene.h"
#import "B3DAsset.h"
#import "B3DAssetSet.h"
#import "B3DAssert.h"
#import "B3DHelper.h"


@interface B3DAssetManager ()
{
    @private
        B3DAssetSet*						_activeAssets;
}

- (void) loadAssetsForScene:(B3DScene*)scene;

@end


@implementation B3DAssetManager


#pragma mark - Con-/Destructor

- (id) init
{
	self = [super init];
	if (self != nil)
	{
		_activeAssets				= [[B3DAssetSet alloc] init];
	}
	
	return self;
}

- (void) dealloc
{
	_activeAssets = nil;
	
}


#pragma mark - Scene/Asset Loading

- (void) loadAssetsForScene:(B3DScene*)scene asynch:(BOOL)asynch
{
	if ([scene isLoaded])
	{
        // Add assets to keep asset retain count balanced
        [_activeAssets addAssets:scene.assetSet];
        
        // Send init messages
        // assetLoadingDidComplete calls create, which is neccessary after a
        // scene has been unloaded (and thus destroy was called on its nodes)
        [scene assetLoadingDidComplete];
        // Don't call did load, cause assets were already loaded
//        [scene didLoad];
        
        // Nothing to do, bail out
		if ([_delegate respondsToSelector:@selector(sceneLoadingDidFinishSuccessfulForScene:)])
		{
			[_delegate sceneLoadingDidFinishSuccessfulForScene:scene];
		}
		self.delegate = nil;
		
		return;
	}
    
    if (asynch)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
        ^{
            [self loadAssetsForScene:scene];
         });
    }
    else
    {
        [self loadAssetsForScene:scene];
    }
}

- (void) loadAssetsForScene:(B3DScene*)scene
{
	// Autoreleasepool in case we go threaded
	@autoreleasepool
    {
        BOOL threaded = ![NSThread isMainThread];
        
        EAGLContext* secondContext = nil;
        if (threaded)
        {
            EAGLContext* mainContext = [[Bane3DEngine entity] context];
            secondContext = [[EAGLContext alloc] initWithAPI:[mainContext API]
                                                  sharegroup:[mainContext sharegroup]];
            
            if (!secondContext || ![EAGLContext setCurrentContext:secondContext])
            {
                LogDebug(@"Creating secondary context for threaded asset loading failed...");
                
                secondContext = nil;
                
                return;
            }
        }
        
        if ([_delegate respondsToSelector:@selector(sceneLoadingDidBeganForScene:)])
        {
            [_delegate sceneLoadingDidBeganForScene:scene];
        }
	
        [_activeAssets addAssets:scene.assetSet];
        NSSet* assets = [_activeAssets assetsToLoad];
        BOOL success = ([assets count] == 0);
	
        int loadedAssetsCount = 0;
        float progress = 0.0f;
	
        for (B3DAsset* asset in assets)
        {
            LogDebug(@"Loading asset %@ ...", asset.name);
            
            success = [asset loadContent];
            if (!success)
            {
                // Something went wrong, cancel loading and send fail message
                LogDebug(@"Asset %@ failed loading, aborting scene load!", asset.name);
                
                break;
            }
            
#if DEBUG
            checkGLError();
#endif
            
            LogDebug(@"Asset %@ did load successfully.", asset.name);
            
            loadedAssetsCount++;
            progress = loadedAssetsCount/(float)([assets count] + 1);
            if ([_delegate respondsToSelector:@selector(sceneLoadingForScene:didAchieveProgress:)])
            {
                [_delegate sceneLoadingForScene:scene didAchieveProgress:progress];
            }
        }
	
        if (success)
        {
            [scene assetLoadingDidComplete];
            
            glFlush();
            
            // Send 1 last progress message, to make sure the delegate receives a 100% message
            if ([_delegate respondsToSelector:@selector(sceneLoadingForScene:didAchieveProgress:)])
            {
                [_delegate sceneLoadingForScene:scene didAchieveProgress:1.0f];
            }
            
            // Send message for further initialisation
//            [scene performSelectorOnMainThread:@selector(didLoad) withObject:nil waitUntilDone:YES];
            [scene didLoad];
            
            if ([_delegate respondsToSelector:@selector(sceneLoadingDidFinishSuccessfulForScene:)])
            {
                [_delegate sceneLoadingDidFinishSuccessfulForScene:scene];
            }
        }
        else
        {
            if ([_delegate respondsToSelector:@selector(sceneLoadingDidFailForScene:)])
            {
                [_delegate sceneLoadingDidFailForScene:scene];
            }
        }
        
        // Delete delegate
        self.delegate = nil;
        
        // Reset texture
        [[B3DGLStateManager sharedManager] readTextureStateFromOpenGL];
        
        // Cleanup
        secondContext = nil;
	}
}

- (void) cleanUpAssetsForScene:(B3DScene*)scene
{
	[_activeAssets removeAssets:scene.assetSet];
}


#pragma mark - Generic Asset Access

- (B3DAsset*) assetForResourceNamed:(NSString*)name ofType:(NSString*)type
{
	NSString* fullPathToResource = [[NSBundle mainBundle] pathForResource:name ofType:type];

	return [self assetForId:[fullPathToResource md5]];
}

- (B3DAsset*) assetForResourceNamed:(NSString*)name ofClass:(Class)assetClass
{
	if ([assetClass respondsToSelector:@selector(extension)])
	{
		NSString* extension = [assetClass extension];
		NSString* fullPathToResource = [[NSBundle mainBundle] pathForResource:name ofType:extension];

		return [self assetForId:[fullPathToResource md5]];
	}
	
	return nil;
}

- (B3DAsset*) assetForId:(NSString*)uniqueIdentifier
{
	B3DAsset* asset = [_activeAssets assetForId:uniqueIdentifier];
    
	[B3DAssert that:(asset != nil)
       errorMessage:@"Requesting nonexistend asset, has it been registered for precaching?"];
	
	return asset;
}


@end
