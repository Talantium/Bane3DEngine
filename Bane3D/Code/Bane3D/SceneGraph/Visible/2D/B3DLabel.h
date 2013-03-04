//
//  B3DLabel.h
//  Bane3D
//
//  Created by Andreas Hanft on 14.01.13.
//  Copyright (c) 2013 talantium.net. All rights reserved.
//

#import <Bane3D/SceneGraph/Visible/B3DVisibleNode.h>


@interface B3DLabel : B3DVisibleNode

@property (nonatomic, readwrite, copy)  NSString*       text;

- (id) initWithText:(NSString*)text;
- (id) initWithFontNamed:(NSString*)fontName size:(CGFloat)size;
- (id) initWithFontNamed:(NSString*)fontName size:(CGFloat)size text:(NSString*)text;
- (id) initWithFont:(UIFont*)font text:(NSString*)text;

@end
