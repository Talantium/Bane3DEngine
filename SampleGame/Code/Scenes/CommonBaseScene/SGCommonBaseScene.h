//
//  SGCommonBaseScene.h
//  SampleGame
//
//  Created by Andreas Hanft on 14.03.13.
//  Copyright (c) 2013 talantium.net. All rights reserved.
//

#import <Bane3D/Bane3D.h>


extern NSString*   const   SGCommonBaseSceneFontName;
extern const       float   SGCommonBaseSceneFontSize;
extern const       float   SGCommonBaseSceneButtonFontSize;


@interface SGCommonBaseScene : B3DScene

- (void) presentSceneWithKey:(NSString*)key;

@end
