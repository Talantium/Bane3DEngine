//
//  Mandelbrot.h
//  SampleGame
//
//  Created by Andreas Hanft on 21.04.11.
//  Copyright 2011 talantium.net All rights reserved.
//

#import <Bane3D/Bane3D.h>


@interface Mandelbrot : B3DShader

+ (NSString*) uniformCenter;
+ (NSString*) uniformScale;

@end
