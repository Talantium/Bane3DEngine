//
//  CB3DMeshLoader3DS.cpp
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


#include "CB3DMeshLoader3DS.h"

#include <iostream>

using namespace std;



//>----- Entry point (Primary Chunk at the start of the file ----------------
#define           PRIMARY           0x4D4D

//>----- Main Chunks --------------------------------------------------------
#define           EDIT3DS           0x3D3D  // Start of our actual objects
#define           KEYF3DS           0xB000  // Start of the keyframe information

//>----- General Chunks -----------------------------------------------------
#define           VERSION           0x0002
#define           MESH_VERSION      0x3D3E
#define           KFVERSION         0x0005
#define           COLOR_F           0x0010
#define           COLOR_24          0x0011
#define           LIN_COLOR_24      0x0012
#define           LIN_COLOR_F       0x0013
#define           INT_PERCENTAGE    0x0030
#define           FLOAT_PERC        0x0031
#define           MASTER_SCALE      0x0100
#define           IMAGE_FILE        0x1100
#define           AMBIENT_LIGHT     0X2100

//>----- Object Chunks -----------------------------------------------------
#define           NAMED_OBJECT      0x4000
#define           OBJ_MESH          0x4100
#define           MESH_VERTICES     0x4110
#define           VERTEX_FLAGS      0x4111
#define           MESH_FACES        0x4120
#define           MESH_MATER        0x4130
#define           MESH_TEX_VERT     0x4140
#define           MESH_XFMATRIX     0x4160
#define           MESH_COLOR_IND    0x4165
#define           MESH_TEX_INFO     0x4170
#define           HEIRARCHY         0x4F00


//>----- Material Chunks ---------------------------------------------------
#define           MATERIAL          0xAFFF
#define           MAT_NAME          0xA000
#define           MAT_AMBIENT       0xA010
#define           MAT_DIFFUSE       0xA020
#define           MAT_SPECULAR      0xA030
#define           MAT_SHININESS     0xA040
#define           MAT_FALLOFF       0xA052
#define           MAT_EMISSIVE      0xA080
#define           MAT_SHADER        0xA100
#define           MAT_TEXMAP        0xA200
#define           MAT_TEXFLNM       0xA300

#define           OBJ_LIGHT         0x4600
#define           OBJ_CAMERA        0x4700

//>----- KeyFrames Chunks --------------------------------------------------
#define           ANIM_HEADER       0xB00A
#define           ANIM_OBJ          0xB002

#define           ANIM_NAME         0xB010
#define           ANIM_POS          0xB020
#define           ANIM_ROT          0xB021
#define           ANIM_SCALE        0xB022




CB3DMeshLoader3DS::CB3DMeshLoader3DS(void)
{
    m_iNumMeshs     = 0;
    m_iNumMaterials = 0;
}

CB3DMeshLoader3DS::~CB3DMeshLoader3DS(void)
{}


/***************************************************************************/
/*                                                                         */
/* Some user functions to make the reading of the .3ds file easier         */
/*                                                                         */
/***************************************************************************/
/* Helper Functions that make our parsing of the chunks easier             */
/***************************************************************************/


void CB3DMeshLoader3DS::ReadChunk(stChunk *pChunk)
{
    unsigned short ID             = 0;
    unsigned int bytesRead        = 0;
    unsigned int bChunkLength     = 0;
    
    bytesRead = (unsigned int)fread(&ID, 1, 2, m_fp);
    
    bytesRead += (unsigned int)fread(&bChunkLength, 1, 4, m_fp);
    
    pChunk->ID          = ID;
    pChunk->length      = bChunkLength;
    pChunk->bytesRead = bytesRead;
}

void CB3DMeshLoader3DS::SkipChunk(stChunk *pChunk)
{
    int buffer[50000] = {0};
    
    fread(buffer, 1, pChunk->length - pChunk->bytesRead, m_fp);
}

/***************************************************************************/
/*                                                                         */
/* Helper Fuction, simply reads in the string from the file pointer, until */
/* a null is reached, then returns how many bytes was read.                */
/*                                                                         */
/***************************************************************************/
int CB3DMeshLoader3DS::GetString(char* pBuffer)
{
    int index = 0;
    
    char buffer[100] = {0};
    
    fread(buffer, 1, 1, m_fp);
    
    while( *(buffer + index++) != 0)
    {
        fread(buffer + index, 1, 1, m_fp);
    }
    
    strcpy( pBuffer, buffer );
    
    return (int)(strlen(buffer) + 1);
}

