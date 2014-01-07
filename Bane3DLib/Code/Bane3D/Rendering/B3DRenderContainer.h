//
//  B3DRenderContainer.h
//  Bane3DEngine
//
//  Created by Andreas Hanft on 14.11.13.
//  Copyright (c) 2013 talantium.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>

@class B3DLayer;
@class B3DVisibleNode;


@interface B3DRenderContainer : NSObject

+ (instancetype) containerWithNode:(B3DVisibleNode*)node;

@property (nonatomic, readonly,    weak) B3DVisibleNode*    prototypeNode;
@property (nonatomic, readwrite, assign) NSUInteger         capacity;
@property (nonatomic, readwrite, assign) GLsizei            vertexCount;

-(id) initWithNode:(B3DVisibleNode*)node;

- (BOOL) isSuitableForNode:(B3DVisibleNode*)node;
- (void) addNode:(B3DVisibleNode*)node;
- (void) refreshNodes;
- (void) updateBuffers;
- (void) drawInLayer:(B3DLayer*)layer;

@end


@interface B3DRenderContainer (Protected)

- (void) createBuffers;
- (void) tearDownBuffers;

@end
