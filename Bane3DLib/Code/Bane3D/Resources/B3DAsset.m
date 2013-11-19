//
//  B3DAsset.m
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

#import "B3DAsset.h"

#import "B3DConstants.h"
#import "B3DAssetToken.h"
#import "NSString+MD5.h"
#import "NSString+Utils.h"


@interface B3DAsset ()

@property (nonatomic, readwrite, copy)   NSString*          name;
@property (nonatomic, readwrite, copy)   NSString*          path;
@property (nonatomic, readwrite, copy)   NSString*          uID;
@property (nonatomic, readwrite, weak)   NSString*          internalType;
@property (nonatomic, readwrite, assign, getter=isLoaded)   BOOL loaded;
@property (nonatomic, readwrite, assign) GLuint             openGlName;
@property (nonatomic, readwrite, assign) uint               assetRetainCount;

@property (nonatomic, readwrite, weak)   B3DGLStateManager* stateManager;

- (NSString*) createNameForResource:(NSString*)resource ofType:(NSString*)type;
- (void) unloadContent;

@end


@implementation B3DAsset

#pragma mark - Class Methods

+ (NSString*) extension
{
	return @"";
}

+ (B3DAssetToken*) token
{
    B3DAssetToken* token = [[B3DAssetToken alloc] init];
    token.uniqueIdentifier = [B3DAssetToken uniqueIdForAsset:NSStringFromClass([self class])
                                               withExtension:[[self class] extension]
                                                      ofType:B3DAssetTypeVolatile];
    
    return token;
}

+ (B3DAssetToken*) tokenWithName:(NSString*)name
{
    // Override in subclasses to provide a suitable and convenient implementation!
    
    B3DAssetToken* token = [[B3DAssetToken alloc] init];
    token.uniqueIdentifier = [B3DAssetToken uniqueIdForAsset:name withExtension:nil];
    
    return token;
}


#pragma mark - Custom Properties

@synthesize uID					= _uniqueIdentifier;


#pragma mark - Initialization

- (id) initWithResourceNamed:(NSString*)fileName ofType:(NSString*)fileType
{
	return [self initWithResource:fileName ofType:fileType];
}

- (id) initWithResourceAtUrl:(NSString*)ressouceUrl
{
	return [self initWithResource:ressouceUrl ofType:B3DAssetTypeRemote];
}

- (id) initWithVolatileResourceNamed:(NSString*)name
{
	return [self initWithResource:name ofType:B3DAssetTypeVolatile];
}

// Designated initializer
- (id) initWithResource:(NSString*)resource ofType:(NSString*)type
{
	self = [super init];
	if (self != nil)
	{
        self.stateManager           = [B3DGLStateManager sharedManager];

        if (type == B3DAssetTypeVolatile)
        {
            // Volatile resources are generated and/or do not have a physical 
            // representation. 'resource' only contains the name of the asset 
            // to identify it. Thus _path must be nil!
            
            self.internalType   = type;
            self.path           = nil;
        }
        else if (type == B3DAssetTypeRemote)
        {
            // Remote assets are downloaded from an URL. 'resource' contains 
            // the whole url including the filename and extension.
            
            self.internalType   = type;
            self.path           = resource;
        }
        else
        {
            // Regularily we expect a name and a filetype for an asset. 'resource' 
            // contains the file name excluding extension, 'type' the file
            // extension without dot.

            self.internalType = B3DAssetTypeLocal;
            self.path = [[NSBundle mainBundle] pathForResource:resource ofType:type];
            if (_path == nil)
            {
                LogError(@"Resource %@ not found, could not load asset!", resource);
                
                return nil;
            }
        }
        
        NSString* extension = (_internalType == B3DAssetTypeLocal ? type : [[self class] extension]);
        self.uID = [B3DAssetToken uniqueIdForAsset:resource
                                     withExtension:extension
                                            ofType:_internalType];

        self.name               = [self createNameForResource:resource ofType:type];
		self.loaded             = NO;
		self.assetRetainCount   = 0;
        self.openGlName         = 0;
	}
	
	return self;
}

- (void) enable
{}

- (void) disable
{}

- (BOOL) loadContent
{
	if (_loaded)
	{
		return YES;
	}
	
	// Override and return message of success, set isLoaded accordingly
	
	return NO;
}

- (void) unloadContent
{
	if (!_loaded)
	{
		return;
	}
}

- (void) cleanUp
{}


- (void) assetRetain
{
	_assetRetainCount++;
}

- (void) assetRelease
{
	_assetRetainCount--;
	if (_assetRetainCount <= 0)
	{
		_assetRetainCount = 0;
		[self unloadContent];
	}
}


- (NSString*) createNameForResource:(NSString*)resource ofType:(NSString*)type
{
    NSString* name = nil;
    
    if (type == B3DAssetTypeVolatile)
    {
        // Create name from resource name and typical extension
        NSString* extension = [[self class] extension];
        name = [NSString stringWithFormat:@"%@%@%@",
                resource,
                ([extension isEmptyOrWhitespace] ? @"" : @"::"),
                extension];
    }
    else
    {
        if (type == B3DAssetTypeRemote)
        {
            // 'resource' contains an URL
            name = [resource lastPathComponent];
        }
        else
        {
            // For an asset of type B3DAssetTypeLocal the type var contains
            // the actual file extension.
            name = [NSString stringWithFormat:@"%@%@%@",
                    resource,
                    ([type isEmptyOrWhitespace] ? @"" : @"."),
                    type];
        }
    }
    
    return name;
}


#pragma mark - Copying

- (id) copyWithZone:(NSZone*)zone
{
    B3DAsset* copy = [[[self class] allocWithZone:zone] init];
    
    copy.name               = _name;
    copy.path               = _path;
    copy.uID                = _uniqueIdentifier;
    copy.internalType       = _internalType;
    copy.loaded             = _loaded;
    copy.openGlName         = _openGlName;
    copy.assetRetainCount   = _assetRetainCount;
    copy.stateManager       = _stateManager;
    
    return copy;
}


@end