/***************************************************************************/
/*                                                                         */
/* This little function reads the matrial data for our individual object,  */
/* So it determines which face references which material, in our material  */
/* list.                                                                   */
/*                                                                         */
/***************************************************************************/
void CB3DMeshLoader3DS::ReadMeshMaterials(stChunk* Chunk)
{
    // Material Name Where Referencing
    char str[256];
    unsigned int characterlen = GetString(str);
    Chunk->bytesRead += characterlen;
    
    unsigned short iNumFaces = 0;
    Chunk->bytesRead += (unsigned int)fread(&iNumFaces, 1, 2, m_fp);
    
    unsigned short *FaceAssignedThisMaterial = new unsigned short[iNumFaces];
    Chunk->bytesRead += (unsigned int)fread(FaceAssignedThisMaterial, 1,
                                            iNumFaces*sizeof(unsigned short), m_fp);
    
    // Determine Which Material It Is In Our List
    int MaterialID = 0;
    for( int cc=0; cc<m_iNumMaterials; cc++)
    {
        if( strcmp( str, m_pMaterials[cc].szName ) == 0 )
            MaterialID = cc;
    }
    
    stMesh* pMesh = &(m_pMeshs[m_iNumMeshs - 1]);
    for(int i=0; i<iNumFaces; i++)
    {
        int iIndex = FaceAssignedThisMaterial[i];
        pMesh->pFaces[iIndex].MaterialID = MaterialID;
    }
    
    return;
}

/***************************************************************************/
/*                                                                         */
/* We get all the faces...e.g. Triangle Index's into our vertex array, so  */
/* we can actually put our shape together.                                 */
/*                                                                         */
/***************************************************************************/
void CB3DMeshLoader3DS::ReadMeshFaces(stChunk* Chunk)
{
    unsigned int iNumberFaces = 0; //= Chunk->length - 6;
    Chunk->bytesRead += (unsigned int)fread(&iNumberFaces, 1, 2, m_fp);
    
    // Each face is 3 points A TRIANGLE!..WOW
    struct stXFace{ unsigned short p1, p2, p3, visibityflag; };
    stXFace *pFaces = new stXFace[iNumberFaces];
    
    Chunk->bytesRead += (unsigned int)fread(pFaces, 1, iNumberFaces*sizeof(stXFace), m_fp);
    
    stMesh* pMesh = &(m_pMeshs[m_iNumMeshs - 1]);
    pMesh->pFaces = new stFace[iNumberFaces];
    pMesh->iNumFaces = iNumberFaces;
    
    unsigned int iNumberIndices = iNumberFaces * 3;
    pMesh->iNumIndices = iNumberIndices;
    pMesh->pIndices = new unsigned short[iNumberIndices];
    
    for (unsigned int i = 0; i < iNumberFaces; i++)
    {
        pMesh->pFaces[i].A = pFaces[i].p1;
        pMesh->pFaces[i].B = pFaces[i].p2;
        pMesh->pFaces[i].C = pFaces[i].p3;
        
        int offset = i * 3;
        pMesh->pIndices[offset] = pFaces[i].p1;
        pMesh->pIndices[offset+1] = pFaces[i].p2;
        pMesh->pIndices[offset+2] = pFaces[i].p3;
    }
    
    delete[] pFaces;
    
    
    // Our face material information is a sub-chunk.
    ParseChunk(Chunk);
}

/***************************************************************************/
/*                                                                         */
/* You know all those x,y,z things...yup I mean vertices...well this reads */
/* them all in.                                                            */
/*                                                                         */
/***************************************************************************/
void CB3DMeshLoader3DS::ReadMeshVertices(stChunk* Chunk)
{
    unsigned int iNumberVertices = 0;
    Chunk->bytesRead += (unsigned int)fread(&iNumberVertices, 1, 2, m_fp);
    
    // Allocate Memory and dump our vertices to the screen.
    stVert *pVerts = new stVert[iNumberVertices];
    
    Chunk->bytesRead += (unsigned int)fread( (void*)pVerts, 1, iNumberVertices*sizeof(stVert), m_fp);
    
    stMesh* pMesh = &(m_pMeshs[m_iNumMeshs - 1]);
    pMesh->pVerts = pVerts;
    pMesh->iNumVerts = iNumberVertices;
    
    SkipChunk(Chunk);
}

