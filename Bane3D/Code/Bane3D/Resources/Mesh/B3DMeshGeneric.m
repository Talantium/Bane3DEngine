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

#import "B3DAsset+Protected.h"
#import "B3DDatatypes.h"
#import "B3DConstants.h"
#import "B3DVertexBuffer.h"
#import "B3DPoint.h"


@interface B3DMeshGeneric ()
{
  @private
    GLuint                  _vertexArrayObject;
}

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
	if (_loaded)
	{
		return YES;
	}
	
	BOOL success	= NO;
    
    if (self.loadingBlock == nil)
    {
        return NO;
    }
    
    NSArray* points = self.loadingBlock(self.meshName, self.meshFileType);
    
    uint verticeCount = points.count;
    if (verticeCount > 0)
    {
        dispatch_block_t block = ^(void)
        {
            if (_vertexArrayObject == 0)
            {
                // Create and bind a vertex array object.
                glGenVertexArraysOES(1, &_vertexArrayObject);
                glBindVertexArrayOES(_vertexArrayObject);
                
                // Generate the vertex buffer object (VBO)
                [_vertexBuffer loadContent];
                
                // Bind the VBO so we can fill it with data
                [_vertexBuffer enable];
                
                NSAssert(_vertexBuffer != nil, @"No vertex buffer!");
                
                // Set the buffer's data
                GLsizei size = sizeof(B3DMeshVertexData);
                unsigned int uiSize = verticeCount * size;
                
                // Create empty buffer, we have to rewrite the data to get it interleaved.
                [_vertexBuffer setData:NULL size:uiSize usage:GL_STATIC_DRAW];
                
                B3DMeshVertexData* vertexBuffer = (B3DMeshVertexData*)glMapBufferOES(GL_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
                for (NSUInteger i = 0; i < verticeCount; i++)
                {
                    B3DPoint* point = points[i];
                    vertexBuffer[i]             = [point pointAsMeshData];
                }
                glUnmapBufferOES(GL_ARRAY_BUFFER);
                
                // Set VAO values
                {
                    glEnableVertexAttribArray(B3DVertexAttributesPosition);
                    glVertexAttribPointer(B3DVertexAttributesPosition, 3, GL_FLOAT, GL_FALSE, size, BUFFER_OFFSET(0));

                    glEnableVertexAttribArray(B3DVertexAttributesTexCoord0);
                    glVertexAttribPointer(B3DVertexAttributesTexCoord0, 2, GL_UNSIGNED_SHORT, GL_TRUE, size, BUFFER_OFFSET(12));
                }
                // Bind back to the default state.
                glBindVertexArrayOES(0);
                
                [_vertexBuffer disable];
            }
        };
        
        if ([NSThread isMainThread])
        {
            block();
        }
        else
        {
            dispatch_sync(dispatch_get_main_queue(), block);
        }
        
        unsigned short indices[verticeCount];
        
        for (unsigned short i = 0; i < verticeCount; i++)
        {
            indices[i] = i;
        }
        
        self.vertexIndexLength = verticeCount;
        
        self.vertexIndexData = [NSData dataWithBytes:indices
                                              length:(verticeCount * sizeof(unsigned short))];
        
        success = YES;
    }
    
	_loaded = success;
	
	return success;
}

- (void) enable
{
    [super enable];
    
    glBindVertexArrayOES(_vertexArrayObject);
}

- (void) disable
{
    glBindVertexArrayOES(0);
    
    [super disable];
}

- (void) cleanUp
{
    if (_vertexArrayObject != 0)
    {
        glDeleteVertexArraysOES(1, &_vertexArrayObject);
        _vertexArrayObject = 0;
    }
    
    [super cleanUp];
}

@end
