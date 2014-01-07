//
//  B3DPoint.h
//  Bane3D
//
//  Created by Andreas Hanft on 04.10.13.
//  Copyright (c) 2013 talantium.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/glext.h>
#import <GLKit/GLKit.h>
#import <Bane3D/Rendering/B3DMeshContainer.h>


@interface B3DPoint : NSObject

@property (nonatomic, readwrite, assign) GLfloat x;
@property (nonatomic, readwrite, assign) GLfloat y;
@property (nonatomic, readwrite, assign) GLfloat z;

@property (nonatomic, readwrite, assign) GLushort u;
@property (nonatomic, readwrite, assign) GLushort v;


+ (instancetype) point;
+ (instancetype) pointWithPoint:(B3DPoint*)otherPoint;
+ (instancetype) pointWithVector:(GLKVector3)position uv:(CGPoint)uvCoords;

// Catmull Rom interpolation between point2 and point3 with the help of point1 and point4.
// Amount specifies a value between p2 and p3 with amount[0] = p2 and amount[1] = p3.
+ (B3DPoint*) interpolateWithPoint1:(B3DPoint*)point1 point2:(B3DPoint*)point2 point3:(B3DPoint*)point3 point4:(B3DPoint*)point4 amount:(GLfloat)amount;

- (B3DMeshVertexData) pointAsMeshData;

- (GLKVector3) positionAsVector3;

@end
