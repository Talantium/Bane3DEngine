//
//  B3DBaseModelNode.h
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

#import <Bane3D/SceneGraph/Visible/B3DVisibleNode.h>

@class B3DMesh;


typedef enum
{
    B3DModelRendererSolid,
    B3DModelRendererPoint,
    B3DModelRendererLines,
    B3DModelRendererLineStrip,
    B3DModelRendererLineLoop
} B3DModelRenderer;


@interface B3DBaseModelNode : B3DVisibleNode
{
    @protected
        B3DMesh*                _mesh;
}

@property (nonatomic, strong)   B3DMesh*            mesh;
@property (nonatomic, assign)   B3DModelRenderer    renderer;
@property (nonatomic, assign)   CGFloat             lineWidth; // !< Default: 4.0f

- (id) initWithMesh:(NSString*)meshName ofType:(NSString*)meshType
            texture:(NSString*)textureName ofType:(NSString*)textureType;

@end
