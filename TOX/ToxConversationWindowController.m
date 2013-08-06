//
//  ToxConversationWindowController.m
//  TOX
//
//  Created by Daniel Parnell on 4/08/13.
//  Copyright (c) 2013 Daniel Parnell. All rights reserved.
//

#import "ToxConversationWindowController.h"
#import "ToxController.h"
#import "ToxCore.h"

@interface ToxConversationWindowController ()

@end

@implementation ToxConversationWindowController {
    ToxFriend* me;
    WebScriptObject* scripting;
    NSMutableArray* pending_messages;
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
        
        me = [ToxFriend new];
        me.name = @"";
        
        [self showWindow: self];
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [[_web_view mainFrame] loadRequest:
     [NSURLRequest requestWithURL:
      [NSURL fileURLWithPath:
       [[NSBundle mainBundle] pathForResource:@"conversation" ofType:@"html"]]]];
    
    [self.window makeKeyAndOrderFront: self];
}

#pragma mark -
#pragma mark Delegate methods

- (void)windowWillClose:(id)sender {
    [[ToxController instance] removeConversionWithFriendNumber: _friend_number];
}

#pragma mark -
#pragma mark methods

- (void) appendMessage:(NSString*)message from:(NSString*)from {
    NSArray* args = [NSArray arrayWithObjects: from, message, nil];
    [scripting callWebScriptMethod:@"add_message" withArguments:args];
}

- (void) addMessage:(NSDictionary*)message {
    if(scripting) {
        NSNumber* from_number = [message objectForKey: kToxFriendNumber];
        ToxFriend* sender;
        
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
        
        [self appendMessage: [message objectForKey: kToxMessageString] from: sender.name];
    } else {
        if(pending_messages == nil) {
            pending_messages = [NSMutableArray new];
        }
        [pending_messages addObject: message];
    }
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
            [self appendMessage: _to_send from: @""];
            
            self.to_send = nil;
        } else {
            [[NSAlert alertWithError: error] beginSheetModalForWindow: self.window
                                                        modalDelegate: self
                                                       didEndSelector: @selector(alertDidEnd:returnCode:contextInfo:)
                                                          contextInfo: nil];
        }
    }
}

#pragma mark -
#pragma mark WebKit delegate methods

- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element
    defaultMenuItems:(NSArray *)defaultMenuItems
{
    // disable right-click context menu
    return nil;
}

- (void)webView:(WebView *)sender didClearWindowObject:(WebScriptObject *)windowObject forFrame:(WebFrame *)frame {
    scripting = windowObject;
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    if(pending_messages) {
        for(NSDictionary* msg in pending_messages) {
            [self addMessage: msg];
        }
    
        pending_messages = nil;
    }
}

@end
