//
//  B3DVertexBuffer.m
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

#import "B3DVertexBuffer.h"

#import "B3DAsset+Protected.h"


@implementation B3DVertexBuffer

- (id) initWithMeshName:(NSString*)name
{
	self = [super initWithVolatileResourceNamed:[NSString stringWithFormat:@"B3DVertexBuffer_%@", name]];
	if (self != nil)
	{
        _target = GL_ARRAY_BUFFER;
    }
	
	return self;
}


- (void) setData:(const GLvoid*)data size:(GLsizeiptr)size usage:(GLenum)usage
{
    glBufferData(_target, size, data, usage);
}


- (void) enable
{
    [super enable];
    
    if (_target == GL_ARRAY_BUFFER)
    {
        [_stateManager bindBuffer:_openGlName];
    }
    else if (_target == GL_ELEMENT_ARRAY_BUFFER)
    {
        [_stateManager bindIndexBuffer:_openGlName];
    }
}

- (void) disable
{
    [_stateManager clearBufferBindings];
    
    [super disable];
}


- (BOOL) loadContent
{
	if (_loaded)
	{
		return YES;
	}
		
    glGenBuffers(1, &_openGlName);
	_loaded = (_openGlName > 0);
	
	return _loaded;
}

- (void) unloadContent
{
	if (!_loaded)
	{
		return;
	}
	
	[self cleanUp];
	_loaded = NO;
}

- (void) cleanUp
{
    if ([_stateManager deleteBuffer:_openGlName])
    {
        _openGlName = 0;
    }
    
    [super cleanUp];
}


@end
