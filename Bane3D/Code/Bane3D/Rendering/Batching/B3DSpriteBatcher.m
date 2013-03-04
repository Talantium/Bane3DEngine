//
//  B3DSpriteBatcher.m
//  Bane3D
//
//  Created by Andreas Hanft on 09.12.11.
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

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "B3DSpriteBatcher.h"

#import "B3DGLStateManager.h"
#import "B3DDatatypes.h"
#import "B3DConstants.h"
#import "B3DSprite.h"
#import "B3DScene.h"
#import "B3DMaterial.h"
#import "B3DCamera.h"
#import "B3DShader.h"


@interface B3DSpriteBatcher ()
{
    @private
        GLuint                  _spriteBatchArrayObject[BUFFER_COUNT];
        GLuint                  _spriteBatchVertexBufferObject[BUFFER_COUNT];
        
        int                     _currentBuffer;
        
        B3DGLStateManager*      _stateManager;
}

@end


@implementation B3DSpriteBatcher

#pragma mark - Con-/Destructor

- (id) init
{
    self = [super init];
    if (self)
    {
        _stateManager               = [B3DGLStateManager sharedManager];
    }
    
    return self;
}

- (void) dealloc
{
    [self tearDownBuffers];
        
}


#pragma mark - Buffer Handling

- (void) createBuffers
{
    // Create a buffer and array storage to render a number of batched sprite nodes
    for (int i = 0; i < BUFFER_COUNT; i++)
    {
        int size = sizeof(B3DSpriteVertexData);
        
        glGenVertexArraysOES(1, &_spriteBatchArrayObject[i]);
        glBindVertexArrayOES(_spriteBatchArrayObject[i]);
        
        glGenBuffers(1, &_spriteBatchVertexBufferObject[i]);
        glBindBuffer(GL_ARRAY_BUFFER, _spriteBatchVertexBufferObject[i]);
        glBufferData(GL_ARRAY_BUFFER, size * B3DSpriteBatcherMaxVertices, NULL, GL_STREAM_DRAW);// GL_DYNAMIC_DRAW);
        
        glEnableVertexAttribArray(B3DVertexAttributesPosition);
        glVertexAttribPointer(B3DVertexAttributesPosition, 3, GL_FLOAT, GL_FALSE, size, BUFFER_OFFSET(0));
        
//        glEnableVertexAttribArray(B3DVertexAttributesNormal);
//        glVertexAttribPointer(B3DVertexAttributesNormal, 3, GL_FLOAT, GL_FALSE, size, BUFFER_OFFSET(12));
        
        glEnableVertexAttribArray(B3DVertexAttributesColor);
        glVertexAttribPointer(B3DVertexAttributesColor, 4, GL_UNSIGNED_BYTE, GL_TRUE, size, BUFFER_OFFSET(12));
        
        glEnableVertexAttribArray(B3DVertexAttributesTexCoord0);
        glVertexAttribPointer(B3DVertexAttributesTexCoord0, 2, GL_UNSIGNED_SHORT, GL_TRUE, size, BUFFER_OFFSET(16));
        
//        glEnableVertexAttribArray(B3DVertexAttributesTexCoord1);
//        glVertexAttribPointer(B3DVertexAttributesTexCoord1, 2, GL_UNSIGNED_SHORT, GL_TRUE, size, BUFFER_OFFSET(32));
        
        glBindVertexArrayOES(0);
        
        //NSLog(@"%lu %lu %lu %lu %lu ", sizeof(GLfloat), sizeof(GLshort), sizeof(GLubyte), sizeof(B3DSpriteVertexData), sizeof(B3DSpriteVertexData) * B3DSpriteBatcherMaxVertices);
        // Output 4 2 1 36 360000
        
        /*B3DSpriteVertexData data;
         data.posX = 0.0f;
         data.posY = 0.0f;
         data.posZ = 0.0f;
         
         data.normX = 0.0f;
         data.normY = 0.0f;
         data.normZ = -1.0f;
         
         data.colR = 255;
         data.colG = 0;
         data.colB = 255;
         data.colA = 56;
         
         data.texCoord0U = 0;
         data.texCoord0V = 0;
         data.texCoord1U = 255;
         data.texCoord1V = 255;
         
         
         for (int i = 0; i < 10; i += 1)
         {
         data.posX = gStrideTestData[(i*3)];
         data.posY = gStrideTestData[(i*3)+1];
         data.posZ = gStrideTestData[(i*3)+2];
         
         glBufferSubData(GL_ARRAY_BUFFER, sizeof(B3DSpriteVertexData) * i, sizeof(B3DSpriteVertexData), &data);
         }*/
    }
}

- (void) tearDownBuffers
{
    for (int i = 0; i < BUFFER_COUNT; i++)
    {
        glDeleteBuffers(1, &_spriteBatchVertexBufferObject[i]);
        glDeleteVertexArraysOES(1, &_spriteBatchArrayObject[i]);
    }
}


#pragma mark - Batched Rendering


