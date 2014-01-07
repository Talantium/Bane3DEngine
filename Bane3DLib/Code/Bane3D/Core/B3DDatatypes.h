//
//  B3DDatatypes.h
//  Bane3D
//
//  Created by Andreas Hanft on 07.04.11.
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

#import <CoreGraphics/CoreGraphics.h>
#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/gl.h>


//	B3DTextureInfo is a helper struct to use only a part of 
//	a texture beeing a texture atlas, generated from a tool
//	like atlas maker.
const int B3DTextureInfoAtlasNameMaxLength = 51;
typedef struct B3DTextureInfo
{
	CGRect		sourceRect;
	char		atlasName[B3DTextureInfoAtlasNameMaxLength];
	
	B3DTextureInfo() {};
	
    B3DTextureInfo(GLfloat x, GLfloat y, GLfloat width, GLfloat height, const char* name)
	{
		CGRect rect;
		rect.origin.x = x;
		rect.origin.y = y;
		rect.size.width = width;
		rect.size.height = height;
		sourceRect = rect;
		
		if (strlcpy(atlasName, name, B3DTextureInfoAtlasNameMaxLength)
			>= B3DTextureInfoAtlasNameMaxLength)
		{
			NSCAssert(NO, @"Name of atlas file too long!");
		}
    };
	
	inline bool isUnset()
	{
		return CGRectIsEmpty(sourceRect);
	}
	
	/**
	 *	Use and output:
	 
	 B3DTextureInfo info = TextureInfo(0, 196, 12, 12, "game_texture_atlas_01");
	 
	 LogDebug(@"TextureInfo: %f %f %f %f %@",
     info.sourceRect.origin.x,
     info.sourceRect.origin.y, 
     info.sourceRect.size.width, 
     info.sourceRect.size.height, 
     [NSString stringWithCString:info.atlasName encoding:NSUTF8StringEncoding]);
	 
	 *
	 */
    
} B3DTextureInfo;


typedef struct
{
    GLKMatrixStackRef   matrixStack;
    double              deltaTime;
//    __unsafe_unretained B3DScene* scene;
} B3DSceneGraphInfo;