/***************************************************************************/
/*                                                                         */
/* Well if we have a texture, e.g. coolimage.bmp, then we need to load in  */
/* our texture coordinates...tu and tv.                                    */
/*                                                                         */
/***************************************************************************/
void CB3DMeshLoader3DS::ReadMeshTexCoords(stChunk* Chunk)
{
    unsigned short iNumberVertices = 0;
    Chunk->bytesRead += (unsigned int)fread(&iNumberVertices, 1, 2, m_fp);
    
    // Allocate Memory and dump our texture for each vertice to the screen.
    stTex *pTex = new stTex[iNumberVertices];
    
    Chunk->bytesRead += (unsigned int)fread( (void*)pTex, 1, iNumberVertices*sizeof(stTex), m_fp);
    
    stMesh* pMesh = &(m_pMeshs[m_iNumMeshs - 1]);
    pMesh->pTexs = pTex;
    
    SkipChunk(Chunk);
}


/***************************************************************************/
/*                                                                         */
/* Read in our objects name...as each object in our 3D world has a name,   */
/* for example Box1, HillMesh...whatever you called your object or object's*/
/* in 3d max before you saved it.                                          */
/*                                                                         */
/***************************************************************************/
void CB3DMeshLoader3DS::GetMeshObjectName(stChunk* Chunk)
{
    // The strange thing is, the next few parts of this chunk represent
    // the name of the object.  Then we start chunking again.
    char str[256];
    unsigned int characterlen = GetString(str);
    Chunk->bytesRead += characterlen;
    
    stMesh* pMesh = &(m_pMeshs[m_iNumMeshs - 1]);
    strcpy( pMesh->szMeshName, str );
    
    ParseChunk(Chunk);
}

// Read in our texture's file name (e.g. coolpic.jpg)
void CB3DMeshLoader3DS::GetTexFileName(stChunk* Chunk)
{
    char str[256];
    Chunk->bytesRead += GetString(str);
    
    stMaterial* pMat = &(m_pMaterials[m_iNumMaterials-1]);
    strcpy( pMat->szTextureFile, str );
}

// Read in our diffuse colour (rgb)
void CB3DMeshLoader3DS::GetDiffuseColour(stChunk* Chunk)
{
    struct stRGB{ unsigned char r, g, b; };
    stRGB DiffColour;
    
    char ChunkHeader[6];
    Chunk->bytesRead += (unsigned int)fread(ChunkHeader, 1, 6, m_fp);
    
    Chunk->bytesRead += (unsigned int)fread(&DiffColour, 1, 3, m_fp);
    
    stMaterial* pM = &(m_pMaterials[m_iNumMaterials-1]);
    pM->Colour.r = DiffColour.r;
    pM->Colour.g = DiffColour.g;
    pM->Colour.b = DiffColour.b;
    
    SkipChunk(Chunk);
}

// Get the materials name, e.g. default-2- etc
void CB3DMeshLoader3DS::GetMaterialName(stChunk* Chunk)
{
    char str[256];
    Chunk->bytesRead += GetString(str);
    
    stMaterial* pM = &(m_pMaterials[m_iNumMaterials-1]);
    strcpy(pM->szName, str);
}
/***************************************************************************/
/*                                                                         */
/* If theres a nested sub-chunk, and we know its ID, e.g 0xA000 etc, then  */
/* we can simply add its ID to the switch list, and add a calling sub      */
/* functino which will deal with it.  Else just skip over that Chunk...    */
/* and carry on parsing the rest of our file.                              */
/*                                                                         */
/***************************************************************************/

void CB3DMeshLoader3DS::ParseChunk(stChunk* Chunk)
{
    while(Chunk->bytesRead < Chunk->length)
    {
        stChunk tempChunk = {0};
        ReadChunk(&tempChunk);
        
        switch(tempChunk.ID)
        {
                // HEADER OUR ENTRY POINT
            case EDIT3DS: //0x3D3D
                ParseChunk(&tempChunk);
                break;
                
                // MATERIALS
            case MATERIAL: //0xAFFF
                stMaterial newMaterial;
                m_pMaterials.push_back(newMaterial);
                m_iNumMaterials++;
                ParseChunk(&tempChunk);
                break;
            case MAT_NAME: //0xA000 - sz for hte material name "e.g. default 2"
                GetMaterialName(&tempChunk);
                break;
            case MAT_DIFFUSE:  // Diffuse Colour  //0xA020
                GetDiffuseColour(&tempChunk);
                break;
            case MAT_TEXMAP:  //0xA200 - if there's a texture wrapped to it where here
                ParseChunk(&tempChunk);
                break;
            case MAT_TEXFLNM: // 0xA300 -  get filename of the material
                GetTexFileName(&tempChunk);
                break;
                
                // OBJECT - MESH'S
            case NAMED_OBJECT: //0x4000
            {
                stMesh newMesh;
                m_pMeshs.push_back(newMesh);
                m_iNumMeshs++;
                GetMeshObjectName(&tempChunk);
            }
                break;
            case OBJ_MESH:     //0x4100
                ParseChunk(&tempChunk);
                break;
            case MESH_VERTICES: //0x4110
                ReadMeshVertices(&tempChunk);
                break;
            case MESH_FACES: //0x4120
                ReadMeshFaces(&tempChunk);
                break;
            case MESH_TEX_VERT: //0x4140
                ReadMeshTexCoords(&tempChunk);
                break;
            case MESH_MATER: //0x4130
                ReadMeshMaterials(&tempChunk);
                break;
                
            default:
                SkipChunk(&tempChunk);
        }
        
        Chunk->bytesRead += tempChunk.length;
    }
}


