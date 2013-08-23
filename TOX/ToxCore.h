//
//  ToxCore.h
//  TOX
//
//  Created by Daniel Parnell on 2/08/13.
//  Copyright (c) 2013 Daniel Parnell. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* kToxErrorDomain;

extern NSString* kToxConnectedNotification;
extern NSString* kToxDisconnectedNotification;

extern NSString* kToxFriendRequestNotification;
extern NSString* kToxMessageNotification;
extern NSString* kToxFriendNickChangedNotification;
extern NSString* kToxFriendStatusChangedNotification;
extern NSString* kToxActionNotification;
extern NSString* kToxMessageReadNotification;
extern NSString* kToxFriendRemovedNotification;

extern NSString* kToxPublicKey;
extern NSString* kToxMessageString;
extern NSString* kToxFriendNumber;
extern NSString* kToxNewFriendNick;
extern NSString* kToxNewFriendStatus;
extern NSString* kToxNewFriendStatusKind;
extern NSString* kToxMessageNumber;

extern NSString* kToxUserOnline;
extern NSString* kToxUserAway;
extern NSString* kToxUserBusy;
extern NSString* kToxUserOffline;
extern NSString* kToxUserInvalid;

@interface ToxCore : NSObject

+ (ToxCore*) instance;

- (BOOL) start:(NSURL*)url error:(NSError**)error;

- (int) friendNumber:(NSString*)client_id error:(NSError**)error;
- (NSString*) friendName:(int)friend_number error:(NSError**)error;
- (NSString*) clientIdForFriend:(int)friend_number error:(NSError**)error;
- (NSString*) friendStatus:(int)friend_number error:(NSError**)error;
- (NSString*) friendStatusKind:(int)friend_number error:(NSError**)error;
- (NSUInteger) sendMessage:(NSString*)text toFriend:(int)friend_number error:(NSError**)error;
- (BOOL) sendAction:(NSString*)text toFriend:(int)friend_number error:(NSError**)error;
- (int) friendStatusCode:(int)friend_number;
- (BOOL) sendFriendRequestTo:(NSString*)client_id message:(NSString*)message error:(NSError**)error;
- (int) addFriendWithoutRequest:(NSString*)client_id error:(NSError**)error;
- (BOOL) removeFriend:(int)friend_number error:(NSError**)error;

- (int) acceptFriendRequestFrom:(NSString*)client_id error:(NSError**)error;

+ (NSData*) dataFromHexString:(NSString*)string;

@property (readonly) NSString* public_key;
@property (readonly) BOOL connected;
@property (strong, nonatomic) NSString* user_status;
@property (copy, nonatomic) NSString* nick;
@property (copy, nonatomic) NSData* state;

@end
