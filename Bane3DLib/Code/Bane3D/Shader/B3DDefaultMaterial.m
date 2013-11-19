//
//  B3DDefaultMaterial.m
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

#import "B3DDefaultMaterial.h"

#import "B3DShaderDefaultAmbient.h"
#import "B3DAssetToken.h"
#import "B3DConstants.h"


@implementation B3DDefaultMaterial

+ (B3DAssetToken*) token
{
    B3DAssetToken* token = [[B3DAssetToken alloc] init];
    token.uniqueIdentifier = [B3DAssetToken uniqueIdForAsset:B3DDefaultMaterialName
                                               withExtension:[[self class] extension]
                                                      ofType:B3DAssetTypeVolatile];
    return token;
}

- (id) init
{
    self = [super initWithVolatileResourceNamed:B3DDefaultMaterialName];
    if (self)
    {
        self.shader = [B3DShaderDefaultAmbient shader];
    }
    
    return self;
}

@end
