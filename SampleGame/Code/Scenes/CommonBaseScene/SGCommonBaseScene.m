//
//  SGCommonBaseScene.m
//  SampleGame
//
//  Created by Andreas Hanft on 14.03.13.
//  Copyright (c) 2013 talantium.net. All rights reserved.
//

#import "SGCommonBaseScene.h"

#import "SGLoadingCircle.h"


NSString*   const   SGCommonBaseSceneFontName           = @"Futura-CondensedMedium";
const       float   SGCommonBaseSceneFontSize           = 16.0f;
const       float   SGCommonBaseSceneButtonFontSize     = 20.0f;


@interface SGCommonBaseScene ()

@property (nonatomic, readwrite, strong) B3DLayer* perspectiveLayer;
@property (nonatomic, readwrite, strong) B3DLayer* orthoLayer;

@property (nonatomic, readwrite, strong) SGLoadingCircle*   loadingCircle;
@property (nonatomic, readwrite, strong) B3DSprite*         loadingShade;

@end


@implementation SGCommonBaseScene

- (void) assetList
{
    [self registerAssetForUse:[B3DTextureFont defaultFontTexture]];
    [self registerAssetForUse:[B3DTextureFont textureWithFontNamed:SGCommonBaseSceneFontName size:SGCommonBaseSceneFontSize]];
    [self registerAssetForUse:[B3DTextureFont textureWithFontNamed:SGCommonBaseSceneFontName size:SGCommonBaseSceneButtonFontSize]];
	[self registerAssetForUse:[B3DTexturePNG textureNamed:@"LoadingCircleAtlas"]];
}

- (id) init
{
	self = [super initWithLayers:nil];
	if (self != nil)
	{
        _perspectiveLayer = [B3DLayer layerWithCamera:[B3DCameraPerspective camera]];
        _orthoLayer       = [B3DLayer layerWithCamera:[B3DCameraOrtho camera]];
        
        self.layers =  @[_perspectiveLayer, _orthoLayer];
        
        CGSize screenSize = [UIApplication currentSize];
        
        self.handleSceneLoadingEvents = YES;
        
        self.loadingShade = [[B3DSprite alloc] initWithSize:screenSize
                                                        color:[B3DColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:0.6]];
        {
            [self.loadingShade translateByX:0 y:0 z:-1];
            self.loadingShade.hidden = YES;
        }
        [_orthoLayer addChild:self.loadingShade];
        
        
        self.loadingCircle = [SGLoadingCircle loadingCircle];
        [self.loadingCircle translateByX:4 y:20 z:0.5];
        [self.loadingShade addChild:self.loadingCircle];
        
        
        B3DLabel* label = [[B3DLabel alloc] initWithFontNamed:SGCommonBaseSceneFontName
                                                         size:SGCommonBaseSceneFontSize
                                                         text:NSLocalizedString(@"SGCommonBaseSceneLoadingLabelText", nil)];
        {
            label.color = [B3DColor colorWithRGBHex:0xffffff];
            [label translateByX:4 y:0 z:0.6];
        }
        [self.loadingShade addChild:label];
	}
	
	return self;
}

- (void) presentSceneWithKey:(NSString*)key
{
    [self.sceneManager loadSceneWithKey:key];
}


//- (void) update
//{
//    [super update];
//    
//    float fakeProgress = sinf([B3DTime timeElapsed]*2);
//    fakeProgress = (fakeProgress + 1.0f) * 0.5f;
//    [self.loadingCircle setProgress:fakeProgress];
//}

#pragma mark - B3DSceneLoadingDelegate

- (void) sceneLoadingDidBeganForScene:(B3DScene*)scene
{
    [self.loadingCircle setProgress:0.0f];
    self.loadingShade.hidden = NO;
}

- (void) sceneLoadingForScene:(B3DScene*)scene didAchieveProgress:(float)progress
{
    [self.loadingCircle setProgress:progress];
}

- (void) sceneLoadingDidFinishSuccessfulForScene:(B3DScene*)scene
{
    [self.sceneManager setSceneAsVisible:scene];
    self.loadingShade.hidden = YES;
}


@end
