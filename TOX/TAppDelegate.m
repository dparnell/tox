//
//  TAppDelegate.m
//  TOX
//
//  Created by Daniel Parnell on 30/07/13.
//  Copyright (c) 2013 Daniel Parnell. All rights reserved.
//

#import "TAppDelegate.h"
#import "ToxCore.h"

@implementation TAppDelegate

- (void) gotNotification:(NSNotification*)notification {
    NSLog(@"got: %@", notification);
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSError* error = nil;
    // Start up the Tox core
    if([[ToxCore instance] start: [NSURL URLWithString: @"tox://198.46.136.167:33445/728925473812C7AAC482BE7250BCCAD0B8CB9F737BF3D42ABD34459C1768F854"] error: &error]) {
        NSLog(@"public key: %@", [ToxCore instance].public_key);
    
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(gotNotification:) name: nil object: [ToxCore instance]];
    } else {
        NSLog(@"FAILED: %@", error);
    }
}

@end
