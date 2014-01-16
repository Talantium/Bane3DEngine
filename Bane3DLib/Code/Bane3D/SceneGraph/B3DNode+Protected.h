//
//  B3DNode+Protected.h
//  Bane3D
//
//  Created by Andreas Hanft on 06.04.11.
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

#import "B3DNode.h"
#import "B3DDatatypes.h"
#import "B3DLayer.h"


/**
 *	Protected iVars for subclasses to be able to bypass properties and thus
 *  speed up access.
 */
@interface B3DNode ()
{
  @protected
    BOOL					_hidden;
    BOOL					_parentHidden;
    BOOL					_transformDirty;
    BOOL                    _hasSceneGraphChanges;
    
    NSMutableDictionary*    _assetTokens;
    NSString*				_name;
    
    B3DScene*				__weak _scene;
    B3DLayer*				__weak _layer;
    B3DNode*                __weak _parent;
    NSArray*				_children;
    NSMutableArray*			_childrenMutable;
    Bane3DEngine*           __weak _engine;
}

- (void) updateSceneGraphHierarchy;
- (void) recursivelyUpdateSceneGraphHierarchy;

- (void) updateWithSceneGraphInfo:(B3DSceneGraphInfo)info;

@end
