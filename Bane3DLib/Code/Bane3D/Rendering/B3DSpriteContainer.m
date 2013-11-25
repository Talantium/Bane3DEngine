//
//  B3DSpriteContainer.m
//  Bane3DEngine
//
//  Created by Andreas Hanft on 19.11.13.
//  Copyright (c) 2013 talantium.net. All rights reserved.
//

#import <GLKit/GLKit.h>

#import "B3DSpriteContainer.h"

#import "B3DConstants.h"
#import "B3DDatatypes.h"

#import "B3DLayer.h"
#import "B3DVisibleNode.h"
#import "B3DCamera.h"

#import "B3DShader.h"
#import "B3DMaterial.h"


@interface B3DSpriteContainer ()
{
  @private
    GLuint                  _vertexArrayObject;
    GLuint                  _vertexBufferObject;
}

@end


@implementation B3DSpriteContainer

- (id) initWithNode:(B3DVisibleNode *)node
{
    self = [super initWithNode:node];
    if (self)
    {
        self.capacity = 1;
    }
    
    return self;
}


- (void) createBuffers
{
    if (_vertexArrayObject != 0) return;

    // Creating VAO's must be done on the main thread, see
    // http://stackoverflow.com/questions/7125257/can-vertex-array-objects-vaos-be-shared-across-eaglcontexts-in-opengl-es
    
    dispatch_block_t block = ^(void)
    {
        // Create a buffer and array storage to render a single sprite node
        if (_vertexArrayObject == 0)
        {
            // Create and bind a vertex array object.
            glGenVertexArraysOES(1, &_vertexArrayObject);
            glBindVertexArrayOES(_vertexArrayObject);
            
            GLsizei size = sizeof(B3DSpriteVertexData);
            GLsizeiptr bufferSize = size * 4;
            
            // Configure the attributes in the VAO.
            glGenBuffers(1, &_vertexBufferObject);
            glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferObject);
            glBufferData(GL_ARRAY_BUFFER, bufferSize, NULL, GL_STREAM_DRAW);
            
            glEnableVertexAttribArray(B3DVertexAttributesPosition);
            glVertexAttribPointer(B3DVertexAttributesPosition, 3, GL_FLOAT, GL_FALSE, size, BUFFER_OFFSET(0));
            
            glEnableVertexAttribArray(B3DVertexAttributesColor);
            glVertexAttribPointer(B3DVertexAttributesColor, 4, GL_UNSIGNED_BYTE, GL_TRUE, size, BUFFER_OFFSET(12));
            
            glEnableVertexAttribArray(B3DVertexAttributesTexCoord0);
            glVertexAttribPointer(B3DVertexAttributesTexCoord0, 2, GL_UNSIGNED_SHORT, GL_TRUE, size, BUFFER_OFFSET(16));
            
            // Bind back to the default state.
            glBindVertexArrayOES(0);
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
}

- (void) tearDownBuffers
{
    if (_vertexArrayObject != 0)
    {
        glDeleteBuffers(1, &_vertexBufferObject);
        glDeleteVertexArraysOES(1, &_vertexArrayObject);
    }
}


- (void) updateBufferWithNodesInSet:(NSSet*)set
{
    [self.prototypeNode updateVerticeData];

    glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferObject);

    GLsizeiptr size = sizeof(B3DSpriteVertexData) * self.prototypeNode.vertexCount;

    glBufferData(GL_ARRAY_BUFFER, size, NULL, GL_STREAM_DRAW);
    B3DSpriteVertexData* currentElementVertices = (B3DSpriteVertexData*) glMapBufferOES(GL_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
    memcpy(currentElementVertices, self.prototypeNode.vertexData.bytes, size);
    glUnmapBufferOES(GL_ARRAY_BUFFER);

    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

- (void) drawInLayer:(B3DLayer*)layer
{
    glBindVertexArrayOES(_vertexArrayObject);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferObject);

    B3DMaterial* material = self.prototypeNode.material;
    B3DShader* shader = material.shader;
    B3DCamera* camera = layer.camera;
    
    // Create Model-View-Projection-Matrix based on currently used scene camera
    GLKMatrix4 matrix_mvp = GLKMatrix4Multiply(camera.viewMatrix, self.prototypeNode.worldTransform);
    [shader setMatrix4Value:matrix_mvp forUniformNamed:B3DShaderUniformMatrixMVP];
    
    [shader setIntValue:0 forUniformNamed:B3DShaderUniformTextureBase];
    
    [material enable];

//    glDrawElements(GL_TRIANGLES, <#GLsizei count#>, <#GLenum type#>, <#const GLvoid *indices#>)

    glDrawArrays(GL_TRIANGLE_STRIP, 0, self.prototypeNode.vertexCount);
    
    [material disable];
    
    glBindVertexArrayOES(0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}


@end
