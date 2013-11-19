//
//  B3DSceneManager.h
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

#import <Bane3D/Resources/B3DSceneLoadingDelegate.h>

@class B3DScene;
@class B3DAssetManager;


@interface B3DSceneManager : NSObject <B3DSceneLoadingDelegate>

@property (nonatomic, strong, readonly) B3DAssetManager*    assetManager;
@property (nonatomic, strong, readonly) NSArray*            scenes;
@property (nonatomic, weak, readonly)   B3DScene*           currentScene;

// Managing scenes
- (void) setRootScene:(B3DScene*)rootScene;
- (B3DScene*) rootScene;

- (void) addScene:(B3DScene*)scene;
- (void) addScene:(B3DScene*)scene forKey:(NSString*)sceneKey;
- (B3DScene*) sceneForKey:(NSString*)sceneKey;
- (void) deleteSceneForKey:(NSString*)sceneKey;
- (void) deleteScene:(B3DScene*)scene;

// Loading scenes
// A scene must be preloaded before making it visible!
// Loading usually happens asynchronously and can be observed by current scene
// (eg. to show a progress bar...). 
- (void) loadRootScene;
- (void) loadSceneWithKey:(NSString*)sceneKey; // Defaults to asynch = YES
- (void) loadSceneWithKey:(NSString*)sceneKey asynch:(BOOL)asynch;
- (void) loadScene:(B3DScene*)scene; // Defaults to asynch = YES
- (void) loadScene:(B3DScene*)scene asynch:(BOOL)asynch;

// Sets scene visible but only after it was preloaded!
// Is either called automatically after loading a scene if no delegate 
// was set or manually eg. by pressing a button in current scene.
- (void) setSceneAsVisible:(B3DScene*)scene;

@end
