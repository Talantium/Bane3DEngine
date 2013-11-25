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

@property (nonatomic, readonly, strong) B3DLayer* perspectiveLayer;
@property (nonatomic, readonly, strong) B3DLayer* orthoLayer;

- (void) presentSceneWithKey:(NSString*)key;

@end
