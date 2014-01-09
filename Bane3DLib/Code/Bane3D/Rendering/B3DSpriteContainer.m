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
#import "B3DMesh.h"


@implementation B3DSpriteContainer

- (id) initWithNode:(B3DVisibleNode *)node
{
    self = [super initWithNode:node];
    if (self)
    {
        _capacity               = 1;
        _defaultBufferSize      = sizeof(B3DSpriteVertexData) * 4;
        _defaultBufferUsage     = GL_STREAM_DRAW;
    }
    
    return self;
}

- (void) configureVertexArrayObject
{
    GLsizei size = sizeof(B3DSpriteVertexData);

    glEnableVertexAttribArray(B3DVertexAttributesPosition);
    glVertexAttribPointer(B3DVertexAttributesPosition, 3, GL_FLOAT, GL_FALSE, size, BUFFER_OFFSET(0));

    glEnableVertexAttribArray(B3DVertexAttributesColor);
    glVertexAttribPointer(B3DVertexAttributesColor, 4, GL_UNSIGNED_BYTE, GL_TRUE, size, BUFFER_OFFSET(12));

    glEnableVertexAttribArray(B3DVertexAttributesTexCoord0);
    glVertexAttribPointer(B3DVertexAttributesTexCoord0, 2, GL_UNSIGNED_SHORT, GL_TRUE, size, BUFFER_OFFSET(16));
}

- (void) drawInLayer:(B3DLayer*)layer
{
    glBindVertexArrayOES(_vertexArrayObject);

    B3DMaterial* material = self.prototypeNode.material;
    B3DShader* shader = material.shader;
    B3DCamera* camera = layer.camera;
    
    // Create Model-View-Projection-Matrix based on currently used scene camera
    GLKMatrix4 matrix_mvp = GLKMatrix4Multiply(camera.viewMatrix, self.prototypeNode.worldTransform);
    [shader setMatrix4Value:matrix_mvp forUniformNamed:B3DShaderUniformMatrixMVP];
    
    [shader setIntValue:0 forUniformNamed:B3DShaderUniformTextureBase];
    
    [material enable];

    glDrawArrays(GL_TRIANGLE_STRIP, 0, _vertexCount);

    [material disable];
    
    glBindVertexArrayOES(0);
}


@end
