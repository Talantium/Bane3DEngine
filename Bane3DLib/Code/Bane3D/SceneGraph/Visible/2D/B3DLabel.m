//
//  B3DLabel.m
//  Bane3D
//
//  Created by Andreas Hanft on 14.01.13.
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

#import <UIKit/UIKit.h>

#import "B3DLabel.h"

#import "B3DTextureFont.h"
#import "B3DConstants.h"
#import "B3DShaderDefaultBaseColor.h"
#import "B3DRenderMan.h"
#import "B3DShader.h"
#import "B3DMaterial.h"
#import "B3DScene.h"
#import "B3DCamera.h"
#import "B3DNode+Protected.h"
#import "B3DVisibleNode+Protected.h"
#import "B3DTextureFontContainer.h"


const       int		B3DLabelMaxLabelLength                  = 256;


@interface B3DLabel ()

@property (nonatomic, readwrite, weak) B3DTextureFont*     textureFont;

@end


@implementation B3DLabel

- (id) initWithText:(NSString*)text
{
    return [self initWithFont:[UIFont systemFontOfSize:B3DLabelDefaultFontSize] text:text];
}

- (id) initWithFontNamed:(NSString*)fontName size:(CGFloat)size
{
    return [self initWithFont:[UIFont fontWithName:fontName size:size] text:nil];
}

- (id) initWithFontNamed:(NSString*)fontName size:(CGFloat)size text:(NSString*)text
{
    return [self initWithFont:[UIFont fontWithName:fontName size:size] text:text];
}

- (id) initWithFont:(UIFont*)font text:(NSString*)text
{
    self = [super init];
    if (self)
    {
        [self useShader:[B3DShaderDefaultBaseColor token]];
        
        if (font)
		{
            B3DAssetToken* textureFontToken = [B3DTextureFont tokenForFont:font];
            [self useAssetWithToken:textureFontToken
                          atKeyPath:@"material.texture"];
            
            [self useAssetWithToken:textureFontToken
                          atKeyPath:@"textureFont"];
		}
        
        if (text)
        {
            _text = [text copy];
            _dirty = YES;
        }
    }
    
    return self;
}

- (void) awake
{
    [super awake];
    
    self.material.baseColor = self.color;
}

- (Class) classForRenderContainer
{
    return [B3DTextureFontContainer class];
}

#pragma mark - Properties

- (void) setText:(NSString*)text
{
    if ([_text isEqualToString:text] == NO)
    {
        _text = [text copy];
        _size = CGSizeZero;
        _dirty = YES;
    }
}


- (void) updateVerticeData
{
    if (_dirty)
    {
        NSUInteger vertexCount = 0;
        NSDictionary* charDict = _textureFont.charDict;

        NSUInteger length = _text.length;
        unichar buffer[length + 1];
        [_text getCharacters:buffer range:NSMakeRange(0, length)];

        CGFloat spacing = 0.0f;
        CGPoint currentPosition = CGPointZero;

        NSString* currentCharAsString = nil;
        B3DTextureFontCharMapInfo currentCharInfo;

        B3DTextureFontCharSprite textRepresentation[length];
        for (int i = 0; i < length; ++i)
        {
            unichar currentChar = buffer[i];
            currentCharAsString = [NSString stringWithCharacters:&currentChar length:1];

            NSValue* value = [charDict objectForKey:currentCharAsString];
            if (value == nil)
            {
                value = [charDict objectForKey:@"?"];
            }
            [value getValue:&currentCharInfo];

            textRepresentation[i].bottomLeft.position   = GLKVector3Make(currentPosition.x, currentPosition.y, 0.0f);
            textRepresentation[i].bottomRight.position  = GLKVector3Make(currentPosition.x + currentCharInfo.size.width, currentPosition.y, 0.0f);
            textRepresentation[i].topLeft.position      = GLKVector3Make(currentPosition.x, currentPosition.y + currentCharInfo.size.height, 0.0f);
            textRepresentation[i].topRight.position     = GLKVector3Make(currentPosition.x + currentCharInfo.size.width, currentPosition.y + currentCharInfo.size.height, 0.0f);
            currentPosition.x += spacing + currentCharInfo.size.width;

            _size.width = currentPosition.x - spacing; // Remove spacing for bounding size
            _size.height = MAX(_size.height, currentCharInfo.size.height);

            textRepresentation[i].bottomLeft.texCoords  = currentCharInfo.textCoords[0];
            textRepresentation[i].bottomRight.texCoords = currentCharInfo.textCoords[1];
            textRepresentation[i].topLeft.texCoords     = currentCharInfo.textCoords[2];
            textRepresentation[i].topRight.texCoords    = currentCharInfo.textCoords[3];

            textRepresentation[i].degeneratedFirst      = textRepresentation[i].bottomLeft;
            textRepresentation[i].degeneratedLast       = textRepresentation[i].topRight;

            vertexCount += 6;
        }

        // Discard last degenerated sprite
        vertexCount -= 1;
        
        _vertexCount = vertexCount;
        _vertexData = [NSMutableData dataWithBytes:textRepresentation length:sizeof(B3DTextureFontCharVertice) * vertexCount];
        
        _dirty = NO;
    }
}


@end
