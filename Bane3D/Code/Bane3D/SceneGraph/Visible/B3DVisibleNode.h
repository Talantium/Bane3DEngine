//
//  B3DVisibleNode.h
//  Bane3D
//
//  Created by Andreas Hanft on 13.04.11.
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

#import <Bane3D/SceneGraph/B3DNode.h>

@class B3DMaterial;
@class B3DShader;
@class B3DColor;
@class B3DRenderMan;
@class B3DGLStateManager;


@interface B3DVisibleNode : B3DNode

@property (nonatomic, copy)     B3DMaterial*            material;   //!< We need to copy the material so each node has its own settings for color etc.
@property (nonatomic, strong)   B3DColor*               color;      //!< More or less equals to material.baseColor, implemented to simplify the use of a color on a sprite, meshes don't use it

/**
 * Render settings
 */
@property (nonatomic, assign)   BOOL                    useOrtho;   //!< Use the orthographic or perspective scene camera?
@property (nonatomic, assign, getter=isOpaque)    BOOL  opaque;     //!< Does the node use alpha or transparency either in its color or texture? If yes, we must z-sort the node prior drawing it.
@property (nonatomic, assign, getter=isBatchable) BOOL  batchable;  //!< Can the node be batched and drawn together?

// Setting shader of material directly
- (void) useShader:(B3DAssetToken*)shaderToken;
- (void) useShaderNamed:(NSString*)name;

- (void) render;

@end
