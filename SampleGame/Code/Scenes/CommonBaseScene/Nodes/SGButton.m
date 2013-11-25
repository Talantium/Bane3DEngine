//
//  SGButton.m
//  SampleGame
//
//  Created by Andreas Hanft on 15.03.13.
//  Copyright (c) 2013 talantium.net. All rights reserved.
//

#import "SGButton.h"

#import "SGCommonBaseScene.h"


const UIEdgeInsets SGButtonDefaultPadding = {0, 6, 0, 6};


@implementation SGButton

+ (SGButton*) buttonWithText:(NSString*)text
{
    SGButton* button = [[self alloc] initWithSize:CGSizeMake(156, 42) color:[B3DColor colorWithRGBHex:0xaaaaaa] text:text];
    
    return button;
}

- (id) initWithSize:(CGSize)size color:(B3DColor*)baseColor text:(NSString*)text
{
    self = [super initWithSize:size color:baseColor];
    if (self)
    {
        _textAlignment  = SGButtonTextAlignmentCenter;
        _padding        = SGButtonDefaultPadding;
        
        _label = [[B3DLabel alloc] initWithFontNamed:SGCommonBaseSceneFontName
                                                size:SGCommonBaseSceneButtonFontSize
                                                text:text];
        {
            _label.color = [B3DColor blackColor];
            [_label translateByX:0 y:0 z:0.5];
        }
//        [self addChild:_label];

        [self updateWithBlock:^(B3DNode *node, double deltaTime)
        {
            CGSize size = ((B3DSprite*)node).size;
            CGSize labelSize = _label.size;
            switch (_textAlignment)
            {
                case SGButtonTextAlignmentLeft:
                    _label.position = GLKVector3Make(_padding.left, (int) (size.height/2 - labelSize.height/2), _label.position.z);
                    break;

                case SGButtonTextAlignmentCenter:
                    _label.position = GLKVector3Make((int) (size.width/2 - labelSize.width/2), (int) (size.height/2 - labelSize.height/2), _label.position.z);
                    break;

                case SGButtonTextAlignmentRight:
                    _label.position = GLKVector3Make(size.width - labelSize.width - _padding.right, (int) (size.height/2 - labelSize.height/2), _label.position.z);
                    break;
                    
                default:
                    break;
            }
        }];
    }
    
    return self;
}

@end
