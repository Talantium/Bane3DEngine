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
#import "B3DMesh.h"


@interface B3DTextureFontContainer ()
@end


@implementation B3DTextureFontContainer

- (id) initWithNode:(B3DVisibleNode *)node
{
    self = [super initWithNode:node];
    if (self)
    {
        _capacity               = 1;
        _defaultBufferSize      = sizeof(B3DTextureFontCharSprite) * B3DLabelMaxLabelLength;
        _defaultBufferUsage     = GL_STREAM_DRAW;
    }

    return self;
}

- (void) configureVertexArrayObject
{
    GLsizei size = sizeof(B3DTextureFontCharVertice);

    glEnableVertexAttribArray(B3DVertexAttributesPosition);
    glVertexAttribPointer(B3DVertexAttributesPosition, 3, GL_FLOAT, GL_FALSE, size, BUFFER_OFFSET(0));

    glEnableVertexAttribArray(B3DVertexAttributesTexCoord0);
    glVertexAttribPointer(B3DVertexAttributesTexCoord0, 2, GL_FLOAT, GL_FALSE, size, BUFFER_OFFSET(12));
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
    [shader setBoolValue:YES forUniformNamed:B3DShaderUniformToggleTextureAlphaOnly];

    [material enable];

    // Finally draw
    glDisable(GL_CULL_FACE);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, _vertexCount);
    glEnable(GL_CULL_FACE);

    [material disable];

    glBindVertexArrayOES(0);
}

@end
