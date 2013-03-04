//
//  B3DHelper.c
//  Bane3D
//
//  Created by Andreas Hanft on 07.04.11.
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

#import "B3DHelper.h"


void checkGLError(void)
{
    GLenum error = glGetError();
    if (error)
	{
        fprintf(stderr, "[CRITICAL] GL Error encountered: %x\n", error);
//        abort();
    }
}

void printGLKMatrix4(GLKMatrix4 matrix)
{
    LogDebug(@"    %f %f %f %f", matrix.m00, matrix.m01, matrix.m02, matrix.m03);
    LogDebug(@"    %f %f %f %f", matrix.m10, matrix.m11, matrix.m12, matrix.m13);
    LogDebug(@"    %f %f %f %f", matrix.m20, matrix.m21, matrix.m22, matrix.m23);
    LogDebug(@"    %f %f %f %f", matrix.m30, matrix.m31, matrix.m32, matrix.m33);
}
