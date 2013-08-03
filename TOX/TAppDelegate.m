//
//  TAppDelegate.m
//  TOX
//
//  Created by Daniel Parnell on 30/07/13.
//  Copyright (c) 2013 Daniel Parnell. All rights reserved.
//

#import "TAppDelegate.h"
#import "ToxCore.h"
#import "ToxFriendRequestWindowController.h"

@implementation TAppDelegate

#pragma mark -
#pragma mark Notifications

- (void) gotNotification:(NSNotification*)notification {
    NSLog(@"got: %@", notification);
}

- (void) connected:(NSNotification*) notification {
    self.connected = YES;
}

- (void) disconnected:(NSNotification*) notification {
    self.connected = NO;
}

- (void) gotFriendRequest:(NSNotification*)notifcation {
    [ToxFriendRequestWindowController newWithFriendRequest: [notifcation userInfo]];
}

#pragma mark -
#pragma mark Alert finished

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    [[alert window] orderOut: nil];
}

#pragma mark -
#pragma mark Delegate methods

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSError* error = nil;
    // Start up the Tox core
    ToxCore* core = [ToxCore instance];
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    
    [self willChangeValueForKey: @"nick"];
    _nick = core.public_key;
    [self didChangeValueForKey: @"nick"];
    
    [center addObserver: self selector: @selector(gotNotification:) name: nil object: core];
    
    [center addObserver: self selector: @selector(connected:) name: kToxConnected object: core];
    [center addObserver: self selector: @selector(disconnected:) name: kToxDisconnected object: core];
    [center addObserver: self selector: @selector(gotFriendRequest:) name: kToxFriendRequest object: core];
    
    if(![core start: [NSURL URLWithString: @"tox://198.46.136.167:33445/728925473812C7AAC482BE7250BCCAD0B8CB9F737BF3D42ABD34459C1768F854"] error: &error]) {
        [[NSAlert alertWithError: error] beginSheetModalForWindow: self.window
                                                    modalDelegate: self
                                                   didEndSelector: @selector(alertDidEnd:returnCode:contextInfo:)
                                                      contextInfo: nil];
    }
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    // make sure the TOX state is saved
    [[ToxCore instance] saveState];
}

@end
