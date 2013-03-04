//
//  B3DTextureFont.h
//  Bane3D
//
//  Created by Andreas Hanft on 14.01.13.
//  Copyright (c) 2013 talantium.net. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <Bane3D/Resources/Texture/B3DTexture.h>


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


@interface B3DTextureFont : B3DTexture

@property (nonatomic, readonly, strong) NSMutableDictionary*    charDict;
@property (nonatomic, readonly, strong) UIFont*                 font;
@property (nonatomic, readwrite, copy)  NSString*               charSet; // Uses B3DTextureFontDefaultCharSet as default

+ (B3DAssetToken*) tokenForFont:(UIFont*)font;

+ (B3DTextureFont*) textureWithFont:(UIFont*)font;
+ (B3DTextureFont*) textureWithFontNamed:(NSString*)name size:(CGFloat)size;

+ (B3DTextureFont*) defaultFontTexture;

- (id) initWithFont:(UIFont*)font;

@end
