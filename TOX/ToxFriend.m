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

- (id) initWithCoder:(NSCoder*) coder {
    self = [super init];
    if(self) {
        ToxCore* core = [ToxCore instance];
        
        _public_key = [coder decodeObjectForKey: @"public_key"];
        _name = [coder decodeObjectForKey: @"name"];
        _alias = [coder decodeObjectForKey: @"alias"];
        _status_message = [coder decodeObjectForKey: @"status_message"];

        // TODO: this should probably handle the case where the add fails
        _friend_number = [core addFriendWithoutRequest: _public_key error: nil];
        _status_kind = [core friendStatusKind: _friend_number error: nil];
    }

    return self;
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
            _status_kind = [core friendStatusKind: friend_number error: nil];
            
            if(_name == nil || _name.length == 0) {
                _name = NSLocalizedString(@"Unknown", @"Unknown user name");
            }
        }
    
        return self;
    }
    
    return nil;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject: _public_key forKey: @"public_key"];
    if(_name) {
        [coder encodeObject: _name forKey: @"name"];
    }
    if(_alias) {
        [coder encodeObject: _alias forKey: @"alias"];
    }
    if(_status_message) {
        [coder encodeObject: _status_message forKey: @"status_nessage"];
    }
}

- (void) updateStatusImage {
    [self willChangeValueForKey: @"status_image"];
    
    [self didChangeValueForKey: @"status_image"];
}

#pragma mark -
#pragma mark Properties

- (void) setStatus_kind:(NSString*)status_kind {
    [self willChangeValueForKey: @"status_image"];
    _status_kind = status_kind;
    [self didChangeValueForKey: @"status_image"];
}

- (NSImage*) status_image {
    ToxCore* core = [ToxCore instance];
    NSString* status = [core friendStatusKind: _friend_number error: nil];
    
    if(status == kToxUserOnline) {
        return [NSImage imageNamed: @"online"];
    } else if(status == kToxUserBusy) {
        return [NSImage imageNamed: @"busy"];
    } else if(status == kToxUserAway) {
        return [NSImage imageNamed: @"away"];
    } else if(status == kToxUserInvalid) {
        if([core friendStatusCode: _friend_number] == 4) {
            return [NSImage imageNamed: @"online"];
        }
    }
    
    return [NSImage imageNamed: @"offline"];
}

@end
