//
//  ToxController.m
//  TOX
//
//  Created by Daniel Parnell on 4/08/13.
//  Copyright (c) 2013 Daniel Parnell. All rights reserved.
//

#import "ToxController.h"
#import "ToxCore.h"
#import "ToxFriendRequestWindowController.h"
#import "ToxFriend.h"

@implementation ToxController

static NSDictionary* defaults_dict = nil;
+ (NSDictionary*) defaultValues {
    if(defaults_dict == nil) {
        NSString *localizedPath = [[NSBundle mainBundle] pathForResource: @"Defaults" ofType:@"plist"];
        NSData* plistData = [NSData dataWithContentsOfFile:localizedPath];
    
        defaults_dict = [NSPropertyListSerialization propertyListWithData: plistData options: NSPropertyListImmutable format: nil error: nil];
    }
    
    return defaults_dict;
}

- (id)init
{
    self = [super init];
    if (self) {
        _friends = [NSMutableArray new];
        _status_icon = [NSImage imageNamed: @"offline"];
    }
    return self;
}

- (void) awakeFromNib {
    [self start];
}

- (void) start {
    NSError* error = nil;
    // Start up the Tox core
    ToxCore* core = [ToxCore instance];
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    
    [self willChangeValueForKey: @"nick"];
    _nick = core.public_key;
    [self didChangeValueForKey: @"nick"];
    NSLog(@"_nick = %@", _nick);
    
    [center addObserver: self selector: @selector(gotNotification:) name: nil object: core];
    
    [center addObserver: self selector: @selector(connected:) name: kToxConnected object: core];
    [center addObserver: self selector: @selector(disconnected:) name: kToxDisconnected object: core];
    [center addObserver: self selector: @selector(gotFriendRequest:) name: kToxFriendRequest object: core];
    [center addObserver: self selector: @selector(friendStatusChanged:) name: kToxFriendStatusChanged object: core];
    [center addObserver: self selector: @selector(friendNickChanged:) name: kToxFriendNickChanged object: core];

    NSArray* dht_hosts = [[ToxController defaultValues] objectForKey: @"DHT Bootstrap Hosts"];
    NSString* dht_host = [dht_hosts objectAtIndex: arc4random() % dht_hosts.count];
    if(![core start: [NSURL URLWithString: dht_host] error: &error]) {
        [[NSAlert alertWithError: error] beginSheetModalForWindow: self.window
                                                    modalDelegate: self
                                                   didEndSelector: @selector(alertDidEnd:returnCode:contextInfo:)
                                                      contextInfo: nil];
    }
    
    [core enumerateFriends];
}

#pragma mark -
#pragma mark Notifications

- (void) gotNotification:(NSNotification*)notification {
    NSLog(@"got: %@", notification);
}

- (void) connected:(NSNotification*) notification {
    self.connected = YES;
    self.status_icon = [NSImage imageNamed: @"online"];
}

- (void) disconnected:(NSNotification*) notification {
    self.connected = NO;
    self.status_icon = [NSImage imageNamed: @"offline"];
}

- (void) gotFriendRequest:(NSNotification*)notifcation {
    NSString* client_id = [[notifcation userInfo] objectForKey: kToxPublicKey];
    if([[ToxCore instance] friendNumber: client_id error: nil] == -1) {
        [ToxFriendRequestWindowController newWithFriendRequest: [notifcation userInfo]];
    }
}

- (void) friendStatusChanged:(NSNotification*)notification {
    NSDictionary* dict = [notification userInfo];
    int friend_num = [[dict objectForKey: kToxFriendNumber] intValue];
    NSString* status = [dict objectForKey: kToxNewFriendStatus];
    
    ToxFriend* friend;
    
    NSUInteger index = [_friends indexOfObjectPassingTest:^BOOL(ToxFriend* obj, NSUInteger idx, BOOL *stop) {
        if(obj.friend_number == friend_num) {
            return YES;
        }
        
        return NO;
    }];

    if(index == NSNotFound) {
        friend = [ToxFriend newWithFriendNumber: friend_num];
        if(friend) {
            friend.status_message = status;
            
            NSIndexSet* index_set = [NSIndexSet indexSetWithIndex: [_friends count]];
            [self willChange: NSKeyValueChangeInsertion valuesAtIndexes: index_set forKey: @"friends"];
            [_friends addObject: friend];
            [self didChange: NSKeyValueChangeInsertion valuesAtIndexes: index_set forKey: @"friends"];
        }
    } else {
        friend = [_friends objectAtIndex: index];
        friend.status_message = status;
    }
}

- (void) friendNickChanged:(NSNotification*)notification {
    NSDictionary* dict = [notification userInfo];
    int friend_num = [[dict objectForKey: kToxFriendNumber] intValue];
    NSString* nick = [dict objectForKey: kToxNewFriendNick];
    
    ToxFriend* friend;
    
    NSUInteger index = [_friends indexOfObjectPassingTest:^BOOL(ToxFriend* obj, NSUInteger idx, BOOL *stop) {
        if(obj.friend_number == friend_num) {
            return YES;
        }
        
        return NO;
    }];
    
    if(index == NSNotFound) {
        friend = [ToxFriend newWithFriendNumber: friend_num];
        if(friend) {
            friend.name = nick;
            NSIndexSet* index_set = [NSIndexSet indexSetWithIndex: [_friends count]];
            [self willChange: NSKeyValueChangeInsertion valuesAtIndexes: index_set forKey: @"friends"];
            [_friends addObject: friend];
            [self didChange: NSKeyValueChangeInsertion valuesAtIndexes: index_set forKey: @"friends"];
        }
    } else {
        friend = [_friends objectAtIndex: index];
        friend.name = nick;
    }
}


#pragma mark -
#pragma mark Alert finished

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    [[alert window] orderOut: nil];
}

#pragma mark -
#pragma mark properties

- (void) setStatus:(NSString *)status {
    _status = status;
    ToxCore* core = [ToxCore instance];
    core.user_status = status;
}

#pragma mark -
#pragma mark Actions

- (IBAction) copyPublicKeyToClipboard:(id)sender {
    NSPasteboard* pb = [NSPasteboard generalPasteboard];
    [pb clearContents];
    [pb setString: [[ToxCore instance] public_key] forType: NSPasteboardTypeString];
}


@end
