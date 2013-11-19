//
//  B3DLayerRenderer.m
//  Bane3DEngine
//
//  Created by Andreas Hanft on 13.11.13.
//  Copyright (c) 2013 talantium.net. All rights reserved.
//

#import "B3DLayerRenderer.h"

#import "B3DNode.h"
#import "B3DVisibleNode.h"
#import "B3DRenderContainer.h"


@interface B3DLayerRenderer ()

@property (nonatomic, readwrite,   weak) B3DLayer* layer;
@property (nonatomic, readwrite, assign, getter = isDirty) BOOL dirty;

@property (nonatomic, readwrite, strong) NSMutableArray* nodes;
@property (nonatomic, readwrite, strong) NSMutableArray* container;

@end


@implementation B3DLayerRenderer

- (id)initWithLayer:(B3DLayer*)layer
{
    self = [super init];
    if (self)
    {
        _layer      = layer;
        _nodes      = [NSMutableArray array];
        _container  = [NSMutableArray array];
    }
    
    return self;
}

- (void) addNode:(B3DVisibleNode*)node
{
    if ([_nodes indexOfObject:node] == NSNotFound)
    {
        [_nodes addObject:node];
    }
    
    _dirty = YES;
}

- (void) removeNode:(B3DVisibleNode*)node
{
    NSUInteger index = [_nodes indexOfObject:node];
    if (index != NSNotFound)
    {
        [_nodes removeObjectAtIndex:index];
        
        _dirty = YES;
    }
}

- (void) draw
{
    if ([self resortNodesIfNeeded])
    {
        [self reassignContainer];
    }
    
    for (B3DRenderContainer* container in _container)
    {
        [container updateBuffers];
        [container drawInLayer:_layer];
    }
}

- (BOOL) resortNodesIfNeeded
{
    BOOL needResorting = _dirty;
    
    if (needResorting == NO)
    {
        for (B3DVisibleNode* node in _nodes)
        {
            if ([node hasSceneGraphChanges])
            {
                needResorting = YES;
                break;
            }
        }
    }
    
    if (needResorting)
    {
        [_nodes sortedArrayUsingSelector:@selector(compareByZValueDescending:)];
        _dirty = NO;
        
        return YES;
    }
    
    return NO;
}

- (void) reassignContainer
{
    NSUInteger index = 0;
    B3DRenderContainer* container = ((_container.count > 0) ? _container[index] : nil);
    BOOL lastContainerWasNew = NO;
    
    for (B3DVisibleNode* node in _nodes)
    {
        if ([container isSuitableForNode:node])
        {
            [container addNode:node];
        }
        else
        {
            if ((index + 1) < _container.count
                && [_container[(index + 1)] isSuitableForNode:node])
            {
                index++;
                container = _container[index];
                [container addNode:node];
                lastContainerWasNew = NO;
            }
            else
            {
                if (lastContainerWasNew) index++;
                
                container = [B3DRenderContainer containerWithNode:node];
                [_container insertObject:container atIndex:index];
                lastContainerWasNew = YES;
            }
        }
    }
    
    NSUInteger location = index + 1;
    NSUInteger length = _container.count - location;
    if (length > 0)
    {
        [_container removeObjectsInRange:NSMakeRange(location, length)];
    }
    
    for (B3DRenderContainer* container in _container)
    {
        [container refreshNodes];
    }
}


@end
