//
//  ToxConversationWindowController.m
//  TOX
//
//  Created by Daniel Parnell on 4/08/13.
//  Copyright (c) 2013 Daniel Parnell. All rights reserved.
//

#import "ToxConversationWindowController.h"
#import "ToxController.h"

@interface ToxConversationWindowController ()

@end

@implementation ToxConversationWindowController {
}

+ (ToxConversationWindowController*) newWithFriendNumber:(int)friend_number {
    return [[ToxConversationWindowController alloc] initWithFriendNumber: friend_number];
}

- (id)initWithFriendNumber:(int)friend_number
{
    self = [super initWithWindowNibName: @"ToxConversationWindow"];
    if (self) {
        self.friend_number = friend_number;
        self.friend = [[ToxController instance] friendWithFriendNumber: friend_number];
        
        [self showWindow: self];
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [self.window makeKeyAndOrderFront: self];
}

#pragma mark -
#pragma mark Delegate methods

- (void)windowWillClose:(id)sender {
    [[ToxController instance] removeConversionWithFriendNumber: _friend_number];
}

- (void) addMessage:(NSDictionary*)message {
    
}


@end
