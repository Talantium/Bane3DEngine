//
//  B3DLayerRenderer.h
//  Bane3DEngine
//
//  Created by Andreas Hanft on 13.11.13.
//  Copyright (c) 2013 talantium.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@class B3DLayer;
@class B3DVisibleNode;


@interface B3DLayerRenderer : NSObject

@property (nonatomic, readonly, weak) B3DLayer* layer;

// DI
- (id) initWithLayer:(B3DLayer*)layer;

- (void) addNode:(B3DVisibleNode*)node;
- (void) removeNode:(B3DVisibleNode*)node;

- (void) draw;

@end
