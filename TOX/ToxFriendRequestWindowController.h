//
//  ToxFriendRequestWindowController.h
//  TOX
//
//  Created by Daniel Parnell on 3/08/13.
//  Copyright (c) 2013 Daniel Parnell. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ToxFriendRequestWindowController : NSWindowController

+ (ToxFriendRequestWindowController*) newWithFriendRequest:(NSDictionary*)dict;

- (IBAction) acceptFriendRequest:(id)sender;
- (IBAction) ignoreFriendRequest:(id)sender;

@property (readonly) NSString* client_id;
@property (readonly) NSString* message;

@end
