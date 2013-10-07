//
//  Bane3D.h
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


#pragma mark - Core
#import <Bane3D/Core/B3DConstants.h>
#import <Bane3D/Core/B3DDatatypes.h>
#import <Bane3D/Core/Bane3DEngine.h>


#pragma mark - Math
#import <Bane3D/Math/B3DMathHelper.h>
#import <Bane3D/Math/Geometry/B3DGeometryHelper.h>


#pragma mark - iOS Bridge
#import <Bane3D/Core/iOS/B3DGLView.h>
#import <Bane3D/Core/iOS/B3DGLViewController.h>


#pragma mark - Protocols
#import <Bane3D/Input/B3DTouchResponder.h>
#import <Bane3D/Resources/B3DSceneLoadingDelegate.h>


#pragma mark - Scene Graph
#import <Bane3D/SceneGraph/B3DBaseNode.h>
#import <Bane3D/SceneGraph/B3DSceneManager.h>
#pragma mark • Logical
#import <Bane3D/SceneGraph/Logical/B3DScene.h>
#import <Bane3D/SceneGraph/Logical/B3DCamera.h>
#import <Bane3D/SceneGraph/Logical/B3DTimer.h>
#pragma mark • Visible Common
#import <Bane3D/SceneGraph/Visible/B3DVisibleNode.h>
#pragma mark • Visible/2D
#import <Bane3D/SceneGraph/Visible/2D/B3DSprite.h>
#import <Bane3D/SceneGraph/Visible/2D/B3DLabel.h>
#import <Bane3D/SceneGraph/Visible/2D/GUI/B3DGUIImage.h>
#import <Bane3D/SceneGraph/Visible/2D/GUI/B3DGUITouchable.h>
#import <Bane3D/SceneGraph/Visible/2D/GUI/B3DGUIButton.h>
#import <Bane3D/SceneGraph/Visible/2D/GUI/B3DGUIDraggable.h>
#import <Bane3D/SceneGraph/Visible/2D/GUI/B3DGUIDefaultSplashImage.h>
#pragma mark • Visible/3D
#import <Bane3D/SceneGraph/Visible/3D/B3DBaseModelNode.h>


#pragma mark - Rendering Pipeline
#pragma mark • Optimizing GL State Handling
#import <Bane3D/Rendering/B3DGLStateManager.h>
#import <Bane3D/Rendering/B3DRenderMan.h>
#import <Bane3D/Rendering/B3DFrameBuffer.h>
#pragma mark • Sprite Batching
#import <Bane3D/Rendering/Batching/B3DVerticeBatchHelper.h>
#import <Bane3D/Rendering/Batching/B3DSpriteBatcher.h>
#import <Bane3D/Rendering/Batching/B3DOpaqueSpriteSorter.h>
#import <Bane3D/Rendering/Batching/B3DTransparentNodeSorter.h>


#pragma mark - Resources
#import <Bane3D/Resources/B3DAsset.h>
#import <Bane3D/Resources/B3DAssetToken.h>
#import <Bane3D/Resources/B3DAssetManager.h>
#import <Bane3D/Resources/B3DAssetSet.h>
#pragma mark • Audio
#import <Bane3D/Resources/Audio/B3DAudioAsset.h>
#pragma mark • Mesh
#import <Bane3D/Resources/Mesh/B3DVertexBuffer.h>
#import <Bane3D/Resources/Mesh/B3DMesh.h>
#import <Bane3D/Resources/Mesh/B3DMeshGeneric.h>
#import <Bane3D/Resources/Mesh/B3DMesh3DS.h>
#pragma mark • Material
#import <Bane3D/Resources/Material/B3DMaterial.h>
#pragma mark • Shader
#import <Bane3D/Resources/Shader/B3DShader.h>
#import <Bane3D/Resources/Shader/B3DShaderUnit.h>
#import <Bane3D/Resources/Shader/B3DShaderUnitVertex.h>
#import <Bane3D/Resources/Shader/B3DShaderUnitFragment.h>
#pragma mark • Texture
#import <Bane3D/Resources/Texture/B3DTexture.h>
#import <Bane3D/Resources/Texture/B3DTexturePNG.h>
#import <Bane3D/Resources/Texture/B3DTexturePVR.h>
#import <Bane3D/Resources/Texture/B3DTextureFont.h>


#pragma mark - Utils
#import <Bane3D/Utils/B3DPoint.h>
#import <Bane3D/Utils/B3DHelper.h>
#import <Bane3D/Utils/B3DDebug.h>
#import <Bane3D/Utils/B3DColor.h>
#import <Bane3D/Utils/B3DTime.h>
#import <Bane3D/Utils/Categories/UIApplication+ApplicationDimensions.h>


#pragma mark - Built In Shader/Material
#import <Bane3D/Shader/B3DDefaultMaterial.h>
#pragma mark • Basic
#import <Bane3D/Shader/Basic/B3DShaderDefaultAmbient.h>
#import <Bane3D/Shader/Basic/B3DShaderDefaultBaseColor.h>
#import <Bane3D/Shader/Basic/B3DShaderDefaultSimpleColor.h>


#pragma mark - Input
#import <Bane3D/Input/B3DInputManager.h>
