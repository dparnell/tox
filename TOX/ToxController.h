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

- (ToxFriend*) friendWithFriendNumber:(int)friend_number;
- (void) removeConversionWithFriendNumber:(int)friend_number;

@property (weak) IBOutlet NSWindow* window;

@property (strong) NSString* nick;
@property (strong, nonatomic) NSString* status;
@property (assign) BOOL connected;
@property (strong) NSMutableArray* friends;
@property (strong) NSImage* status_icon;

@end
