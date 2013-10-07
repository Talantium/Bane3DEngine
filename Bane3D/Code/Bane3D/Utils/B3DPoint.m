//
//  B3DPoint.m
//  Bane3D
//
//  Created by Andreas Hanft on 04.10.13.
//  Copyright (c) 2013 talantium.net. All rights reserved.
//

#import "B3DPoint.h"


@implementation B3DPoint

+ (instancetype) point
{
    return [[self alloc] init];
}

+ (B3DPoint*) interpolateWithPoint1:(B3DPoint*)point1 point2:(B3DPoint*)point2 point3:(B3DPoint*)point3 point4:(B3DPoint*)point4 amount:(GLfloat)amount
{
    B3DPoint *point = [self point];
    point.x = [self catmullRomWithValue1:point1.x value2:point2.x value3:point3.x value4:point4.x amount:amount];
    point.y = [self catmullRomWithValue1:point1.y value2:point2.y value3:point3.y value4:point4.y amount:amount];
    point.z = [self catmullRomWithValue1:point1.z value2:point2.z value3:point3.z value4:point4.z amount:amount];
    
    return point;
}

+ (GLfloat) catmullRomWithValue1:(GLfloat)value1 value2:(GLfloat)value2 value3:(GLfloat)value3 value4:(GLfloat)value4 amount:(GLfloat)amount
{
    return  0.5f * ((2.0f * value2)
                    + (-value1 + value3) * amount
                    + (2.0f * value1 - 5.0f * value2 + 4.0f * value3 - value4) * powf(amount, 2)
                    + (-value1 + 3.0f * value2- 3.0f * value3 + value4) * powf(amount, 3));
}

- (B3DMeshVertexData) pointAsMeshData
{
    B3DMeshVertexData data;
    data.posX       = self.x;
    data.posY       = self.y;
    data.posZ       = self.z;
    
    data.texCoord0U = self.u;
    data.texCoord0V = self.v;
    
    return data;
}

@end
