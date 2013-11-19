//
//  B3DAssetToken.m
//  Bane3D
//
//  Created by Andreas Hanft on 14.04.11.
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

#import "B3DAssetToken.h"

#import "B3DConstants.h"
#import "NSString+MD5.h"


@implementation B3DAssetToken

#pragma mark - Class Methods

+ (NSString*) uniqueIdForAsset:(NSString*)asset withExtension:(NSString*)extension
{
    return [B3DAssetToken uniqueIdForAsset:asset withExtension:extension ofType:B3DAssetTypeLocal];
}

+ (NSString*) uniqueIdForAsset:(NSString*)asset withExtension:(NSString*)extension ofType:(NSString*)type
{
    NSString* uID = nil;
    
    if (type == B3DAssetTypeVolatile)
    {
        // Volatile resources are generated and/or do not have a physical 
        // representation.
        // We have no path so create hash from name and (if available) typical 
        // extension.
        
        uID = [NSString stringWithFormat:@"%@::%@::%@",
               B3DAssetTypeVolatile,
               asset,
               extension];
        
    }
    else if (type == B3DAssetTypeRemote)
    {
        // Remote assets are downloaded and referenced by a complete URL
        // Use it to create hash!
        
        uID = asset;
    }
    else
    {
        // Every other resource is considered to be found in the local file 
        // system. For these we use the current path as base for hash.
        
        uID = [[NSBundle mainBundle] pathForResource:asset ofType:extension];
    }
    
    return [uID md5];
}

@end
