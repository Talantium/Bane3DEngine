//
//  B3DSceneLoadingDelegate.h
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

@class B3DScene;


@protocol B3DSceneLoadingDelegate <NSObject>

@required
	// After receiving one of the following messages, no more will be sent.
	// When loading finishes
	- (void) sceneLoadingDidFinishSuccessfulForScene:(B3DScene*)scene;
	// When loading fails
	- (void) sceneLoadingDidFailForScene:(B3DScene*)scene;

@optional
	// When loading begins
	- (void) sceneLoadingDidBeganForScene:(B3DScene*)scene;
	// Receive messages of progress during load (Range: [0.0 - 1.0])
	- (void) sceneLoadingForScene:(B3DScene*)scene didAchieveProgress:(float)progress;

@end