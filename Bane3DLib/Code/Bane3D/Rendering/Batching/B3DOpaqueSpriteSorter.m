//
//  B3DOpaqueSpriteSorter.m
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

#import "B3DOpaqueSpriteSorter.h"

#import "B3DSpriteBatcher.h"
#import "B3DSprite.h"
#import "B3DMaterial.h"


@interface B3DOpaqueSpriteSorter ()
{
    NSMutableDictionary*        _spritesByTexture;
    B3DSpriteBatcher*           _spriteBatcher;
}

@end


@implementation B3DOpaqueSpriteSorter

#pragma mark - Con-/Destructor

// Designated initialiser
- (id) initWithSharedBatcher:(B3DSpriteBatcher*)spriteBatcher
{
    self = [super init];
    if (self)
    {
        _spriteBatcher      = spriteBatcher;
        _spritesByTexture   = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}


#pragma mark - Sprite Handling

- (void) addSprite:(B3DSprite*)sprite
{
    // @TODO: this should really be optimized, maybe use a vector?
    NSNumber* renderID = [NSNumber numberWithUnsignedInt:sprite.material.renderID];
    NSMutableArray* sprites = [_spritesByTexture objectForKey:renderID];
    if (sprites == nil)
    {
        // @TODO: Implement more efficient way of storing the ordered sprites! 
        
        sprites = [[NSMutableArray alloc] init];
        [_spritesByTexture setObject:sprites forKey:renderID];
    }
    [sprites addObject:sprite];
    
#if DEBUG_PRINT_STATS_BATCHING
    _spriteCount++;
#endif
}

- (void) render
{
    for (NSArray* sprites in [_spritesByTexture allValues])
    {
        [_spriteBatcher renderSpriteArray:sprites];
        
#if DEBUG_PRINT_STATS_BATCHING
        _arrayCount++;
#endif
    }
    
    [_spritesByTexture removeAllObjects];
    
#if DEBUG_PRINT_STATS_BATCHING    
    _spriteCountLastFrame = _spriteCount;
    _arrayCountLastFrame = _arrayCount;
    _spriteCount = 0;
    _arrayCount = 0;
#endif
}

@end
