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

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Start up the Tox core
    [[ToxCore instance] start];
    
    NSLog(@"public key: %@", [ToxCore instance].public_key);
}

@end