//#define VERTTYPE GLfloat
//#define VERTTYPEENUM GL_FLOAT
//
//// Floating-point operations
//#define VERTTYPEMUL(a,b)			( (VERTTYPE)((a)*(b)) )
//#define VERTTYPEDIV(a,b)			( (VERTTYPE)((a)/(b)) )
//#define VERTTYPEABS(a)				( (VERTTYPE)(fabs(a)) )
//
//#define f2vt(x)						(x)
//#define vt2f(x)						(x)


/*!***************************************************************************
 @Function			Normal
 @Input				pV1
 @Input				pV2
 @Input				pV3
 @Output			NormalVect
 @Description		Compute the normal to the triangle defined by the vertices V1,
 V2 and V3.
 *****************************************************************************/
//stVector3 CB3DMeshLoader3DS::Normal(stVert *pV1, stVert *pV2, stVert *pV3)
//{
//	/*
//     The calculation of the normal will be done in floating point,
//     doesn't matter if we're using fixed point.
//     */
//	stVector3 fNormal;
//	stVector3 fV1, fV2, fV3;
//	stVector3 Vect1, Vect2;
//    
//	fV1.x = vt2f(pV1[0]); fV1.y = vt2f(pV1[1]); fV1.z = vt2f(pV1[2]);
//	fV2.x = vt2f(pV2[0]); fV2.y = vt2f(pV2[1]); fV2.z = vt2f(pV2[2]);
//	fV3.x = vt2f(pV3[0]); fV3.y = vt2f(pV3[1]); fV3.z = vt2f(pV3[2]);
//    
//	float PMod;
//    
//    /* Compute triangle vectors */
//	Vect1.x = fV1.x-fV2.x;   Vect1.y = fV1.y-fV2.y;   Vect1.z = fV1.z-fV2.z;
//    Vect2.x = fV1.x-fV3.x;   Vect2.y = fV1.y-fV3.y;   Vect2.z = fV1.z-fV3.z;
//    
//	/* Find cross-product vector of these two vectors */
//	fNormal.x = (Vect1.y * Vect2.z) - (Vect1.z * Vect2.y);
//	fNormal.y = (Vect1.z * Vect2.x) - (Vect1.x * Vect2.z);
//	fNormal.z = (Vect1.x * Vect2.y) - (Vect1.y * Vect2.x);
//    
//	/* Compute length of the resulting vector */
//    PMod = (float)sqrt(fNormal.x*fNormal.x+fNormal.y*fNormal.y+fNormal.z*fNormal.z);
//    
//	/* This is to avoid a division by zero */
//    if (PMod < 1e-10f)
//		PMod = 1e-10f;
//    
//	PMod = 1.0f / PMod;
//    
//	/* Normalize normal vector */
//    fNormal.x *= PMod;
//	fNormal.y *= PMod;
//	fNormal.z *= PMod;
//    
//	return fNormal;
//}


/*!***************************************************************************
 @Function			CalculateNormals
 @Modified			pObject
 @Description		Compute vertex normals of submitted vertices array.
 *****************************************************************************/
