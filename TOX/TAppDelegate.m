//
//  TAppDelegate.m
//  TOX
//
//  Created by Daniel Parnell on 30/07/13.
//  Copyright (c) 2013 Daniel Parnell. All rights reserved.
//

#import "TAppDelegate.h"
#import "ToxCore.h"
#import "ToxController.h"
#import "ToxWelcomeWindowController.h"

@implementation TAppDelegate

#pragma mark -
#pragma mark Delegate methods

- (void) awakeFromNib {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults: [ToxController defaultValues]];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSString* nick = [[NSUserDefaults standardUserDefaults] objectForKey: @"Nickname"];
    if(nick == nil || nick.length == 0) {
        // we have no nick, so we need to set one!
        [ToxWelcomeWindowController new];
    } else {
        [[ToxCore instance] setNick: nick];
    }
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    // make sure the TOX state is saved
}

@end
