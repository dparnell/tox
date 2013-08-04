//
//  ToxConversationWindowController.h
//  TOX
//
//  Created by Daniel Parnell on 4/08/13.
//  Copyright (c) 2013 Daniel Parnell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ToxFriend.h"

@interface ToxConversationWindowController : NSWindowController

+ (ToxConversationWindowController*) newWithFriendNumber:(int)friend_number;

- (void) addMessage:(NSDictionary*)message;

- (IBAction) sendMessage:(id)sender;

@property (assign) int friend_number;
@property (strong) ToxFriend* friend;
@property (strong) NSMutableArray* messages;
@property (strong) NSString* to_send;

@end
