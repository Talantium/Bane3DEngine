//
//  SGLoadingCircle.h
//  SampleGame
//
//  Created by Andreas Hanft on 14.03.13.
//  Copyright (c) 2013 talantium.net. All rights reserved.
//

#import <Bane3D/Bane3D.h>


@interface SGLoadingCircle : B3DGUIImage

+ (SGLoadingCircle*) loadingCircle;

- (void) setProgress:(float)progress;

@end
