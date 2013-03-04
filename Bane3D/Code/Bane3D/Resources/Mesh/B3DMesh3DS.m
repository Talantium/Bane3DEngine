//
//  B3DMesh3DS.m
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

#import <OpenGLES/ES2/glext.h>

#import "B3DMesh3DS.h"

#import "B3DAsset+Protected.h"
#import "B3DDatatypes.h"
#import "B3DConstants.h"
#import "B3DVertexBuffer.h"
#import "CB3DMeshLoader3DS.h"



@interface B3DMesh3DS ()
{
    @private
        GLuint                  _vertexArrayObject;
}

@end


@implementation B3DMesh3DS

#pragma mark - Class Methods

+ (B3DMesh3DS*) meshNamed:(NSString*)name
{
	B3DMesh3DS* mesh = [[B3DMesh3DS alloc] initWithMesh:name];
	return mesh;
}

+ (NSString*) extension
{
	return B3DAssetMesh3DSDefaultExtension;
}


#pragma mark - Con-/Destructor

- (id) initWithMesh:(NSString*)name
{
	self = [super initWithMesh:name ofType:B3DAssetMesh3DSDefaultExtension];
	if (self != nil)
	{

    }
	
	return self;
}


#pragma mark - Asset handling

- (BOOL) loadContent
{
	if (_loaded)
	{
		return YES;
	}
	
	BOOL success	= NO;
	
    CB3DMeshLoader3DS* model = new CB3DMeshLoader3DS();
    model->Create([self.path UTF8String]);
    
    // @TODO: ATM only a single mesh is supported per model file, this should be extended.
    uint verticeCount = model->m_pMeshs[0].iNumVerts;
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
                
                // Set the buffer's data
                GLsizei size = sizeof(B3DMeshVertexData);
                unsigned int uiSize = verticeCount * size;
                
                // Create empty buffer, we have to rewrite the data to get it interleaved.
                [_vertexBuffer setData:NULL size:uiSize usage:GL_STATIC_DRAW];
                
                B3DMeshVertexData* vertexBuffer = (B3DMeshVertexData*)glMapBufferOES(GL_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
                for (int i = 0; i < verticeCount; i++)
                {
                    vertexBuffer[i].posX        = model->m_pMeshs[0].pVerts[i].x;
                    vertexBuffer[i].posY        = model->m_pMeshs[0].pVerts[i].y;
                    vertexBuffer[i].posZ        = model->m_pMeshs[0].pVerts[i].z;
                    //            vertexBuffer[i].normX       = 1.0f;
                    //            vertexBuffer[i].normY       = 0.0f;
                    //            vertexBuffer[i].normZ       = 0.0f;
                    vertexBuffer[i].texCoord0U  = model->m_pMeshs[0].pTexs[i].tu * USHRT_MAX;
                    vertexBuffer[i].texCoord0V  = model->m_pMeshs[0].pTexs[i].tv * USHRT_MAX;
                    //            vertexBuffer[i].texCoord1U  = 0;
                    //            vertexBuffer[i].texCoord1V  = 0;
                }
                glUnmapBufferOES(GL_ARRAY_BUFFER);
                
                // Set VAO values
                {
                    glEnableVertexAttribArray(B3DVertexAttributesPosition);
                    glVertexAttribPointer(B3DVertexAttributesPosition, 3, GL_FLOAT, GL_FALSE, size, BUFFER_OFFSET(0));
                    
                    //            glEnableVertexAttribArray(B3DVertexAttributesNormal);
                    //            glVertexAttribPointer(B3DVertexAttributesNormal, 3, GL_FLOAT, GL_FALSE, size, BUFFER_OFFSET(12));
                    
                    glEnableVertexAttribArray(B3DVertexAttributesTexCoord0);
                    glVertexAttribPointer(B3DVertexAttributesTexCoord0, 2, GL_UNSIGNED_SHORT, GL_TRUE, size, BUFFER_OFFSET(12));
                    
                    //            glEnableVertexAttribArray(B3DVertexAttributesTexCoord1);
                    //            glVertexAttribPointer(B3DVertexAttributesTexCoord1, 2, GL_UNSIGNED_SHORT, GL_TRUE, size, BUFFER_OFFSET(28));
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
        

        
        self.vertexIndexLength = model->m_pMeshs[0].iNumIndices;
        
        self.vertexIndexData = [NSData dataWithBytes:model->m_pMeshs[0].pIndices
                                               length:(model->m_pMeshs[0].iNumIndices * sizeof(unsigned short))];
        
        success = YES;
    }

    model->Release();
    delete model;

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
    }
    
    [super cleanUp];
}


@end
