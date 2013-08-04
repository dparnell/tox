//
//  ToxFriend.m
//  TOX
//
//  Created by Daniel Parnell on 4/08/13.
//  Copyright (c) 2013 Daniel Parnell. All rights reserved.
//

#import "ToxFriend.h"
#import "ToxCore.h"

@implementation ToxFriend

+ (ToxFriend*) newWithFriendNumber:(int)friend_number {
    return [[ToxFriend alloc] initWithFriendNumber: friend_number];
}

- (id) initWithFriendNumber:(int)friend_number {
    ToxCore* core = [ToxCore instance];
    
    NSString* client_id = [core clientIdForFriend: friend_number error: nil];
    if(client_id) {
        self = [super init];
        if(self) {
            _friend_number = friend_number;
            _public_key = client_id;
            _name = [core friendName: friend_number error: nil];
            _status_message = [core friendStatus: friend_number error: nil];
            if(_name == nil || _name.length == 0) {
                _name = NSLocalizedString(@"Unknown", @"Unknown user name");
            }
        }
    
        return self;
    }
    
    return nil;
}

- (void) updateStatusImage {
    [self willChangeValueForKey: @"status_image"];
    
    [self didChangeValueForKey: @"status_image"];
}

#pragma mark -
#pragma mark Properties

- (NSImage*) status_image {
    int status = [[ToxCore instance] friendStatusCode: _friend_number];
    
    if(status == 4) {
        return [NSImage imageNamed: @"online"];
    }
    
    return [NSImage imageNamed: @"offline"];
}

@end
