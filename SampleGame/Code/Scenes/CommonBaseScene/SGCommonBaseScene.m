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
const       float   SGCommonBaseSceneFontSize           = 18.0f;
const       float   SGCommonBaseSceneButtonFontSize     = 24.0f;


@interface SGCommonBaseScene ()

@property (nonatomic, readwrite, strong) SGLoadingCircle*   loadingCircle;
@property (nonatomic, readwrite, strong) B3DGUIImage*       loadingShade;

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
	self = [super init];
	if (self != nil)
	{
        CGSize screenSize = [UIApplication currentSize];
        
        self.handleSceneLoadingEvents = YES;
        
        self.loadingShade = [[B3DGUIImage alloc] initWithSize:screenSize
                                                     andColor:[B3DColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:0.8]];
        {
            [self.loadingShade translateByX:0 andY:0 andZ:-1];
            self.loadingShade.visible = NO;
        }
        [self addSubNode:self.loadingShade];
        
        
        self.loadingCircle = [SGLoadingCircle loadingCircle];
        [self.loadingCircle translateByX:4 andY:20 andZ:0.5];
        [self.loadingShade addSubNode:self.loadingCircle];
        
        
        B3DLabel* label = [[B3DLabel alloc] initWithFontNamed:SGCommonBaseSceneFontName
                                                         size:SGCommonBaseSceneFontSize
                                                         text:NSLocalizedString(@"SGCommonBaseSceneLoadingLabelText", nil)];
        {
            label.color = [B3DColor colorWithRGBHex:0xffffff];
            [label translateByX:4 andY:0 andZ:0.6];
        }
        [self.loadingShade addSubNode:label];
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
    self.loadingShade.visible = YES;
}

- (void) sceneLoadingForScene:(B3DScene*)scene didAchieveProgress:(float)progress
{
    [self.loadingCircle setProgress:progress];
}

- (void) sceneLoadingDidFinishSuccessfulForScene:(B3DScene*)scene
{
    [self.sceneManager setSceneAsVisible:scene];
    self.loadingShade.visible = NO;
}


@end
