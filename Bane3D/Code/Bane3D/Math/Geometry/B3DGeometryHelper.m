//
//  B3DGeometryHelper.m
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

#import <GLKit/GLKit.h>

#import "B3DGeometryHelper.h"


GLfloat distanceBetweenPoints(CGPoint firstPoint, CGPoint secondPoint)
{
	GLfloat distance;
	
	//Square difference in x
	GLfloat xDifferenceSquared = pow(firstPoint.x - secondPoint.x, 2);
	
	// Square difference in y
	GLfloat yDifferenceSquared = pow(firstPoint.y - secondPoint.y, 2);
	
	// Add and take Square root
	distance = sqrt(xDifferenceSquared + yDifferenceSquared);
	
	return distance;
}

BOOL lineIntersectsRect(CGPoint a, CGPoint b, CGRect rect)
{
	float lineSlope = (b.y - a.y) / (b.x - a.x);
	float yIntercept = a.y - lineSlope * a.x;
	float leftY = lineSlope * CGRectGetMinX(rect) + yIntercept;
	float rightY = lineSlope * CGRectGetMaxX(rect) + yIntercept;
	
	if (leftY >= CGRectGetMinY(rect) && leftY <= CGRectGetMaxY(rect))
		return YES;
	if (rightY >= CGRectGetMinY(rect) && rightY <= CGRectGetMaxY(rect))
		return YES;
	
	return NO;
}

BOOL circleIntersectsLineSegment(CGPoint centerPoint, float radius, CGPoint startPoint, CGPoint endPoint)
{
	GLKVector3 center = GLKVector3Make(centerPoint.x, centerPoint.y, 0.0f);
	GLKVector3 start = GLKVector3Make(startPoint.x, startPoint.y, 0.0f);
	GLKVector3 end = GLKVector3Make(endPoint.x, endPoint.y, 0.0f);
	
    GLKVector3 dir = GLKVector3Subtract(end, start);
    GLKVector3 diff = GLKVector3Subtract(center, start);
    GLfloat t = GLKVector3DotProduct(diff, dir) / GLKVector3DotProduct(dir, dir);

    if (t < 0.0f)
        t = 0.0f;
	
	if (t > 1.0f)
		t = 1.0f;
	
	GLKVector3 closest = GLKVector3Add(start, GLKVector3MultiplyScalar(dir, t));
	GLKVector3 d = GLKVector3Subtract(center, closest);
	float distsqr = GLKVector3DotProduct(d, d);
	
	return distsqr <= radius * radius;
}