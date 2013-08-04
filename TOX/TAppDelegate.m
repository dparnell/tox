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

#pragma mark -
#pragma mark Delegate methods

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    // make sure the TOX state is saved
    [[ToxCore instance] saveState];
}

@end
