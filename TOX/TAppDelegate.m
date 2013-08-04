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

- (void) awakeFromNib {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults: [NSDictionary dictionaryWithObjectsAndKeys: [NSArray arrayWithObjects: @"Online", @"Busy", @"Away", nil], @"Status History", nil]];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    ToxCore* core = [ToxCore instance];
    NSString* nick = core.nick;
    if(nick == nil || nick.length == 0) {
        // we have no nick, so we need to set one!
    }
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    // make sure the TOX state is saved
    [[ToxCore instance] saveState];
}

@end
