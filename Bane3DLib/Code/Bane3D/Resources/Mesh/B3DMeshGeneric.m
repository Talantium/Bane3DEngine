//
//  B3DMeshGeneric.m
//  Bane3D
//
//  Created by Andreas Hanft on 03.10.13.
//
//
//  Copyright (C) 2013 Andreas Hanft (talantium.net)
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

#import <OpenGLES/ES2/glext.h>

#import "B3DMeshGeneric.h"

#import "B3DMeshContainer.h"
#import "B3DAsset+Protected.h"
#import "B3DDatatypes.h"
#import "B3DConstants.h"
#import "B3DVertexBuffer.h"
#import "B3DPoint.h"


@interface B3DMeshGeneric ()

@property (nonatomic, readwrite, copy) NSString* meshName;
@property (nonatomic, readwrite, copy) NSString* meshFileType;
@property (nonatomic, readwrite, copy) B3DMeshLoadingBlock loadingBlock;

@end


@implementation B3DMeshGeneric

- (id) initWithMesh:(NSString*)name ofType:(NSString*)type
{
	self = [super initWithMesh:name ofType:type];
	if (self != nil)
	{
        _meshName = name;
        _meshFileType = type;
	}
	
	return self;
}

#pragma mark - Asset handling

- (void) loadContentWithBlock:(B3DMeshLoadingBlock)loadBlock
{
    self.loadingBlock = loadBlock ;
}

- (BOOL) loadContent
{
	if (_loaded) return YES;
	   
    if (_loadingBlock == nil) return NO;
    
    BOOL success = NO;

    NSArray* points = self.loadingBlock(self.meshName, self.meshFileType);
    NSUInteger verticeCount = points.count;
    if (verticeCount > 0)
    {
        // Set the buffer's data
        GLsizei size = sizeof(B3DMeshVertexData);
        NSInteger uiSize = verticeCount * size;
        
        B3DMeshVertexData* vertexBuffer = (B3DMeshVertexData*) malloc(uiSize);
        for (NSUInteger i = 0; i < verticeCount; i++)
        {
            B3DPoint* point = points[i];
            vertexBuffer[i]             = [point pointAsMeshData];
        }
        
        self.vertexCount = verticeCount;
        self.vertexData = [NSData dataWithBytesNoCopy:vertexBuffer length:uiSize freeWhenDone:YES];
        
        unsigned short indices[verticeCount];
        for (unsigned short i = 0; i < verticeCount; i++)
        {
            indices[i] = i;
        }
        
        self.vertexIndexCount = verticeCount;
        
        self.vertexIndexData = [NSData dataWithBytes:indices
                                              length:(verticeCount * sizeof(unsigned short))];
        
        success = YES;
        self.dirty = YES;
    }
    
	_loaded = success;
	
	return success;
}

@end
