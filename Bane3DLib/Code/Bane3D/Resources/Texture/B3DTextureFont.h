//
//  B3DTextureFont.h
//  Bane3D
//
//  Created by Andreas Hanft on 14.01.13.
//  Copyright (c) 2013 talantium.net. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Bane3D/Resources/Texture/B3DTexture.h>


@interface B3DTextureFont : B3DTexture

@property (nonatomic, strong, readonly) NSMutableDictionary*    charDict;
@property (nonatomic, strong, readonly) UIFont*                 font;
@property (nonatomic, copy,  readwrite) NSString*               charSet; // Uses B3DTextureFontDefaultCharSet as default

+ (B3DTextureFont*) defaultFontTexture;
+ (B3DAssetToken*) tokenForFont:(UIFont*)font;

+ (B3DTextureFont*) textureWithFont:(UIFont*)font;
+ (B3DTextureFont*) textureWithFontNamed:(NSString*)name size:(CGFloat)size;

- (id) initWithFont:(UIFont*)font;

@end
