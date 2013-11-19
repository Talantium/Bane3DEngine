//
//  B3DAssetSet.h
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

@class B3DNode;
@class B3DAsset;


@interface B3DAssetSet : NSObject

@property (nonatomic, readonly) BOOL        isLoaded;
@property (nonatomic, readonly) NSSet*      allAssets;

// Adding and removing whole sets of assets from another 
// considering assetRetainCount (typically used by main 
// asset set of asset manager)
- (void) addAssets:(B3DAssetSet*)assetSet;
- (void) removeAssets:(B3DAssetSet*)assetSet;

// Simple adding of single assets, used for building an asset
// set of a scene, discarding duplicates and ignoring assetRetainCount.
- (void) addAsset:(B3DAsset*)asset;
- (void) swapAsset:(B3DAsset*)existingAsset withAsset:(B3DAsset*)newAsset;

- (NSSet*) assetsToLoad;
- (B3DAsset*) assetForId:(NSString*)uniqueIdentifier;

@end
