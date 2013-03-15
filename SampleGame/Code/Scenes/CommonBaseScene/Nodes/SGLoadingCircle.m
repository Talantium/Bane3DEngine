//
//  SGLoadingCircle.m
//  SampleGame
//
//  Created by Andreas Hanft on 14.03.13.
//  Copyright (c) 2013 talantium.net. All rights reserved.
//

#import "SGLoadingCircle.h"

#import "LoadingCircleAtlas.h"


const   int SGLoadingCircleFrameCount        = 9;


@implementation SGLoadingCircle

+ (SGLoadingCircle*) loadingCircle
{
    SGLoadingCircle* loadingCircle = [[self alloc] initWithTextureInfo:TEX_LOADINGCIRCLEANIM00 type:[B3DTexturePNG extension]];
   
    return loadingCircle;
}

- (void) setProgress:(float)progress
{
    static B3DTextureInfo info[] = {
        TEX_LOADINGCIRCLEANIM00,
        TEX_LOADINGCIRCLEANIM01,
        TEX_LOADINGCIRCLEANIM02,
        TEX_LOADINGCIRCLEANIM03,
        TEX_LOADINGCIRCLEANIM04,
        TEX_LOADINGCIRCLEANIM05,
        TEX_LOADINGCIRCLEANIM06,
        TEX_LOADINGCIRCLEANIM07,
        TEX_LOADINGCIRCLEANIM08};
    
    progress = clamp01(progress);
    int index = ((double)SGLoadingCircleFrameCount - 0.01) * progress;
        
    self.textureInfo = info[index];
}

@end
