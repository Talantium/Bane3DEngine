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
{
  @protected
    NSUInteger  _capacity;
    GLsizei     _vertexCount;

    GLuint      _vertexArrayObject;
    GLuint      _vertexBuffer;
    NSUInteger  _vertexBufferSize;
    NSUInteger  _defaultBufferSize;
    GLenum      _defaultBufferUsage;
}

+ (instancetype) containerWithNode:(B3DVisibleNode*)node;

@property (nonatomic, readonly,    weak) B3DVisibleNode*    prototypeNode;

- (id) initWithNode:(B3DVisibleNode*)node;

- (BOOL) isSuitableForNode:(B3DVisibleNode*)node;
- (void) addNode:(B3DVisibleNode*)node;
- (void) refreshNodes;
- (void) updateBuffers;
- (void) drawInLayer:(B3DLayer*)layer;

@end


@interface B3DRenderContainer (Protected)

- (void) createBuffers;
- (void) createBuffersWithVertexBufferSize:(NSUInteger)vertexBufferSize usage:(GLenum)usage;
- (void) configureVertexArrayObject;
- (void) tearDownBuffers;

@end
