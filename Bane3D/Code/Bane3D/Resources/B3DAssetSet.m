//
//  B3DAssetSet.m
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

#import "B3DAssetSet.h"

#import "B3DBaseNode.h"
#import "B3DAsset.h"


@interface B3DAssetSet ()
{
    @private
        NSMutableSet*				_assets;
}

- (B3DAsset*) assetEqualTo:(B3DAsset*)newAsset;

@end


@implementation B3DAssetSet

@dynamic isLoaded;
@dynamic allAssets;


#pragma mark - Con-/Destructor

- (id) init
{
	self = [super init];
	if (self != nil)
	{
		_assets = [[NSMutableSet alloc] init];
	}
	
	return self;
}



- (B3DAsset*) assetEqualTo:(B3DAsset*)newAsset
{
	B3DAsset* existing = nil;
	for (B3DAsset* asset in _assets)
	{
		if ([asset.uID isEqualToString:newAsset.uID])
		{
			existing = asset;
			break;
		}
	}
	
	return existing;
}

- (void) addAssets:(B3DAssetSet*)assetSet
{
	// Add assets to set, discard duplicates and increase retain count instead
	B3DAsset* existing = nil;
	for (B3DAsset* asset in assetSet.allAssets)
	{
		// This only tests if assets point to same resource by hash compare!
		existing = [self assetEqualTo:asset];
		if (existing)
		{
			[existing assetRetain];
			// We have to make sure hash-identical objects are exchanged so
			// everywhere is used the same object.
			[assetSet swapAsset:asset withAsset:existing];
		}
		else
		{
			[asset assetRetain];
			[_assets addObject:asset];
		}
	}
}

- (void) removeAssets:(B3DAssetSet*)assetSet
{
	// Remove assets from set, they unload themselves when their assetRetainCount reaches 0
	B3DAsset* existing = nil;
	for (B3DAsset* asset in assetSet.allAssets)
	{
		existing = [self assetEqualTo:asset];
		if (existing)
		{
			[existing assetRelease];
			if (existing.assetRetainCount == 0)
			{
				[_assets removeObject:existing];
			}
		}
	}
}

- (void) swapAsset:(B3DAsset*)existingAsset withAsset:(B3DAsset*)newAsset
{
	if (existingAsset != newAsset)
	{
		[_assets addObject:newAsset];
		[_assets removeObject:existingAsset];
	}
}

- (void) addAsset:(B3DAsset*)newAsset
{
	for (B3DAsset* asset in _assets)
	{
		if ([asset.uID isEqualToString:newAsset.uID])
		{
			return;
		}
	}
	
	[_assets addObject:newAsset];
}

- (NSSet*) assetsToLoad
{
	// Get set from all active assets that are not yet loaded
	NSMutableSet* assetsToLoad = [NSMutableSet set];
	
	for (B3DAsset* asset in _assets)
	{
		if (![asset isLoaded])
		{
			[assetsToLoad addObject:asset];
		}
	}
	
	return [NSSet setWithSet:assetsToLoad];
}

- (BOOL) isLoaded
{
	// If no assets are registered, we are loaded
	BOOL allLoaded = (_assets.count == 0);
	
	for (B3DAsset* asset in _assets)
	{
		allLoaded = [asset isLoaded];
		if (!allLoaded)
		{
			break;
		}
	}
	
	return allLoaded;
}

- (NSSet*) allAssets
{
	return [NSSet setWithSet:_assets];
}

- (B3DAsset*) assetForId:(NSString*)uniqueIdentifier
{
	B3DAsset* match = nil;
	for (B3DAsset* asset in _assets)
	{
		if ([asset.uID isEqualToString:uniqueIdentifier])
		{
			match = asset;
			break;
		}
	}
	
	return match;
}


@end
