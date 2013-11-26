//
//  B3DTextureFontContainer.h
//  Bane3DEngine
//
//  Created by Andreas Hanft on 26/11/13.
//  Copyright (c) 2013 talantium.net. All rights reserved.
//

#import <GLKit/GLKit.h>
#import <CoreGraphics/CoreGraphics.h>

#import "B3DRenderContainer.h"


typedef struct B3DTextureFontCharMapInfo
{
    uint        index;
    unichar     singleChar;
    CGSize      size;
    CGPoint     position;
    CGPoint     textCoords[4];
} B3DTextureFontCharMapInfo;


typedef struct B3DTextureFontCharVertice
{
    GLKVector3  position;
    CGPoint     texCoords;
} B3DTextureFontCharVertice;


typedef struct B3DTextureFontCharSprite
{
    B3DTextureFontCharVertice degeneratedFirst;
    B3DTextureFontCharVertice bottomLeft;
    B3DTextureFontCharVertice bottomRight;
    B3DTextureFontCharVertice topLeft;
    B3DTextureFontCharVertice topRight;
    B3DTextureFontCharVertice degeneratedLast;
} B3DTextureFontCharSprite;


@interface B3DTextureFontContainer : B3DRenderContainer

@end
