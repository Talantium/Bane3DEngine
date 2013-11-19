//
//  B3DSpriteContainer.h
//  Bane3DEngine
//
//  Created by Andreas Hanft on 19.11.13.
//  Copyright (c) 2013 talantium.net. All rights reserved.
//

#import <Bane3D/Rendering/B3DRenderContainer.h>
#import <OpenGLES/ES2/gl.h>


// A Sprite is considered a 2D element with four or more corners, often used for HUD elements.
// As such, normals and a second tex coord array are not relevant, but specifying
// the color of single elements might be. Sprites might get batched together to
// improve performance.
typedef struct
{
    GLfloat     posX;           // 4 Bytes
    GLfloat     posY;           // 4 Bytes
    GLfloat     posZ;           // 4 Bytes
    
    GLubyte     colR;           // 1 Byte
    GLubyte     colG;           // 1 Byte
    GLubyte     colB;           // 1 Byte
    GLubyte     colA;           // 1 Byte
    
    GLushort     texCoord0U;    // 2 Bytes
    GLushort     texCoord0V;    // 2 Bytes
} B3DSpriteVertexData;


@interface B3DSpriteContainer : B3DRenderContainer

@end
