//
//  B3DMeshContainer.h
//  Bane3DEngine
//
//  Created by Andreas Hanft on 20.12.13.
//  Copyright (c) 2013 talantium.net. All rights reserved.
//

#import <Bane3D/Rendering/B3DRenderContainer.h>
#import <OpenGLES/ES2/gl.h>


// A Mesh is the basic data structure of any 3D models in the virtual world. As
// lighting might be important, normals are also provided. Color values are provided
// per mesh as uniforms. Two texture coord arrays give the possibility of using
// a lightmap texture or other effects.
typedef struct
{
    GLfloat     posX;           // 4 Bytes
    GLfloat     posY;           // 4 Bytes
    GLfloat     posZ;           // 4 Bytes
    
    GLushort    texCoord0U;     // 2 Bytes
    GLushort    texCoord0V;     // 2 Bytes
} B3DMeshVertexData;

typedef struct
{
    GLfloat     posX;           // 4 Bytes
    GLfloat     posY;           // 4 Bytes
    GLfloat     posZ;           // 4 Bytes
    
    GLfloat     normX;          // 4 Bytes
    GLfloat     normY;          // 4 Bytes
    GLfloat     normZ;          // 4 Bytes
    
    GLushort    texCoord0U;     // 2 Bytes
    GLushort    texCoord0V;     // 2 Bytes
    GLushort    texCoord1U;     // 2 Bytes
    GLushort    texCoord1V;     // 2 Bytes
} B3DMeshVertexDataExtended;


@interface B3DMeshContainer : B3DRenderContainer

@end
