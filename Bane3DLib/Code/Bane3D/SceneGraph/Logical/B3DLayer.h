//
//  B3DLayer.h
//  Bane3DEngine
//
//  Created by Andreas Hanft on 08.11.13.
//  Copyright (c) 2013 talantium.net. All rights reserved.
//

#import <Bane3D/SceneGraph/B3DNode.h>

@class B3DCamera;


@interface B3DLayer : B3DNode

+ (instancetype) layer;
+ (instancetype) layerWithCamera:(B3DCamera*)camera;

@property (nonatomic, readwrite, strong) B3DCamera* camera;

- (id) initWithCamera:(B3DCamera*)camera;

- (void) nodeWasAddedToSceneGraph:(B3DNode*)node;
- (void) nodeWasRemovedFromSceneGraph:(B3DNode*)node;

- (void)draw;

@end