- (void) renderSpriteArray:(NSArray*)sprites
{
    if (sprites.count <= 0)
    {
        return;
    }
    
    _currentBuffer = (_currentBuffer + 1) % BUFFER_COUNT;
    
    // We expect all batchable nodes to be sprites with the same texture and material
    B3DSprite* sprite = [sprites objectAtIndex:0];
    
    // Optimize access to some properties
    static B3DTexture* texture = nil;
    texture = sprite.material.texture;
    static B3DShader* shader = nil;
    shader = sprite.material.shader;
    
    // Bind the vertex array storage for single sprite rendering
    glBindVertexArrayOES(_spriteBatchArrayObject[_currentBuffer]);
    glBindBuffer(GL_ARRAY_BUFFER, _spriteBatchVertexBufferObject[_currentBuffer]);
        
    
    if (sprite.useOrtho)
    {
        [sprite.parentScene useOrthoCamera];
    }
    
    // Create Model-View-Projection-Matrix based on currently used scene camera
    [shader setMatrix4Value:sprite.parentScene.mainCamera.viewMatrix forUniformNamed:B3DShaderUniformMatrixMVP];
    [shader setIntValue:0 forUniformNamed:B3DShaderUniformTextureBase];
    
    [sprite.material enable];

    uint count = 0;
    uint totalCount = sprites.count;
    int verticeCount = 0;
    uint currentElementVerticeCount = 0;
    // static B3DSpriteVertexData currentElementVertices[6];
//    static B3DSpriteVertexData currentElementVertices[10000];
    // static B3DSpriteVertexData* currentElementVertices = B3DVertexData[B3DSpriteBatcherMaxVertices];
    
        
    glBufferData(GL_ARRAY_BUFFER, sizeof(B3DSpriteVertexData) * B3DSpriteBatcherMaxVertices, NULL, GL_STREAM_DRAW);// GL_DYNAMIC_DRAW);
//    GLvoid* dataArray 
    B3DSpriteVertexData* currentElementVertices = (B3DSpriteVertexData*) glMapBufferOES(GL_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
    
    for (B3DSprite* currentSprite in sprites)
    {   
        B3DSpriteVertexData* vertices = [currentSprite updateVerticeData];
        GLKMatrix4 transform = currentSprite.absoluteTransform;
        for (int i = 0; i < 4; i++)
        {
            GLKVector4 posMultiplied = GLKMatrix4MultiplyVector4(transform, 
                                                                 GLKVector4Make(vertices[i].posX, 
                                                                                vertices[i].posY,
                                                                                vertices[i].posZ,
                                                                                1.0f));
            vertices[i].posX = posMultiplied.x;
            vertices[i].posY = posMultiplied.y;
            vertices[i].posZ = posMultiplied.z;
        }
        
        currentElementVerticeCount = 0;
        
        // Double first vertice except for first element
        if (count != 0)
        {
            currentElementVertices[verticeCount + currentElementVerticeCount++] = vertices[0];
//            currentElementVertices[currentElementVerticeCount++] = vertices[0];
        }
        
        currentElementVertices[verticeCount + currentElementVerticeCount++] = vertices[0];
        currentElementVertices[verticeCount + currentElementVerticeCount++] = vertices[1];
        currentElementVertices[verticeCount + currentElementVerticeCount++] = vertices[2];
        currentElementVertices[verticeCount + currentElementVerticeCount++] = vertices[3];
//        currentElementVertices[currentElementVerticeCount++] = vertices[0];
//        currentElementVertices[currentElementVerticeCount++] = vertices[1];
//        currentElementVertices[currentElementVerticeCount++] = vertices[2];
//        currentElementVertices[currentElementVerticeCount++] = vertices[3];
        
        // Double last vertice except for last element
        if (count != (totalCount - 1))
        {
            currentElementVertices[verticeCount + currentElementVerticeCount++] = vertices[3];
//            currentElementVertices[currentElementVerticeCount++] = vertices[3];
        }
        
        // @TODO: Test performance ON THE DEVICE when batching with a big vertice array and a single 
        // glBufferSubData call and a small array and numerous glBufferSubData calls!
        
        // Transmit the data of the current sprite to the buffer
//        static int size = sizeof(B3DSpriteVertexData);
//        glBufferSubData(GL_ARRAY_BUFFER, size * verticeCount, size * currentElementVerticeCount, currentElementVertices);

        verticeCount += currentElementVerticeCount;
        count += 1;
        
        if (verticeCount > (B3DSpriteBatcherMaxVertices - 6))
        {
            LogDebug(@"[WARNING] Max vertices for single batch reached!");
            break;
        }
    }
    
    glUnmapBufferOES(GL_ARRAY_BUFFER);

    
    /*
    for (int i = 0; i < verticeCount; i++)
    {
        B3DSpriteVertexData data = currentElementVertices[i];
        LogEcho(@"Vertice Print (%i): pos(%f, %f, %f) norm(%f, %f, %f) col(%u, %u, %u, %u) uv0(%u, %u) uv1(%u, %u)", 
                (i+1),
                data.posX,
                data.posY,
                data.posZ,
                
                data.normX,
                data.normY,
                data.normZ,
                
                data.colR,
                data.colG,
                data.colB,
                data.colA,
                
                data.texCoord0U,
                data.texCoord0V,
                data.texCoord1U,
                data.texCoord1V);
    }
     */
    
    // Transmit the data of all sprites to the buffer
//    glBufferData(GL_ARRAY_BUFFER, sizeof(B3DSpriteVertexData) * B3DSpriteBatcherMaxVertices, NULL, GL_STREAM_DRAW);// GL_DYNAMIC_DRAW);
//    glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(B3DSpriteVertexData) * verticeCount, currentElementVertices);
    
    // Finally draw
    glDrawArrays(GL_TRIANGLE_STRIP, 0, verticeCount);//GL_POINTS
    
    [sprite.material disable];
    
    if (sprite.useOrtho)
    {
        [sprite.parentScene usePerspectiveCamera];
    }
    

#if DEBUG_PRINT_STATS_BATCHING
    //LogEcho(@"[INFO] [SpriteBatcher] Batched and rendered %i nodes with renderID %i (total of %i vertices)", sprites.count, sprite.material.renderID, verticeCount);
#endif
}

@end
