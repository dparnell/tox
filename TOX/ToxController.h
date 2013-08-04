//
//  ToxController.h
//  TOX
//
//  Created by Daniel Parnell on 4/08/13.
//  Copyright (c) 2013 Daniel Parnell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ToxFriend.h"

@interface ToxController : NSObject

+ (NSDictionary*) defaultValues;
+ (ToxController*) instance;

- (IBAction) copyPublicKeyToClipboard:(id)sender;
- (IBAction) showMainWindow:(id)sender;
- (IBAction) showConversation:(id)sender;
- (IBAction) addFriend:(id)sender;
- (IBAction) performAddFriend:(id)sender;
- (IBAction) cancelAddFriend:(id)sender;

- (ToxFriend*) friendWithFriendNumber:(int)friend_number;
- (void) removeConversionWithFriendNumber:(int)friend_number;

@property (assign) IBOutlet NSWindow* window;
@property (assign) IBOutlet NSTableView* friends_table;
@property (strong) IBOutlet NSPanel* add_panel;

@property (strong) NSString* nick;
@property (strong, nonatomic) NSString* status;
@property (assign) BOOL connected;
@property (strong) NSMutableArray* friends;
@property (strong) NSImage* status_icon;

@property (strong) NSString* add_public_key;
@property (strong) NSString* add_message;

@end
