//
//  B3DScene.h
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

#import <Bane3D/SceneGraph/B3DBaseNode.h>
#import <Bane3D/Resources/B3DSceneLoadingDelegate.h>

@class B3DSceneManager;
@class B3DAssetSet;
@class B3DCamera;
@class B3DAsset;


@interface B3DScene : B3DBaseNode <B3DSceneLoadingDelegate>

// Holds a reference to the currently used camera of the scene
@property (nonatomic, weak, readonly)   B3DCamera*          mainCamera;
@property (nonatomic, weak, readonly)   NSDictionary*       cameras;

@property (nonatomic, weak, readonly)   B3DCamera*          defaultPerspectiveCamera;
@property (nonatomic, weak, readonly)   B3DCamera*          defaultOrthoCamera;

@property (nonatomic, weak, readonly)   B3DSceneManager*    sceneManager; //!< Convenience accessor
@property (nonatomic, assign, getter = isHandlingSceneLoadingEvents) BOOL handleSceneLoadingEvents;
@property (nonatomic, assign, readonly) BOOL                isLoaded;
@property (nonatomic, strong, readonly) B3DAssetSet*        assets;
@property (nonatomic, copy, readwrite)  NSString*           key;

- (void) assetLoadingDidComplete;
// Called by asset manager after initial loading of scene assets is complete
- (void) didLoad;
// Called by scene manager after scene has become the visible scene
- (void) becameVisible;
// Called by scene manager when the scene has been visible and was replaced by another one
- (void) didBecomeInactive;

- (void) assetList; //!< Override in subclasses to build up asset set list
- (void) registerAssetForUse:(B3DAsset*)asset;
- (void) lazyInitNode:(B3DBaseNode*)node;
- (void) lazyCleanUpNode:(B3DBaseNode*)node;

@end


@interface B3DScene (Cameras)

- (void) addCamera:(B3DCamera*)camera forKey:(NSString*)key;
- (void) removeCameraWithKey:(NSString*)key;
- (BOOL) useCameraWithKey:(NSString*)key;
- (void) usePerspectiveCamera;
- (void) useOrthoCamera;

@end