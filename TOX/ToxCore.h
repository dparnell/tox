//
//  ToxCore.h
//  TOX
//
//  Created by Daniel Parnell on 2/08/13.
//  Copyright (c) 2013 Daniel Parnell. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* kToxErrorDomain;

extern NSString* kToxConnected;
extern NSString* kToxDisconnected;

extern NSString* kToxFriendRequest;
extern NSString* kToxMessage;
extern NSString* kToxFriendNickChanged;
extern NSString* kToxFriendStatusChanged;

extern NSString* kToxPublicKey;
extern NSString* kToxMessageString;
extern NSString* kToxFriendNumber;
extern NSString* kToxNewFriendNick;
extern NSString* kToxNewFriendStatus;

@interface ToxCore : NSObject

+ (ToxCore*) instance;

- (BOOL) start:(NSURL*)url error:(NSError**)error;
- (void) saveState;

- (int) acceptFriendRequestFrom:(NSString*)client_id error:(NSError**)error;

+ (NSData*) dataFromHexString:(NSString*)string;

@property (readonly) NSString* public_key;
@property (readonly) BOOL connected;

@end
