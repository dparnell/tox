//
//  ToxConversationWindowController.m
//  TOX
//
//  Created by Daniel Parnell on 4/08/13.
//  Copyright (c) 2013 Daniel Parnell. All rights reserved.
//

#import "ToxConversationWindowController.h"
#import "ToxController.h"
#import "ToxMessage.h"
#import "ToxCore.h"

@interface ToxConversationWindowController ()

@end

@implementation ToxConversationWindowController {
    ToxFriend* me;
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
        self.messages = [NSMutableArray new];
        
        me = [ToxFriend new];
        me.name = @"";
        
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

#pragma mark -
#pragma mark methods

- (void) appendMessage:(ToxMessage*)msg {
    NSIndexSet* index = [NSIndexSet indexSetWithIndex: _messages.count];
    [self willChange: NSKeyValueChangeInsertion valuesAtIndexes: index forKey: @"messages"];
    [_messages addObject: msg];
    [self didChange: NSKeyValueChangeInsertion valuesAtIndexes: index forKey: @"messages"];
}

- (void) addMessage:(NSDictionary*)message {
    NSNumber* from_number = [message objectForKey: kToxFriendNumber];
    id sender;
    
    if(from_number) {
        int friend_num = [from_number intValue];
        if(friend_num == _friend_number) {
            sender = _friend;
        } else {
            sender = [[ToxController instance] friendWithFriendNumber: friend_num];
        }
    } else {
        sender = me;
    }
    
    ToxMessage* msg = [ToxMessage newWithSender: sender message: [message objectForKey: kToxMessageString]];
    [self appendMessage: msg];
}

#pragma mark -
#pragma mark Alert finished

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    [[alert window] orderOut: nil];
}
#pragma mark -
#pragma mark Actions

- (IBAction) sendMessage:(id)sender {
    if(_to_send && _to_send.length > 0) {
        NSError* error = nil;
        if([[ToxCore instance] sendMessage: _to_send toFriend: _friend_number error: &error]) {
            ToxMessage* msg = [ToxMessage newWithSender: me message: _to_send];
            [self appendMessage: msg];
            
            self.to_send = nil;
        } else {
            [[NSAlert alertWithError: error] beginSheetModalForWindow: self.window
                                                        modalDelegate: self
                                                       didEndSelector: @selector(alertDidEnd:returnCode:contextInfo:)
                                                          contextInfo: nil];
        }
    }
}


@end
