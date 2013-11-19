//
//  CB3DMeshLoader3DS.h
//  Bane3D
//
//  Created by Andreas Hanft on 26.07.12.
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
//
/***************************************************************************/
/*                                                                         */
/*               Code for loading 3DS file derived from                    */
/*                            www.xbdev.net                                */
/*                         bkenwright@xbdev.net                            */
/*          http://www.xbdev.net/3dformats/3ds/tut6/index.php              */
/*                                                                         */
/***************************************************************************/


#ifndef B3D_CB3DMESHLOADER3DS_H
#define B3D_CB3DMESHLOADER3DS_H

#include <stdio.h>
#include <vector>


class CB3DMeshLoader3DS
{
public:
    struct stMaterial
    {
        char szName[256];
        struct
        {
            unsigned char r, g, b;
        } Colour;
        char szTextureFile[256];
    };
    
    struct stVert
    {
        float x, y, z;
    };
    
    typedef stVert stVector3;
    
    struct stFace
    {
        // 3 Sides of a triangle make a face.
        unsigned short A, B, C;
        int MaterialID;
    };
    
    struct stTex
    {
        float tu, tv;
    };
    
    struct stMesh
    {
        char            szMeshName[256];
        int             iNumVerts;
        stVert*         pVerts;
        int             iNumFaces;
        unsigned short* pIndices;
        int             iNumIndices;
        stFace*         pFaces;
        stTex*          pTexs;
        
        stMesh()
        {
            iNumVerts  = 0;
            pVerts     = NULL;
            iNumFaces  = 0;
            pFaces     = NULL;
            pIndices  = 0;
            pFaces     = NULL;
            pTexs      = NULL;
        }
    };
    
    
protected:
    struct stChunk
    {
        unsigned short ID;
        unsigned int length;
        unsigned int bytesRead;
    };
    
public:
    CB3DMeshLoader3DS(void);
    ~CB3DMeshLoader3DS(void);
    
    bool Create(const char* szFileName);
    void Release();
    void DisplayRawData();

    
public:
    int                m_iNumMeshs;
    std::vector<stMesh>     m_pMeshs;
    
    int                m_iNumMaterials;
    std::vector<stMaterial> m_pMaterials;
    
protected:
    FILE* m_fp;
    
    void ParseChunk        (stChunk* Chunk);
    void GetMaterialName   (stChunk* Chunk);
    void GetDiffuseColour  (stChunk* Chunk);
    void GetTexFileName    (stChunk* Chunk);
    void GetMeshObjectName (stChunk* Chunk);
    void ReadMeshTexCoords (stChunk* Chunk);
    void ReadMeshVertices  (stChunk* Chunk);
    void ReadMeshFaces     (stChunk* Chunk);
    void ReadMeshMaterials (stChunk* Chunk);
    int GetString          (char* pBuffer);
    void SkipChunk         (stChunk *pChunk);
    void ReadChunk         (stChunk *pChunk);
    
    //    TODO: Calculate normals after loading file if needed
    //    stVector3 Normal(stVert *pV1, stVert *pV2, stVert *pV3);
    //    void CalculateNormals(int nNumVertex,
    //                          stVert *pVertex,
    //                          int nNumFaces,
    //                          unsigned short *pFaces,
    //                          stVert *pNormals);
};

#endif /* defined(B3D_CB3DMESHLOADER3DS_H) */
