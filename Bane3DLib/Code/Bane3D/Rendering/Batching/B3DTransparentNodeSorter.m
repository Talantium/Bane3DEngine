//
//  B3DTransparentNodeSorter.m
//  Bane3D
//
//  Created by Andreas Hanft on 09.12.11.
//
//
//  Copyright (C) 2012 Andreas Hanft (talantium.net)
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included
//  in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
//  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

#import "B3DTransparentNodeSorter.h"

#import "B3DSpriteBatcher.h"
#import "B3DVisibleNode.h"
#import "B3DAssert.h"
#import "B3DMaterial.h"


@interface B3DTransparentNodeSorter ()
{
    @private
        B3DSpriteBatcher*               _spriteBatcher;
        NSMutableArray*                 _transparentNodes;
        
        NSMutableArray*                 _currentStrideArray;
        B3DVisibleNode*                 _lastNode;
}

@end


@implementation B3DTransparentNodeSorter

@dynamic hasNodes;


#pragma mark - Con-/Destructor

// Designated initialiser
- (id) initWithSharedBatcher:(B3DSpriteBatcher*)spriteBatcher
{
    self = [super init];
    if (self)
    {
        _spriteBatcher      = spriteBatcher;
        _transparentNodes   = [[NSMutableArray alloc] init];
        _currentStrideArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}


#pragma mark - Rendering

- (BOOL) hasNodes
{
    return (_transparentNodes.count > 0);
}

- (void) addNode:(B3DVisibleNode*)node
{
    [_transparentNodes addObject:node];
    
#if DEBUG_PRINT_STATS_BATCHING
    _nodeCount++;
#endif
}

- (void) render
{
    // Sort by Z position and try to render them in batches
    // For performance reason there are as less method calls as possible and 
    // therefore some duplicate code...
    for (B3DVisibleNode* node in [_transparentNodes sortedArrayUsingSelector:@selector(compareByZValueDescending:)])
    {
        if (NO)//node.isBatchable == NO)
        {
            // Render any previously saved nodes
            if (_currentStrideArray.count > 0)
            {
                [_spriteBatcher renderSpriteArray:_currentStrideArray];
                [_currentStrideArray removeAllObjects];
            }
            else
            {
//                [_lastNode render];
#if DEBUG_PRINT_STATS_BATCHING
                if (_lastNode)
                    _nodeCountSingle++;
#endif
            }
            
            // Render the current node itself
//            [node render];
#if DEBUG_PRINT_STATS_BATCHING
            if (node)
                _nodeCountSingle++;
#endif
            _lastNode = nil;
        }
        else // node is batchable
        {
            if (_lastNode == nil)
            {
                _lastNode = node;
            }
            else // _lastNode not nil
            {
                if (_lastNode.material.renderID == node.material.renderID)
                {
                    // If no stride with current renderID present, add lastnode first
                    if (_currentStrideArray.count == 0)
                    {
                        [_currentStrideArray addObject:_lastNode];
#if DEBUG_PRINT_STATS_BATCHING
                        if (_lastNode)
                            _nodeCountBatched++;
#endif
                    }
                    
                    // Add current node to stride
                    [_currentStrideArray addObject:node];
#if DEBUG_PRINT_STATS_BATCHING
                    if (node)
                        _nodeCountBatched++;
#endif
                    _lastNode = node;

                }
                else // renderIDs do not match
                {
                    // Render any previousely saved nodes
                    if (_currentStrideArray.count > 0)
                    {
                        [_spriteBatcher renderSpriteArray:_currentStrideArray];
                        [_currentStrideArray removeAllObjects];
                    }
                    else
                    {
//                        [_lastNode render];
#if DEBUG_PRINT_STATS_BATCHING
                        if (_lastNode)
                            _nodeCountSingle++;
#endif
                    }
                    
                    _lastNode = node;
                }
            }
        }
    }
    
    // Clear any still present and not rendered nodes
    if (_currentStrideArray.count > 0)
    {
        [_spriteBatcher renderSpriteArray:_currentStrideArray];
        [_currentStrideArray removeAllObjects];
    }
    else
    {
//        [_lastNode render];
#if DEBUG_PRINT_STATS_BATCHING
        if (_lastNode)
            _nodeCountSingle++;
#endif
    }
    
    // Clear state for next run
    [_transparentNodes removeAllObjects];
    _lastNode = nil;
    
#if DEBUG_PRINT_STATS_BATCHING
    _nodeCountLastFrame = _nodeCount;
    _nodeCountBatchedLastFrame = _nodeCountBatched;
    _nodeCountSingleLastFrame = _nodeCountSingle;
    
    _nodeCount = 0;
    _nodeCountBatched = 0;
    _nodeCountSingle = 0;
#endif
}


@end
