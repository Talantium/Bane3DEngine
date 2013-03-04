//
//  B3DAsset.h
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

#import <OpenGLES/ES2/gl.h>
#import <Bane3D/Rendering/B3DGLStateManager.h>

@class B3DAssetToken;


@interface B3DAsset : NSObject <NSCopying>

@property (nonatomic, readonly, copy)   NSString*           name;
@property (nonatomic, readonly, copy)   NSString*           path;
@property (nonatomic, readonly, copy)   NSString*           uID;
@property (nonatomic, readonly, weak)   NSString*           internalType;
@property (nonatomic, readonly, assign, getter=isLoaded) BOOL loaded;
@property (nonatomic, readonly, assign) GLuint              openGlName;
@property (nonatomic, readonly, assign) uint                assetRetainCount;

@property (nonatomic, readonly, weak)   B3DGLStateManager*  stateManager;


// Returns typical extension for asset, eg. 'png', 'caff', ...
+ (NSString*) extension;


// Initialization
- (id) initWithResourceNamed:(NSString*)fileName ofType:(NSString*)fileType;
- (id) initWithResourceAtUrl:(NSString*)ressouceUrl;
- (id) initWithVolatileResourceNamed:(NSString*)name;
// Designated init, type contains either the file type or if not applicable the internal asset type
- (id) initWithResource:(NSString*)resource ofType:(NSString*)type;

@end


@interface B3DAsset (OpenGLSupport)

// Use these to set/unset OpenGL states of assets (eg texture, shader etc.)
- (void) enable;    // Use to set OpenGL state, eg bind texture
- (void) disable;   // Use to reset OpenGL state, eg unbind buffer

@end


@interface B3DAsset (B3DAssetManagement)

// Load/Unloading asset
- (BOOL) loadContent;       // Called when asset is requested to be used in current scene
- (void) unloadContent;     // Called when asset is no longer in use in current scene
- (void) cleanUp;           // Called from unloadcontent, to bind cleanup code of asset at one place

// Internal retain count for optimized asset usage
- (void) assetRetain;
- (void) assetRelease;

@end


@interface B3DAsset (B3DAssetTokenSupport)

// Some predefined convenience accessors to be overridden by concrete subclasses!
// Eg. [MyPrettyShader token];
+ (B3DAssetToken*) token;
+ (B3DAssetToken*) tokenWithName:(NSString*)name;

@end
