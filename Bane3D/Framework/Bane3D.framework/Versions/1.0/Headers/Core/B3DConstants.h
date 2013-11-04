//
//  Bane3DEngine.h
//  Bane3D
//
//  Created by Andreas Hanft on 06.04.11.
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


// Version number of engine as string
extern NSString*    const   B3DEngineVersionString;

// The maximum FPS possible on the device, mostly constrained by hardware 
// capabilities and is usualy 60 FPS (or 60Hz, the display refresh rate).
extern const        int		B3DEngineMaxFps;                            //!< 60

// Key of root scene
extern NSString*    const   B3DSceneManagerRootSceneKey;

// Scenes
// Keys for default cameras
extern NSString*    const   B3DSceneCameraDefaultPerspectiveKey;
extern NSString*    const   B3DSceneCameraDefaultOrthoKey;

// Assets
// By default expected extensions
extern NSString*    const   B3DAssetTexturePVRDefaultExtension;         //!< .pvr
extern NSString*    const   B3DAssetTexturePNGDefaultExtension;         //!< .png
extern NSString*    const   B3DAssetMesh3DSDefaultExtension;            //!< .3ds
extern NSString*    const   B3DAssetShaderVertexDefaultExtension;       //!< .vert
extern NSString*    const   B3DAssetShaderFragmentDefaultExtension;     //!< .frag

// Internal types
extern NSString*    const   B3DAssetTypeVolatile;
extern NSString*    const   B3DAssetTypeRemote;
extern NSString*    const   B3DAssetTypeLocal;

// Some Defaults
extern NSString*    const   B3DDefaultMaterialName;
extern const        int     B3DLabelMaxLabelLength;                     //!< 128
extern const        float   B3DLabelDefaultFontSize;                    //!< 12.0f

// Sprite batcher settings
extern const        int		B3DSpriteBatcherMaxVertices;                //!< 10000


// Texture formats
typedef enum
{
    B3DTextureFormat_Gray,
    B3DTextureFormat_GrayAlpha,
    B3DTextureFormat_RGB,
    B3DTextureFormat_RGBA,
    B3DTextureFormat_PVRTC_RGB2,
    B3DTextureFormat_PVRTC_RGBA2,
    B3DTextureFormat_PVRTC_RGB4,
    B3DTextureFormat_PVRTC_RGBA4,
    B3DTextureFormat_565,
    B3DTextureFormat_5551
} B3DTextureFormat;


// Shader
// TODO: Using the min values specified by OpenGl ES SL 1.0 reference, should
// get actual platform values instead?
//extern const        uint		B3DShaderMaxAttribs;    // 8;
//extern const        uint		B3DShaderMaxUniforms;   // 128;
#define B3DShaderMaxAttribs     8
#define B3DShaderMaxUniforms    128



// Named vertex attributes for mapping shader attributes to client vertex attrib enables
typedef enum
{
    B3DVertexAttributesPosition,
    B3DVertexAttributesNormal,
    B3DVertexAttributesColor,
    B3DVertexAttributesTexCoord0,
    B3DVertexAttributesTexCoord1,
    B3DVertexAttributesCount
} B3DVertexAttributes;

extern NSString*    const   B3DVertexAttributesPositionName;
extern NSString*    const   B3DVertexAttributesNormalName;
extern NSString*    const   B3DVertexAttributesColorName;
extern NSString*    const   B3DVertexAttributesTexCoord0Name;
extern NSString*    const   B3DVertexAttributesTexCoord1Name;


// Default builtin shader uniform names
extern NSString*    const   B3DShaderUniformMatrixMVP;
extern NSString*    const   B3DShaderUniformTextureBase;
extern NSString*    const   B3DShaderUniformColorBase;
extern NSString*    const   B3DShaderUniformColorAmbient;
extern NSString*    const   B3DShaderUniformColorDiffuse;
extern NSString*    const   B3DShaderUniformToggleTextureAlphaOnly;


// Touches for dragging
typedef enum
{
    B3DGUITouchableFirstTouch,
    B3DGUITouchableSecondTouch,
    B3DGUITouchableThirdTouch,
    B3DGUITouchableTouchesCount
} B3DGUITouchableTouches;


