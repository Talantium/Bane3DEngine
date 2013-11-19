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

#import <Bane3D/SceneGraph/B3DNode.h>
#import <Bane3D/Resources/B3DSceneLoadingDelegate.h>

@class B3DLayer;
@class B3DSceneManager;
@class B3DAssetSet;
@class B3DCamera;
@class B3DAsset;


@interface B3DScene : B3DNode <B3DSceneLoadingDelegate>

+ (instancetype) sceneWithLayers:(NSArray*)layers;

@property (nonatomic, readwrite, strong) NSArray* layers;

- (id) initWithLayers:(NSArray*)layers;
- (void) addLayer:(B3DLayer*)layer;


@property (nonatomic, readonly,  weak)   B3DSceneManager*    sceneManager; //!< Convenience accessor
@property (nonatomic, readwrite, assign, getter = isHandlingSceneLoadingEvents) BOOL handleSceneLoadingEvents;
@property (nonatomic, readonly,  assign) BOOL                isLoaded;
@property (nonatomic, readonly,  strong) B3DAssetSet*        assetSet;
@property (nonatomic, readwrite, copy)   NSString*           key;

- (void) assetLoadingDidComplete;
// Called by asset manager after initial loading of scene assets is complete
- (void) didLoad;
// Called by scene manager after scene has become the visible scene
- (void) becameVisible;
// Called by scene manager when the scene has been visible and was replaced by another one
- (void) didBecomeInactive;

- (void) update;
- (void) draw;

- (void) assetList; //!< Override and create the list of assets used in the scene by calling -registerAssetForUse:
- (void) registerAssetForUse:(B3DAsset*)asset;
- (void) lazyInitNode:(B3DNode*)node;
- (void) lazyCleanUpNode:(B3DNode*)node;

@end
