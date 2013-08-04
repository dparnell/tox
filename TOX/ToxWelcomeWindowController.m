//
//  ToxWelcomeWindowController.m
//  TOX
//
//  Created by Daniel Parnell on 4/08/13.
//  Copyright (c) 2013 Daniel Parnell. All rights reserved.
//

#import "ToxWelcomeWindowController.h"
#import "ToxCore.h"

@interface ToxWelcomeWindowController ()

@end

@implementation ToxWelcomeWindowController {
    ToxWelcomeWindowController* self_reference;
}

- (id)init
{
    self = [super initWithWindowNibName: @"ToxWelcomeWindow"];
    if (self) {
        self_reference = self;  // SMELL: YUCK!
        
        [self showWindow: self];
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    NSWindow* window = self.window;
    CGFloat xPos = NSWidth([[window screen] frame])/2 - NSWidth([window frame])/2;
    CGFloat yPos = NSHeight([[window screen] frame])/2 - NSHeight([window frame])/2;
    [window setFrame:NSMakeRect(xPos, yPos, NSWidth([window frame]), NSHeight([window frame])) display:YES];
    
    
    [window makeKeyAndOrderFront: self];
}

#pragma mark -
#pragma mark Delegate methods

- (void)windowWillClose:(id)sender {
    self_reference = nil;
}

#pragma mark -
#pragma mark Properties

- (NSString*) public_key {
    return [[ToxCore instance] public_key];
}

- (NSString*) nick {
    return [[ToxCore instance] nick];
}

- (void) setNick:(NSString *)nick {
    [[NSUserDefaults standardUserDefaults] setObject: nick forKey: @"Nickname"];
    [[ToxCore instance] setNick: nick];
}

@end
