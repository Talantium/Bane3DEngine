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

#import "B3DConstants.h"


// Engine
NSString*   const   B3DEngineVersionString                  = @"0.6.0";
const       int		B3DEngineMaxFps                         = 60;

// Scene Graph
NSString*   const   B3DSceneManagerRootSceneKey             = @"B3DSceneManagerRootSceneKey";

// Scene
NSString*   const   B3DSceneCameraDefaultPerspectiveKey     = @"B3DSceneCameraDefaultPerspectiveKey";
NSString*   const   B3DSceneCameraDefaultOrthoKey           = @"B3DSceneCameraDefaultOrthoKey";

// Assets
// By default expected extensions
NSString*   const   B3DAssetTexturePVRDefaultExtension      = @"pvr";
NSString*   const   B3DAssetTexturePNGDefaultExtension      = @"png";
NSString*   const   B3DAssetMesh3DSDefaultExtension         = @"3ds";
NSString*   const   B3DAssetShaderVertexDefaultExtension    = @"vert";
NSString*   const   B3DAssetShaderFragmentDefaultExtension  = @"frag";

NSString*   const   B3DAssetTypeVolatile                    = @"B3DAssetTypeVolatileThatHasNoPhysicalFileAndNoPath";
NSString*   const   B3DAssetTypeRemote                      = @"B3DAssetTypeRemote";
NSString*   const   B3DAssetTypeLocal                       = @"B3DAssetTypeLocal";


NSString*   const   B3DDefaultMaterialName                  = @"B3DDefaultMaterialName";
const       float   B3DLabelDefaultFontSize                 = 12.0f;


//extern const        uint		B3DShaderMaxAttribs                 = 8;
//extern const        uint		B3DShaderMaxUniforms                = 128;


NSString*   const   B3DVertexAttributesPositionName         = @"a_position";
NSString*   const   B3DVertexAttributesNormalName           = @"a_normal";
NSString*   const   B3DVertexAttributesColorName            = @"a_color";
NSString*   const   B3DVertexAttributesTexCoord0Name        = @"a_texture_coords_0";
NSString*   const   B3DVertexAttributesTexCoord1Name        = @"a_texture_coords_1";


NSString*   const   B3DShaderUniformMatrixMVP               = @"u_matrix_mvp";
NSString*   const   B3DShaderUniformTextureBase             = @"u_texture_base";
NSString*   const   B3DShaderUniformColorBase               = @"u_color_base";
NSString*   const   B3DShaderUniformColorAmbient            = @"u_color_ambient";
NSString*   const   B3DShaderUniformColorDiffuse            = @"u_color_diffuse";
NSString*   const   B3DShaderUniformToggleTextureAlphaOnly  = @"u_toggle_texAlphaOnly";


// Batching
const       int		B3DSpriteBatcherMaxVertices             = 10000;
