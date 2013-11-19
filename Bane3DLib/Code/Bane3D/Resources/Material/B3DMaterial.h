//
//  B3DMaterial.h
//  Bane3D
//
//  Created by Andreas Hanft on 12.04.11.
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

#import <Bane3D/Resources/B3DAsset.h>

@class B3DTexture;
@class B3DShader;
@class B3DColor;


@interface B3DMaterial : B3DAsset

@property (nonatomic, assign) uint                renderID;
@property (nonatomic, strong) B3DTexture*         texture;
@property (nonatomic, copy)   B3DShader*          shader;

@property (nonatomic, strong) B3DColor*           baseColor;
@property (nonatomic, strong) B3DColor*           ambientColor;
@property (nonatomic, strong) B3DColor*           diffuseColor;

+ (B3DMaterial*) materialNamed:(NSString*)name;

- (void) updateRenderID;

@end
