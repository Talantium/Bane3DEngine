//
//  B3DRenderContainer.m
//  Bane3DEngine
//
//  Created by Andreas Hanft on 14.11.13.
//  Copyright (c) 2013 talantium.net. All rights reserved.
//

#import "B3DRenderContainer.h"

#import "B3DVisibleNode.h"


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
        _prototypeNode  = node;

        _nodesNew       = [[NSMutableArray alloc] initWithObjects:node, nil];
        _nodesPresent   = [[NSMutableArray alloc] init];
        
        _capacity       = 1;
    }
    
    return self;
}

- (void) dealloc
{
    [self tearDownBuffers];
}

#pragma mark - Buffer Handling

- (void) createBuffers
{}

- (void) tearDownBuffers
{}

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
        [self createBuffers];

        [self updateBufferWithNodesInSet:_indexesToUpdate];
        _indexesToUpdate = nil;
    }
}

- (void) updateBufferWithNodesInSet:(NSSet*)set
{}

- (void) drawInLayer:(B3DLayer*)layer
{}

@end
