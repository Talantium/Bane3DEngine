//
//  SGAppDelegate.m
//  SampleGame
//
//  Created by Andreas Hanft on 04.03.13.
//  Copyright (c) 2013 talantium.net. All rights reserved.
//

#import "SGAppDelegate.h"

#import "SGViewController.h"


@interface SGAppDelegate ()

- (void) setupInterface;

@end


@implementation SGAppDelegate

#pragma mark - Initialization

- (void) setupInterface
{
    // Create a simple window with black background without using nib file
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor blackColor];
    
    SGViewController* controller = [[SGViewController alloc] initWithNibName:nil bundle:nil];
    self.window.rootViewController = controller;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setupInterface];

    [self.window makeKeyAndVisible];

    return YES;
}

@end
