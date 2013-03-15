//
//  SGButton.m
//  SampleGame
//
//  Created by Andreas Hanft on 15.03.13.
//  Copyright (c) 2013 talantium.net. All rights reserved.
//

#import "SGButton.h"

#import "SGCommonBaseScene.h"


@implementation SGButton

+ (SGButton*) buttonWithText:(NSString*)text
{
    SGButton* button = [[self alloc] initWithSize:CGSizeMake(196, 46) andColor:[B3DColor colorWithRGBHex:0xaaaaaa]];
    {
        B3DLabel* label = [[B3DLabel alloc] initWithFontNamed:SGCommonBaseSceneFontName
                                                         size:SGCommonBaseSceneButtonFontSize
                                                         text:text];
        label.color = [B3DColor blackColor];
        [label translateByX:12 andY:6 andZ:0.5];
        [button addSubNode:label];
    }
    
    return button;
}

@end
