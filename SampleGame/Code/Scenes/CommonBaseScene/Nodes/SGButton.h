//
//  SGButton.h
//  SampleGame
//
//  Created by Andreas Hanft on 15.03.13.
//  Copyright (c) 2013 talantium.net. All rights reserved.
//

#import <Bane3D/Bane3D.h>


typedef enum
{
    SGButtonTextAlignmentLeft,
    SGButtonTextAlignmentCenter,
    SGButtonTextAlignmentRight
} SGButtonTextAlignment;


@interface SGButton : B3DGUIButton

@property (nonatomic, readwrite, strong) B3DLabel*              label;
@property (nonatomic, readwrite, assign) SGButtonTextAlignment  textAlignment;
@property (nonatomic, readwrite, assign) UIEdgeInsets           padding;

+ (SGButton*) buttonWithText:(NSString*)text;

@end
