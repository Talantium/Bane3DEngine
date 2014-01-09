//
//  B3DMeshContainer.m
//  Bane3DEngine
//
//  Created by Andreas Hanft on 20.12.13.
//  Copyright (c) 2013 talantium.net. All rights reserved.
//

#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/glext.h>

#import "B3DMeshContainer.h"

#import "B3DConstants.h"
#import "B3DDatatypes.h"

#import "B3DLayer.h"
#import "B3DVisibleNode.h"
#import "B3DCamera.h"

#import "B3DShader.h"
#import "B3DMaterial.h"
#import "B3DBaseModelNode.h"
#import "B3DMesh.h"


@interface B3DMeshContainer ()
@end

@implementation B3DMeshContainer

- (id) initWithNode:(B3DVisibleNode *)node
{
    self = [super initWithNode:node];
    if (self)
    {
        _capacity               = 1;
        _defaultBufferUsage     = GL_STATIC_DRAW;
    }

    return self;
}

- (void) configureVertexArrayObject
{
    GLsizei size = sizeof(B3DMeshVertexData);

    glEnableVertexAttribArray(B3DVertexAttributesPosition);
    glVertexAttribPointer(B3DVertexAttributesPosition, 3, GL_FLOAT, GL_FALSE, size, BUFFER_OFFSET(0));

    glEnableVertexAttribArray(B3DVertexAttributesTexCoord0);
    glVertexAttribPointer(B3DVertexAttributesTexCoord0, 2, GL_UNSIGNED_SHORT, GL_TRUE, size, BUFFER_OFFSET(12));
}

- (void) drawInLayer:(B3DLayer*)layer
{
    glBindVertexArrayOES(_vertexArrayObject);

    B3DBaseModelNode* node = (B3DBaseModelNode*)self.prototypeNode;
    
    B3DMaterial* material = node.material;
    B3DShader* shader = material.shader;
    B3DCamera* camera = layer.camera;
    
    // Create Model-View-Projection-Matrix based on currently used scene camera
    GLKMatrix4 matrix_mvp = GLKMatrix4Multiply(camera.viewMatrix, node.worldTransform);
    [shader setMatrix4Value:matrix_mvp forUniformNamed:B3DShaderUniformMatrixMVP];
    
    [shader setIntValue:0 forUniformNamed:B3DShaderUniformTextureBase];
    
    [material enable];
    
    B3DModelRenderer renderer = node.renderer;
    CGFloat lineWidth = node.lineWidth;
    GLenum mode;
    switch (renderer)
    {
        case B3DModelRendererPoint:
            // Draws every vertice as a single point
            mode = GL_POINTS;
            glDisable(GL_CULL_FACE);
            break;
            
        case B3DModelRendererLines:
            // Draws every vertice as lines
            mode = GL_LINES;
            glLineWidth(lineWidth);
            break;
            
        case B3DModelRendererLineStrip:
            // Draws every vertice as lines
            mode = GL_LINE_STRIP;
            glLineWidth(lineWidth);
            break;
            
        case B3DModelRendererLineLoop:
            // Draws every vertice as lines
            mode = GL_LINE_LOOP;
            glLineWidth(lineWidth);
            break;
            
        case B3DModelRendererSolidStrip:
            mode = GL_TRIANGLE_STRIP;
            break;
            
        default:
            // Regular drawing as indexed triangles
            mode = GL_TRIANGLES;
            break;
    }
        
    // Regular drawing as indexed triangles
    glDrawElements(mode, node.mesh.vertexIndexCount, GL_UNSIGNED_SHORT, node.mesh.vertexIndexData.bytes);
    
    [material disable];
    
    switch (renderer)
    {
        case B3DModelRendererPoint:
            glEnable(GL_CULL_FACE);
            break;
            
        default:
            break;
    }
    
    glBindVertexArrayOES(0);
}

@end
