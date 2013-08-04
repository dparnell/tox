//
//  ToxFriend.h
//  TOX
//
//  Created by Daniel Parnell on 4/08/13.
//  Copyright (c) 2013 Daniel Parnell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ToxFriend : NSObject

+ (ToxFriend*) newWithFriendNumber:(int)friend_number;

@property (assign) int friend_number;
@property (strong) NSString* name;
@property (strong) NSString* status_message;
@property (strong) NSString* public_key;
@property (strong) NSImage* picture;

@end
