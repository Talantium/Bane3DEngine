//
//  B3DRenderContainer.m
//  Bane3DEngine
//
//  Created by Andreas Hanft on 14.11.13.
//  Copyright (c) 2013 talantium.net. All rights reserved.
//

#import "B3DRenderContainer.h"

#import "B3DVisibleNode.h"
#import "B3DMesh.h"


@interface B3DRenderContainer ()

@property (nonatomic, readwrite, strong) NSMutableArray* nodesNew;
@property (nonatomic, readwrite, strong) NSMutableArray* nodesPresent;
@property (nonatomic, readwrite, strong) NSSet*          indexesToUpdate;

@end


@implementation B3DRenderContainer

+ (instancetype) containerWithNode:(B3DVisibleNode*)node
{
    return [[[node classForRenderContainer] alloc] initWithNode:node];
}

-(id) initWithNode:(B3DVisibleNode*)node
{
    self = [super init];
    if (self)
    {
        NSParameterAssert(node);
        _prototypeNode      = node;

        _nodesNew           = [[NSMutableArray alloc] initWithObjects:node, nil];
        _nodesPresent       = [[NSMutableArray alloc] init];
        
        _capacity           = 1;

        _defaultBufferSize  = 0;
        _defaultBufferUsage = GL_STREAM_DRAW;
    }
    
    return self;
}

- (void) dealloc
{
    [self tearDownBuffers];
}

#pragma mark - Buffer Handling

- (void) createBuffers
{
    [self createBuffersWithVertexBufferSize:_defaultBufferSize usage:_defaultBufferUsage];
}

- (void) createBuffersWithVertexBufferSize:(NSUInteger)vertexBufferSize usage:(GLenum)usage
{
    if (_vertexArrayObject != 0) return;

    // Creating VAO's must be done on the main thread, see
    // http://stackoverflow.com/questions/7125257/can-vertex-array-objects-vaos-be-shared-across-eaglcontexts-in-opengl-es

    dispatch_block_t block = ^(void)
    {
        // Create and bind a vertex array object.
        glGenVertexArraysOES(1, &_vertexArrayObject);
        glBindVertexArrayOES(_vertexArrayObject);

        // Create buffer object
        glGenBuffers(1, &_vertexBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);

        if (vertexBufferSize > 0)
        {
            glBufferData(GL_ARRAY_BUFFER, vertexBufferSize, NULL, usage);
            _vertexBufferSize = vertexBufferSize;
        }

        [self configureVertexArrayObject];

        // Bind back to the default state.
        glBindVertexArrayOES(0);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
    };

    if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

- (void) configureVertexArrayObject
{}

- (void) tearDownBuffers
{
    if (_vertexBuffer != 0)
    {
        glDeleteBuffers(1, &_vertexBuffer);
        _vertexBuffer = 0;
        _vertexBufferSize = 0;
    }

    if (_vertexArrayObject != 0)
    {
        glDeleteVertexArraysOES(1, &_vertexArrayObject);
        _vertexArrayObject = 0;
    }
}

- (BOOL) isSuitableForNode:(B3DVisibleNode*)node
{
    if ([node classForRenderContainer] == [self class]
        && node.renderID == _prototypeNode.renderID
        && _nodesNew.count < _capacity)
    {
        return YES;
    }
    
    return NO;
}

- (void) addNode:(B3DVisibleNode*)node
{
#if DEBUG
    NSUInteger index = [_nodesNew indexOfObject:node];
    NSAssert((index == NSNotFound), @"Adding node twice!");
    if (index == NSNotFound)
#endif
    {
        [_nodesNew addObject:node];
    }
}

- (void) refreshNodes
{
    NSMutableSet* indexesToUpdate = [NSMutableSet set];
    
    BOOL nodesChanged = NO;
    
    B3DVisibleNode* newNode = nil;
    B3DVisibleNode* presentNode = nil;
    for (NSUInteger index = 0; index < _nodesNew.count; index++)
    {
        newNode = _nodesNew[index];
        presentNode = (index < _nodesPresent.count ? _nodesPresent[index] : nil);
        
        if (presentNode == nil)
        {
            NSAssert((index <= _nodesPresent.count), @"Adding node with invalid index to currentNodes");
            [_nodesPresent insertObject:newNode atIndex:index];
            nodesChanged = YES;
            [indexesToUpdate addObject:@(index)];
        }
        else if (newNode != presentNode)
        {
            [_nodesPresent replaceObjectAtIndex:index withObject:newNode];
            nodesChanged = YES;
            [indexesToUpdate addObject:@(index)];
        }
    }
    
    if (_nodesNew.count < _nodesPresent.count)
    {
        [_nodesPresent removeObjectsInRange:NSMakeRange(_nodesNew.count, _nodesPresent.count - _nodesNew.count)];
        nodesChanged = YES;
    }
    
    if (nodesChanged == NO)
    {
        for (NSUInteger index = 0; index < _nodesPresent.count; index++)
        {
            B3DVisibleNode* node = _nodesPresent[index];
            if (node.isDirty)
            {
                nodesChanged = YES;
                [indexesToUpdate addObject:@(index)];
            }
        }
    }
    
    if (nodesChanged)
    {
        _indexesToUpdate = indexesToUpdate;
    }
    
    [_nodesNew removeAllObjects];
}

- (void) updateBuffers
{
    if (_indexesToUpdate.count > 0)
    {
        [self updateBufferWithNodesInSet:_indexesToUpdate];
        _indexesToUpdate = nil;
    }
}

- (void) updateBufferWithNodesInSet:(NSSet*)set
{
    for (NSNumber* indexObj in set)
    {
        NSUInteger index = [indexObj unsignedIntegerValue];
        [self updateDataOfNode:_nodesPresent[index] atIndex:index];
    }
}

- (void) updateDataOfNode:(B3DVisibleNode*)node atIndex:(NSUInteger)index
{
    [node updateVerticeData];

    B3DMesh* mesh = node.mesh;
    BOOL rebuildBuffer = (mesh.vertexData.length > _vertexBufferSize);

    if (rebuildBuffer)
    {
        [self tearDownBuffers];
        [self createBuffers];
    }

    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);

    if (rebuildBuffer && _defaultBufferSize == 0)
    {
        GLsizeiptr size = mesh.vertexData.length;
        glBufferData(GL_ARRAY_BUFFER, size, mesh.vertexData.bytes, _defaultBufferUsage);

        _vertexBufferSize = size;
    }
    else
    {
        // http://www.khronos.org/registry/gles/extensions/EXT/EXT_map_buffer_range.txt
        GLvoid* buffer = glMapBufferRangeEXT(GL_ARRAY_BUFFER, 0, mesh.vertexData.length, GL_MAP_WRITE_BIT_EXT | GL_MAP_INVALIDATE_BUFFER_BIT_EXT);
        memcpy(buffer, mesh.vertexData.bytes, mesh.vertexData.length);
        glUnmapBufferOES(GL_ARRAY_BUFFER);

//        B3DSpriteVertexData* currentElementVertices = (B3DSpriteVertexData*) glMapBufferOES(GL_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
//        memcpy(currentElementVertices, self.prototypeNode.mesh.vertexData.bytes, size);
//        glUnmapBufferOES(GL_ARRAY_BUFFER);
    }

    _vertexCount = mesh.vertexCount;
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

- (void) drawInLayer:(B3DLayer*)layer
{}

@end