//void CB3DMeshLoader3DS::CalculateNormals(int nNumVertex, stVert *pVertex,
//                                 int nNumFaces, unsigned short *pFaces,
//                                 stVert *pNormals)
//{
//	unsigned short	P1, P2, P3;
//	stVert		fMod, *pfVN;
//	int				nIdx;
//	int				j, k;
//    
//	stVector3 fNormal;
//    
//	// Parameter checking
//	if (!pVertex || !pFaces || !pNormals)
//	{
//		_RPT0(_CRT_WARN,  "CalculateNormals : Bad parameters\n");
//		return;
//	}
//    
//	// Use the actual output array for summing face-normal contributions
//	pfVN = pNormals;
//    
//	// Zero normals array
//	memset(pfVN, 0, nNumVertex * 3 * sizeof(stVert));
//    
//	// Sum the components of each face's normal to a vector normal
//	for (j=0; j < 3 * nNumFaces; j += 3)
//	{
//		// Get three points defining a triangle
//		P1 = pFaces[j + 0];
//		P2 = pFaces[j + 1];
//		P3 = pFaces[j + 2];
//        
//		// Calculate face normal in pfN
//		fNormal = Normal(&pVertex[3*P1], &pVertex[3*P2], &pVertex[3*P3]);
//        
//		// Add the normal of this triangle to each vertex
//		for (k=0; k<3; k++)
//		{
//			nIdx = pFaces[j + k];
//			pfVN[nIdx * 3 + 0] += f2vt(fNormal.x);
//			pfVN[nIdx * 3 + 1] += f2vt(fNormal.y);
//			pfVN[nIdx * 3 + 2] += f2vt(fNormal.z);
//		}
//	}
//    
//	stVert fSq[3];
//	// Normalise each vector normal and set in mesh
//	for (j = 0; j < 3 * nNumVertex; j += 3)
//	{
//        
//		fSq[0] = stVertMUL(pfVN[j + 0], pfVN[j + 0]);
//		fSq[1] = stVertMUL(pfVN[j + 1], pfVN[j + 1]);
//		fSq[2] = stVertMUL(pfVN[j + 2], pfVN[j + 2]);
//        
//		fMod = (stVert) f2vt(sqrt(vt2f(fSq[0] + fSq[1] + fSq[2])));
//        
//		// Zero length normal? Either point down an axis or leave...
//		if(fMod == f2vt(0.0f))
//			continue;
//        
//		fMod = stVertDIV(f2vt(1.0f), fMod);
//        
//		pNormals[j + 0] = stVertMUL(pNormals[j + 0], fMod);
//		pNormals[j + 1] = stVertMUL(pNormals[j + 1], fMod);
//		pNormals[j + 2] = stVertMUL(pNormals[j + 2], fMod);
//	}
//}




/***************************************************************************/
/*                                                                         */
/* Read in .3ds file.                                                      */
/*                                                                         */
/***************************************************************************/

bool CB3DMeshLoader3DS::Create(const char* szFileName)
{
    m_fp = fopen(szFileName, "rb");
    
    stChunk Chunk = {0};
    ReadChunk(&Chunk);
    
    ParseChunk(&Chunk );
    
    fclose(m_fp);
    
    return true;
}

void CB3DMeshLoader3DS::Release()
{
    for (int i=0; i<m_iNumMeshs; i++)
    {
        delete[] m_pMeshs[i].pVerts;
        delete[] m_pMeshs[i].pFaces;
        delete[] m_pMeshs[i].pIndices;
        delete[] m_pMeshs[i].pTexs;
    }
}


// Debugging Function
void CB3DMeshLoader3DS::DisplayRawData()
{
    for (unsigned int i = 0; i < this->m_iNumMeshs; i++)
    {
        CB3DMeshLoader3DS::stMesh* pMesh = &(this->m_pMeshs[i]);
        
        printf("Shape: %s\n", pMesh->szMeshName);
                
        printf("iNumFaces: %d\n", pMesh->iNumFaces);

        for (int cc=0; cc<pMesh->iNumFaces; cc++)
        {
            printf("\t %d, \t %d \t %d\n",
                   pMesh->pFaces[cc].A, pMesh->pFaces[cc].B, pMesh->pFaces[cc].C);
        }
        
        printf("iNumVertices: %d\n", pMesh->iNumVerts);

        for (int cc=0; cc<pMesh->iNumVerts; cc++)
        {
            printf("\t %.2f, \t %.2f \t %.2f\n",
                   pMesh->pVerts[cc].x,pMesh->pVerts[cc].y,pMesh->pVerts[cc].z);
        }
        
        if( pMesh->pTexs != NULL )
        {
            printf("iNumTex: %d\n", pMesh->iNumVerts);

            for(int cc=0; cc<pMesh->iNumVerts; cc++)
            {
                printf("\t %.2f, \t %.2f\n",
                       pMesh->pTexs[cc].tu, pMesh->pTexs[cc].tv );
            }
        }
        
        if (this->m_iNumMaterials > 0)
        {
            printf("Material vs Faces: %d\n", pMesh->iNumFaces);

            for(int cc=0; cc<pMesh->iNumFaces; cc++)
            {
                printf("\t MaterialID: %d",
                       pMesh->pFaces[cc].MaterialID );
                                
                int ID = pMesh->pFaces[cc].MaterialID;
                printf("\t, Name: %s\n", this->m_pMaterials[ID].szName);
            }
        }
    }
}

