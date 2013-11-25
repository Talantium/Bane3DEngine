//
//  B3DLayer.m
//  Bane3DEngine
//
//  Created by Andreas Hanft on 08.11.13.
//  Copyright (c) 2013 talantium.net. All rights reserved.
//

#import "B3DLayer.h"

#import "B3DNode+Protected.h"
#import "B3DCamera.h"
#import "B3DVisibleNode.h"
#import "B3DLayerRenderer.h"


@interface B3DLayer ()

@property (nonatomic, readwrite, strong) B3DLayerRenderer* renderer;

@end


@implementation B3DLayer

+ (instancetype) layer
{
    return [[self alloc] init];
}

+ (instancetype) layerWithCamera:(B3DCamera*)camera
{
    return [[self alloc] initWithCamera:camera];
}

- (id) init
{
    return [self initWithCamera:[B3DCameraPerspective camera]];
}

- (id) initWithCamera:(B3DCamera*)camera
{
    self = [super init];
    if (self)
    {
        _camera = camera;

        _renderer = [[B3DLayerRenderer alloc] initWithLayer:self];
        _layer  = self;

        [self addChild:_camera];
    }

    return self;
}

- (void) nodeWasAddedToSceneGraph:(B3DNode*)node
{
    if ([node isKindOfClass:[B3DVisibleNode class]])
    {
        [_renderer addNode:(B3DVisibleNode*)node];
    }
}

- (void) nodeWasRemovedFromSceneGraph:(B3DNode*)node
{
    if ([node isKindOfClass:[B3DVisibleNode class]])
    {
        [_renderer removeNode:(B3DVisibleNode*)node];
    }
}

- (void)draw
{
    [_renderer draw];
}


@end
