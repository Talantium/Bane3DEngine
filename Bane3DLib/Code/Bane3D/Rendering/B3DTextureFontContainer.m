//
//  B3DTextureFontContainer.m
//  Bane3DEngine
//
//  Created by Andreas Hanft on 26/11/13.
//  Copyright (c) 2013 talantium.net. All rights reserved.
//

#import <GLKit/GLKit.h>

#import "B3DTextureFontContainer.h"

#import "B3DConstants.h"
#import "B3DDatatypes.h"

#import "B3DLayer.h"
#import "B3DVisibleNode.h"
#import "B3DCamera.h"

#import "B3DShader.h"
#import "B3DMaterial.h"
#import "B3DLabel.h"


@interface B3DTextureFontContainer ()
{
  @private
    GLuint                  _vertexArrayObject;
    GLuint                  _vertexBufferObject;
}

@end


@implementation B3DTextureFontContainer

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

            // Configure the attributes in the VAO.
            glGenBuffers(1, &_vertexBufferObject);
            glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferObject);
            glBufferData(GL_ARRAY_BUFFER, sizeof(B3DTextureFontCharSprite) * B3DLabelMaxLabelLength, NULL, GL_STREAM_DRAW);

            GLsizei size = sizeof(B3DTextureFontCharVertice);

            glEnableVertexAttribArray(B3DVertexAttributesPosition);
            glVertexAttribPointer(B3DVertexAttributesPosition, 3, GL_FLOAT, GL_FALSE, size, BUFFER_OFFSET(0));

            glEnableVertexAttribArray(B3DVertexAttributesTexCoord0);
            glVertexAttribPointer(B3DVertexAttributesTexCoord0, 2, GL_FLOAT, GL_FALSE, size, BUFFER_OFFSET(12));

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
    if (_vertexBufferObject != 0)
    {
        glDeleteBuffers(1, &_vertexBufferObject);

        _vertexBufferObject = 0;
    }

    if (_vertexArrayObject != 0)
    {
        glDeleteVertexArraysOES(1, &_vertexArrayObject);

        _vertexArrayObject = 0;
    }
}

- (void) updateBufferWithNodesInSet:(NSSet*)set
{
    [self.prototypeNode updateVerticeData];

    glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferObject);

    GLsizeiptr size = sizeof(B3DTextureFontCharVertice) * self.prototypeNode.vertexCount;

    glBufferData(GL_ARRAY_BUFFER, size, NULL, GL_STREAM_DRAW);
    B3DTextureFontCharVertice* currentElementVertices = (B3DTextureFontCharVertice*) glMapBufferOES(GL_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
    memcpy(currentElementVertices, self.prototypeNode.vertexData.bytes, size);
    glUnmapBufferOES(GL_ARRAY_BUFFER);

    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

- (void) drawInLayer:(B3DLayer*)layer
{
    B3DMaterial* material = self.prototypeNode.material;
    B3DShader* shader = material.shader;
    B3DCamera* camera = layer.camera;

    // Bind the vertex array storage for single sprite rendering
    glBindVertexArrayOES(_vertexArrayObject);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferObject);

    // Create Model-View-Projection-Matrix based on currently used scene camera
    GLKMatrix4 matrix_mvp = GLKMatrix4Multiply(camera.viewMatrix, self.prototypeNode.worldTransform);
    [shader setMatrix4Value:matrix_mvp forUniformNamed:B3DShaderUniformMatrixMVP];
    [shader setIntValue:0 forUniformNamed:B3DShaderUniformTextureBase];
    [shader setBoolValue:YES forUniformNamed:B3DShaderUniformToggleTextureAlphaOnly];

    [material enable];

    // Finally draw
    glDisable(GL_CULL_FACE);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, self.prototypeNode.vertexCount);
    glEnable(GL_CULL_FACE);

    [material disable];

    glBindVertexArrayOES(0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

@end
