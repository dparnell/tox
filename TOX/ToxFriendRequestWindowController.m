//
//  ToxFriendRequestWindowController.m
//  TOX
//
//  Created by Daniel Parnell on 3/08/13.
//  Copyright (c) 2013 Daniel Parnell. All rights reserved.
//

#import "ToxFriendRequestWindowController.h"
#import "ToxCore.h"

@interface ToxFriendRequestWindowController ()

@end

@implementation ToxFriendRequestWindowController {
    ToxFriendRequestWindowController* self_reference;
    BOOL accepted;
}

+ (ToxFriendRequestWindowController*) newWithFriendRequest:(NSDictionary*)dict {
    return [[ToxFriendRequestWindowController new] initWithFriendRequest: dict];
}

- (id) initWithFriendRequest:(NSDictionary*)dict {
    self = [super initWithWindowNibName: @"ToxFriendRequest"];
    if(self) {
        [self willChangeValueForKey: @"client_id"];
        _client_id = [dict objectForKey: kToxPublicKey];
        [self didChangeValueForKey: @"client_id"];
        
        [self willChangeValueForKey: @"message"];
        _message = [dict objectForKey: kToxMessageString];
        [self didChangeValueForKey: @"message"];
        
        accepted = NO;
        self_reference = self;  // SMELL: YUCK!
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
    if(!accepted) {
        // TODO: add code to ignore the friend request
    }
    
    self_reference = nil;
}

#pragma mark -
#pragma mark Alert finished

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    [[alert window] orderOut: nil];
}

#pragma mark -
#pragma mark Actions

- (IBAction) acceptFriendRequest:(id)sender {
    NSError* error = nil;
    ToxCore* core = [ToxCore instance];
    int friend_id = [core acceptFriendRequestFrom: _client_id error: &error];
    
    if(friend_id >= 0) {
        [core saveState];
        accepted = YES;
        [self.window close];
    } else {
        [[NSAlert alertWithError: error] beginSheetModalForWindow: self.window
                                                    modalDelegate: self
                                                   didEndSelector: @selector(alertDidEnd:returnCode:contextInfo:)
                                                      contextInfo: nil];
    }
}

- (IBAction) ignoreFriendRequest:(id)sender {
    [self.window close];
}

@end
